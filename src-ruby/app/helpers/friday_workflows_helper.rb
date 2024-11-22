module FridayWorkflowsHelper
  def set_friday_workflow_helper_globals
    @core_fields = Tracker::CORE_FIELDS.to_a
    @issue_custom_fields = IssueCustomField.sorted.to_a
    @roles = Role.sorted.select(&:consider_workflow?)
  end

  # A Node in the UI represents an IssueStatus which the Issue can be set to.
  def get_workflow_nodes_for_tracker(tracker)
    workflow_nodes = tracker.nodes_json.nil? ? [] : JSON.parse(tracker.nodes_json)
    # Get all of the distinct IssueStatusIds in the `workflows` table for this Tracker.
    workflow_issue_status_ids = [
      tracker.default_status_id
    ]
    workflow_rules_for_tracker = WorkflowRule.where(tracker_id: tracker.id).distinct.pluck(:old_status_id, :new_status_id)
    workflow_rules_for_tracker.each do |rule|
      if !workflow_issue_status_ids.include?(rule[0])
        workflow_issue_status_ids << rule[0]
      end
      if !workflow_issue_status_ids.include?(rule[1])
        workflow_issue_status_ids << rule[1]
      end
    end
    nodes = []
    workflow_issue_status_ids.each do |issue_status_id|
      if !issue_status_id.nil? && issue_status_id != 0
        # find the workflow node which has the same issue status id
        workflow_node = workflow_nodes.find { |node| node["id"] == "issue-status-#{issue_status_id}" }
        if !workflow_node.nil?
          unless workflow_node[:type] == "start-node"
            workflow_node[:data] = {
              statusId: issue_status_id,
              statusName: IssueStatus.find(issue_status_id).name,
              current: get_current_field_permissions_for_issue_status(issue_status_id, tracker.id)
            }
          end
          nodes << workflow_node
        else
          nodes << make_node_for_issue_status(issue_status_id, tracker.id)
        end
      end
    end
    nodes
  end

  # An Edge in the UI represents a transition between two IssueStatuses.
  def get_workflow_edges_for_tracker(tracker)
    set_friday_workflow_helper_globals if @roles.nil?
    roles = @roles
    workflow_transitions_for_tracker = WorkflowTransition.where(tracker_id: tracker.id)
    edges = []
    workflow_edges_by_id = {}

    workflow_transitions_for_tracker.each do |transition|
      source_node = (transition.old_status_id.nil? || transition.old_status_id == 0) ? "start-node" : "issue-status-#{transition.old_status_id}"
      target_node = (transition.new_status_id.nil? || transition.new_status_id == 0) ? "end-node" : "issue-status-#{transition.new_status_id}"

      workflow_edge = {
        id: "vueflow__edge-#{source_node}out-#{target_node}in",
        type: "issue-status-transition",
        source: source_node,
        target: target_node,
        sourceHandle: "out",
        targetHandle: "in",
        data: {},
        markerEnd: "arrowclosed",
        animated: true
      }

      unless workflow_edges_by_id[workflow_edge[:id]]
        workflow_edge[:data] = {
          current: {}
        }

        roles.each do |role|
          if (transition.old_status_id.nil? || transition.old_status_id == 0) && transition.new_status_id == tracker.default_status_id
            workflow_edge[:data][:current][role.id.to_s] = {
              always: true,
              author: true,
              assignee: true
            }
          else
            role_transitions = workflow_transitions_for_tracker.select do |t|
              t.role_id == role.id &&
                t.old_status_id == transition.old_status_id &&
                t.new_status_id == transition.new_status_id
            end

            always = role_transitions.any? { |t| (t.assignee.nil? || t.assignee == false) && (t.author.nil? || t.author == false) }
            author = role_transitions.any? { |t| t.author == true }
            assignee = role_transitions.any? { |t| t.assignee == true }

            workflow_edge[:data][:current][role.id.to_s] = {
              always: always,
              author: author,
              assignee: assignee
            }
          end
        end

        workflow_edges_by_id[workflow_edge[:id]] = workflow_edge
        edges << workflow_edge
      end
    end

    workflow_edge_id_for_default_status = "vueflow__edge-start-nodeout-issue-status-#{tracker.default_status_id}in"
    if !workflow_edges_by_id[workflow_edge_id_for_default_status]
      workflow_edge = {
        id: workflow_edge_id_for_default_status,
        type: "issue-status-transition",
        source: "start-node",
        target: "issue-status-#{tracker.default_status_id}",
        sourceHandle: "out",
        targetHandle: "in",
        data: {},
        markerEnd: "arrowclosed",
        animated: true
      }

      workflow_edge[:data] = {
        current: {}
      }

      roles.each do |role|
        workflow_edge[:data][:current][role.id.to_s] = {
          always: true,
          author: true,
          assignee: true
        }
      end

      workflow_edges_by_id[workflow_edge[:id]] = workflow_edge
      edges << workflow_edge
    end

    edges
  end

  # Updates the workflows table with the current state of WorkflowPermission and WorkflowTransition
  # records based on the nodes and edges from the UI. Because the database stores the records in a format
  # which is not directly compatible with the UI, we need to convert the UI data into the database format.
  def update_from_nodes_and_edges(tracker, nodes, edges)
    raw_workflow_permissions = get_raw_workflow_permissions_from_nodes(tracker, nodes)
    raw_workflow_transitions = get_raw_workflow_transitions_from_edges(tracker, edges)
    workflow_rule_ids = []
    changes_made = false

    raw_workflow_permissions.each do |raw|
      raw = raw.to_h.deep_symbolize_keys if raw.is_a?(ActionController::Parameters)
      Rails.logger.info "raw #{raw}"
      existing = WorkflowPermission
        .where(type: raw[:type])
        .where(tracker_id: raw[:tracker_id])
        .where(old_status_id: raw[:old_status_id])
        .where(role_id: raw[:role_id])
        .where(field_name: raw[:field_name])
        .where(rule: raw[:rule])
        .first
      if existing.nil?
        existing = WorkflowPermission.create(raw)
        existing.save
        changes_made = true
      end
      workflow_rule_ids << existing.id
    end

    raw_workflow_transitions.each do |raw|
      raw = raw.to_h.deep_symbolize_keys if raw.is_a?(ActionController::Parameters)
      existing = WorkflowTransition
        .where(type: raw[:type])
        .where(tracker_id: raw[:tracker_id])
        .where(old_status_id: raw[:old_status_id])
        .where(new_status_id: raw[:new_status_id])
        .where(role_id: raw[:role_id])
        .where(assignee: raw[:assignee])
        .where(author: raw[:author])
        .first
      if existing.nil?
        existing = WorkflowTransition.create(raw)
        existing.save
        changes_made = true
      end
      workflow_rule_ids << existing.id
    end

    deleted_count = WorkflowPermission.where(tracker_id: tracker.id).where.not(id: workflow_rule_ids).destroy_all.size
    changes_made = true if deleted_count > 0

    changes_made
  end

  def nodes_are_different?(tracker_nodes_json, ui_nodes_json)
    # Parse JSON and handle nil cases
    tracker_nodes = tracker_nodes_json.nil? ? [] : JSON.parse(tracker_nodes_json)
    ui_nodes = ui_nodes_json.nil? ? [] : JSON.parse(ui_nodes_json)

    # Sort nodes by 'id' to ensure order doesn't matter
    sorted_tracker_nodes = tracker_nodes.sort_by { |node| node["id"] }
    sorted_ui_nodes = ui_nodes.sort_by { |node| node["id"] }

    # Compare lengths first to quickly determine difference
    return true if sorted_tracker_nodes.length != sorted_ui_nodes.length

    # Iterate and compare the specific properties of each node
    sorted_tracker_nodes.each_with_index do |tracker_node, index|
      ui_node = sorted_ui_nodes[index]

      # Check if node IDs match (to confirm we are comparing the right nodes)
      return true if tracker_node["id"] != ui_node["id"]

      # Compare the 'position' property
      return true if tracker_node["position"] != ui_node["position"]

      # Compare the 'data' property
      return true if tracker_node["data"] != ui_node["data"]
    end

    # If no differences are found, return false
    false
  end

  def edges_are_different?(tracker_edges_json, ui_edges_json)
    # Parse JSON and handle nil cases
    tracker_edges = tracker_edges_json.nil? ? [] : JSON.parse(tracker_edges_json)
    ui_edges = ui_edges_json.nil? ? [] : JSON.parse(ui_edges_json)

    # Sort edges by 'id' to ensure order doesn't matter
    sorted_tracker_edges = tracker_edges.sort_by { |edge| edge["id"] }
    sorted_ui_edges = ui_edges.sort_by { |edge| edge["id"] }

    # Compare lengths first to quickly determine difference
    return true if sorted_tracker_edges.length != sorted_ui_edges.length

    # Iterate and compare the specific properties of each edge
    sorted_tracker_edges.each_with_index do |tracker_edge, index|
      ui_edge = sorted_ui_edges[index]

      # Check if edge IDs match (to confirm we are comparing the right edges)
      return true if tracker_edge["id"] != ui_edge["id"]

      # Compare the 'source' property
      return true if tracker_edge["source"] != ui_edge["source"]

      # Compare the 'target' property
      return true if tracker_edge["target"] != ui_edge["target"]

      # Compare the 'data' property
      return true if tracker_edge["data"] != ui_edge["data"]
    end

    # If no differences are found, return false
    false
  end

  private

  def make_node_for_issue_status(issue_status_id, tracker_id)
    issue_status = IssueStatus.find(issue_status_id)
    if issue_status.nil?
      {
        id: "issue-status-#{issue_status_id}",
        type: "issue-status",
        position: {x: 0, y: 0},
        data: {
          statusId: issue_status_id,
          statusName: "Unknown",
          current: get_current_field_permissions_for_issue_status(issue_status_id, tracker_id)
        }
      }
    else
      {
        id: "issue-status-#{issue_status_id}",
        type: "issue-status",
        position: {x: 0, y: 0},
        data: {
          statusId: issue_status_id,
          statusName: issue_status.name,
          current: get_current_field_permissions_for_issue_status(issue_status_id, tracker_id)
        }
      }
    end
  end

  def get_current_field_permissions_for_issue_status(issue_status_id, tracker_id)
    if @roles.nil? || @core_fields.nil? || @issue_custom_fields.nil?
      set_friday_workflow_helper_globals
    end
    roles = @roles
    core_fields = @core_fields
    issue_custom_fields = @issue_custom_fields
    permissions_in_database = WorkflowPermission.where(old_status_id: issue_status_id, tracker_id: tracker_id)
    hash = {
      coreFields: {},
      customFields: {}
    }
    roles.each do |role|
      role_core_fields = {}
      role_custom_fields = {}

      core_fields.each do |field|
        from_db = permissions_in_database.find { |permission| permission.role_id == role.id && permission.field_name == field }
        role_core_fields[field.to_s] = from_db.nil? ? "" : from_db[:rule].to_s
      end
      issue_custom_fields.each do |field|
        from_db = permissions_in_database.find { |permission| permission.role_id == role.id && permission.field_name == field.id.to_s }
        role_custom_fields[field.id.to_s] = from_db.nil? ? "" : from_db[:rule].to_s
      end
      hash[:coreFields][role.id.to_s] = role_core_fields
      hash[:customFields][role.id.to_s] = role_custom_fields
    end
    hash
  end

  def get_raw_workflow_permissions_from_nodes(tracker, nodes)
    raw_workflow_permissions = []
    # each node holds permission settings for all fields, custom fields, and roles
    # related to a signle issue status
    nodes.each do |node|
      unless node[:type] == "start-node"
        unless node[:data][:current].nil?
          node[:data][:current][:coreFields].each do |role_id, core_fields|
            core_fields.each do |field, rule|
              if rule != ""
                raw_workflow_permissions << {
                  tracker_id: tracker.id,
                  old_status_id: node[:data][:statusId],
                  new_status_id: 0,
                  role_id: role_id,
                  assignee: 0,
                  author: 0,
                  type: "WorkflowPermission",
                  field_name: field,
                  rule: rule
                }
              end
            end
          end
        end
      end
      unless node[:data][:current].nil?
        node[:data][:current][:customFields].each do |role_id, custom_fields|
          custom_fields.each do |field, rule|
            if rule != ""
              raw_workflow_permissions << {
                tracker_id: tracker.id,
                old_status_id: node[:data][:statusId],
                new_status_id: 0,
                role_id: role_id,
                assignee: 0,
                author: 0,
                type: "WorkflowPermission",
                field_name: field,
                rule: rule
              }
            end
          end
        end
      end
    end
    raw_workflow_permissions
  end

  def get_raw_workflow_transitions_from_edges(tracker, edges)
    raw_workflow_transitions = []
    # each edge holds the transition information for all transitions between two issue statuses
    # for all roles, and whether the transition is allowed for the assignee and author
    edges.each do |edge|
      old_status_id = (edge[:source] == "start-node") ? 0 : edge[:source].sub("issue-status-", "").to_i
      new_status_id = (edge[:target] == "end-node") ? 0 : edge[:target].sub("issue-status-", "").to_i
      unless edge[:data][:current].nil?
        edge[:data][:current].each do |role_id, transitions|
          if transitions[:always]
            raw_workflow_transitions << {
              tracker_id: tracker.id,
              old_status_id: old_status_id,
              new_status_id: new_status_id,
              role_id: role_id,
              assignee: 0,
              author: 0,
              type: "WorkflowTransition",
              field_name: nil,
              rule: nil
            }
          end
          if transitions[:assignee]
            raw_workflow_transitions << {
              tracker_id: tracker.id,
              old_status_id: old_status_id,
              new_status_id: new_status_id,
              role_id: role_id,
              assignee: 1,
              author: 0,
              type: "WorkflowTransition",
              field_name: nil,
              rule: nil
            }
          end
          if transitions[:author]
            raw_workflow_transitions << {
              tracker_id: tracker.id,
              old_status_id: old_status_id,
              new_status_id: new_status_id,
              role_id: role_id,
              assignee: 0,
              author: 1,
              type: "WorkflowTransition",
              field_name: nil,
              rule: nil
            }
          end
        end
      end
    end
    raw_workflow_transitions
  end
end

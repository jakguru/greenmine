# frozen_string_literal: true

class UiController < ApplicationController
  unloadable

  def get_app_data
    projects = projects_for_jump_box(User.current)
    jump_box = Redmine::ProjectJumpBox.new User.current
    bookmarked = jump_box.bookmarked_projects
    recents = jump_box.recently_used_projects
    project_hashes = []
    Project.project_tree(projects) do |project, level|
      project_hashes << {
        id: project.id,
        name: project.name,
        identifier: project.identifier,
        level: level,
        lft: project.lft,
        rgt: project.rgt
      }
    end
    priorities = IssuePriority.active
    impacts = IssueImpact.active
    render json: {
      name: Setting.send(:app_title),
      i18n: ::I18n.locale,
      identity: {
        authenticated: User.current.logged?,
        identity: User.current.logged? ? User.current : nil
      },
      projects: {
        active: project_hashes,
        bookmarked: bookmarked,
        recent: recents
      },
      queries: {
        ProjectQuery: {
          operators: ProjectQuery.operators_by_filter_type
        },
        IssueQuery: {
          operators: IssueQuery.operators_by_filter_type
        },
        SprintsQuery: {
          operators: SprintsQuery.operators_by_filter_type
        }
      },
      settings: {
        loginRequired: Setting.login_required?,
        gravatarEnabled: Setting.gravatar_enabled?,
        selfRegistrationEnabled: Setting.self_registration?
      },
      priorities: priorities.map { |priority| {id: priority.id, name: priority.name, position: priority.position} },
      impacts: impacts.map { |impact| {id: impact.id, name: impact.name, position: impact.position} },
      fetchedAt: Time.now,
      friday: {
        sidekiq: ENV["REDIS_URL"] && !(defined?(Rails::Console) || File.split($0).last == "rake")
      }
    }
  end

  def get_project_link_info_by_id
    project = Project.find(params[:id])
    render json: {
      id: project.id,
      name: project.name,
      identifier: project.identifier
    }
  end

  def get_actions_for_issues
    find_issues
    permissions_by_issue = {}
    statuses_by_issue = {}
    assignees_by_issue = {}
    trackers_by_issue = {}
    versions_by_issue = {}
    urgencies = IssuePriority.active.reverse.map { |priority| {id: priority.id, name: priority.name} }
    impacts = IssueImpact.active.reverse.map { |impact| {id: impact.id, name: impact.name} }
    @issues.each do |issue|
      permissions_by_issue[issue.id] = {
        edit: (issue.assigned_to_id == User.current.id) ? User.current.allowed_to?(:edit_own_issues, issue.project) : User.current.allowed_to?(:edit_issues, issue.project),
        log_time: User.current.allowed_to?(:log_time, issue.project),
        copy: User.current.allowed_to?(:copy_issues, issue.project) && Issue.allowed_target_projects.any?,
        add_watchers: User.current.allowed_to?(:add_issue_watchers, issue.project),
        delete: User.current.allowed_to?(:delete_issues, issue.project),
        add_subtask: !issue.closed? && User.current.allowed_to?(:manage_subtasks, issue.project),
        assign_to_sprint: User.current.admin || User.current.allowed_to?(:assign_to_sprint, issue.project),
        unassign_from_sprint: issue.sprints.present? && (User.current.admin || User.current.allowed_to?(:unassign_from_sprint, issue.project))
      }
      statuses_by_issue[issue.id] = issue.new_statuses_allowed_to(User.current).map { |status| {id: status.id, name: status.name} }
      assignees_by_issue[issue.id] = issue.assignable_users.map { |user| {id: user.id, name: user.name} }
      trackers_by_issue[issue.id] = Issue.allowed_target_trackers(issue.project).map { |tracker| {id: tracker.id, name: tracker.name} }
      versions_by_issue[issue.id] = issue.project.shared_versions.open.map { |version| {id: version.id, name: version.name} }
    end

    permissions = permissions_by_issue.values.each_with_object(Hash.new(true)) do |issue_permissions, acc|
      issue_permissions.each do |action, value|
        acc[action] &&= value
      end
    end

    # Find common statuses, assignees, trackers, and versions that exist in all issues
    statuses = statuses_by_issue.values.reduce { |acc, statuses| acc & statuses }
    assignees = assignees_by_issue.values.reduce { |acc, assignees| acc & assignees }
    trackers = trackers_by_issue.values.reduce { |acc, trackers| acc & trackers }
    versions = versions_by_issue.values.reduce { |acc, versions| acc & versions }

    # Ensure the hashes only include values that exist in all of the *_by_issue lists
    statuses ||= []
    assignees ||= []
    trackers ||= []
    versions ||= []

    sprints = []
    if permissions[:assign_to_sprint]
      sprints = Sprint.where("end_date >= #{Date.today.to_date}").order(:start_date).map do |sprint|
        {
          id: sprint.id,
          name: sprint.name,
          starts: sprint.start_date.to_date,
          ends: sprint.end_date.to_date
        }
      end
    end
    render json: {
      permissions: permissions,
      values: {
        statuses: statuses,
        assignees: assignees,
        trackers: trackers,
        versions: versions,
        urgencies: urgencies,
        impacts: impacts,
        sprints: sprints
      }
    }
  end

  private

  def projects_for_jump_box(user = User.current)
    if user.logged?
      user.projects.active.select(:id, :name, :identifier, :lft, :rgt).to_a
    else
      []
    end
  end
end

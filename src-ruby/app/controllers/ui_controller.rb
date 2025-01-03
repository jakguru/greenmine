# frozen_string_literal: true

class UiController < ApplicationController
  unloadable
  include FridayHelper
  include FridayCustomFieldHelper

  skip_before_action :check_if_login_required, only: [:get_app_data, :get_project_link_info_by_id, :get_actions_for_issues, :get_user_avatar, :get_group_avatar, :manifest_dot_webmanifest, :browserconfig_dot_xml, :yandex_browser_manifest_dot_json]
  skip_before_action :check_password_change, only: [:get_app_data, :get_project_link_info_by_id, :get_actions_for_issues, :get_user_avatar, :get_group_avatar, :manifest_dot_webmanifest, :browserconfig_dot_xml, :yandex_browser_manifest_dot_json]

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
    field_formats = custom_field_types.keys.each_with_object({}) do |type, acc|
      acc[type] = Redmine::FieldFormat.as_select(type)
    end
    core_fields = Tracker::CORE_FIELDS.to_a
    issue_custom_fields = IssueCustomField.sorted.to_a
    render json: {
      name: Setting.send(:app_title),
      sudoMode: Redmine::SudoMode.active?,
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
        },
        CustomFieldQuery: {
          operators: CustomFieldQuery.operators_by_filter_type
        },
        RoleQuery: {
          operators: RoleQuery.operators_by_filter_type
        },
        GroupQuery: {
          operators: GroupQuery.operators_by_filter_type
        },
        UserQuery: {
          operators: UserQuery.operators_by_filter_type
        },
        GitlabsQuery: {
          operators: GitlabsQuery.operators_by_filter_type
        },
        GitlabProjectsQuery: {
          operators: GitlabProjectsQuery.operators_by_filter_type
        },
        GithubsQuery: {
          operators: GithubsQuery.operators_by_filter_type
        },
        MondaysQuery: {
          operators: MondaysQuery.operators_by_filter_type
        },
        GithubRepositoriesQuery: {
          operators: GithubRepositoriesQuery.operators_by_filter_type
        },
        MondayBoardsQuery: {
          operators: MondayBoardsQuery.operators_by_filter_type
        }
      },
      settings: {
        loginRequired: Setting.login_required?,
        gravatarEnabled: Setting.gravatar_enabled?,
        selfRegistrationEnabled: Setting.self_registration?
      },
      priorities: priorities.map { |priority| {id: priority.id, name: priority.name, position: priority.position} },
      impacts: impacts.map { |impact| {id: impact.id, name: impact.name, position: impact.position} },
      statuses: IssueStatus.sorted.each.collect { |v|
        {
          id: v.id,
          name: v.name,
          is_closed: v.is_closed,
          position: v.position,
          description: v.description,
          default_done_ratio: v.default_done_ratio,
          icon: v.icon,
          text_color: v.text_color,
          background_color: v.background_color
        }
      },
      trackers: Tracker.sorted.preload(:default_status).each.collect { |v|
        {
          id: v.id,
          name: v.name,
          default_status_id: v.default_status_id,
          is_in_roadmap: v.is_in_roadmap,
          description: v.description,
          core_fields: core_fields.select { |field| v.core_fields.include?(field) }.map(&:to_s),
          custom_field_ids: issue_custom_fields.select { |field| v.custom_fields.to_a.include?(field) }.map(&:id),
          position: v.position,
          icon: v.icon,
          color: v.color,
          project_ids: v.projects.map(&:id)
        }
      },
      roles: Role.sorted.select(&:consider_workflow?).each.collect { |v|
        {
          id: v.id,
          name: v.name,
          position: v.position
        }
      },
      fetchedAt: Time.now,
      friday: {
        sidekiq: ENV["REDIS_URL"] && !(defined?(Rails::Console) || File.split($0).last == "rake")
      },
      customFieldTypes: custom_field_types,
      fieldFormats: field_formats,
      allFieldFormats: Redmine::FieldFormat.all.values.select.each_with_object({}) do |format, acc|
        acc[format.name] = ::I18n.t(format.label)
      end,
      fieldFormatSupportsMultiple: Redmine::FieldFormat.all.values.select.each_with_object({}) do |format, acc|
        acc[format.name] = format.multiple_supported?
      end,
      fieldFormatSupportsFilter: Redmine::FieldFormat.all.values.select.each_with_object({}) do |format, acc|
        acc[format.name] = format.is_filter_supported?
      end,
      fieldFormatSupportsSearch: Redmine::FieldFormat.all.values.select.each_with_object({}) do |format, acc|
        acc[format.name] = format.searchable_supported?
      end
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
    sprints_by_issue = {}
    urgencies = IssuePriority.active.reverse.map { |priority| {id: priority.id, name: priority.name} }
    impacts = IssueImpact.active.reverse.map { |impact| {id: impact.id, name: impact.name} }

    assignable_sprints = Sprint.where("end_date >= #{Date.today.to_date}").order(:start_date).map do |sprint|
      {
        id: sprint.id,
        name: sprint.name,
        starts: sprint.start_date.to_date,
        ends: sprint.end_date.to_date
      }
    end

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
      sprints_by_issue[issue.id] = (permissions_by_issue[issue.id][:assign_to_sprint] == true) ? assignable_sprints.reject { |sprint| issue.sprints.include?(sprint[:id]) } : []
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
    sprints = sprints_by_issue.values.reduce { |acc, sprints| acc & sprints }

    # Ensure the hashes only include values that exist in all of the *_by_issue lists
    statuses ||= []
    assignees ||= []
    trackers ||= []
    versions ||= []
    sprints ||= []

    render json: {
      formAuthenticityToken: form_authenticity_token,
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

  def get_user_avatar
    user = User.find(params[:id])
    if user.present?
      if user.avatar.present?
        send_base64_avatar(user.avatar)
      else
        initials = user.name.split.map(&:first).join.upcase
        send_svg_avatar(initials)
      end
    else
      send_svg_avatar("?")
    end
  end

  def get_group_avatar
    group = Group.find(params[:id])
    if group.present?
      if group.avatar.present?
        send_base64_avatar(group.avatar)
      else
        initials = group.name.split.map(&:first).join.upcase
        send_svg_avatar(initials)
      end
    else
      send_svg_avatar("?")
    end
  end

  # /manifest.webmanifest
  def manifest_dot_webmanifest
    site_root = ENV["VITE_BASE_URL"].present? ? ENV["VITE_BASE_URL"] : "#{Setting.send(:protocol)}://#{Setting.send(:host_name)}"
    asset_path = "#{site_root}/plugin_assets/friday"
    render json: {
      name: "Friday",
      short_name: "Friday",
      description: "Welcome to Friday: your favorite day of the week! Say goodbye to the convoluted workflows and hello to intuitive, efficient, and no-nonsense project and product management. Friday works the way you do—cutting through the chaos and delivering a streamlined, developer-first experience. It’s as flexible as your code and as reliable as your coffee. With Friday, every day feels like a win—except maybe actual Monday!",
      dir: "auto",
      lang: "en-US",
      display: "minimal-ui",
      orientation: "any",
      start_url: "/",
      background_color: "#282F4C",
      theme_color: "#00854d",
      icons: [
        {
          src: "#{asset_path}/android-chrome-36x36.png",
          sizes: "36x36",
          type: "image/png",
          purpose: "any"
        },
        {
          src: "#{asset_path}/android-chrome-48x48.png",
          sizes: "48x48",
          type: "image/png",
          purpose: "any"
        },
        {
          src: "#{asset_path}/android-chrome-72x72.png",
          sizes: "72x72",
          type: "image/png",
          purpose: "any"
        },
        {
          src: "#{asset_path}/android-chrome-96x96.png",
          sizes: "96x96",
          type: "image/png",
          purpose: "any"
        },
        {
          src: "#{asset_path}/android-chrome-144x144.png",
          sizes: "144x144",
          type: "image/png",
          purpose: "any"
        },
        {
          src: "#{asset_path}/android-chrome-192x192.png",
          sizes: "192x192",
          type: "image/png",
          purpose: "any"
        },
        {
          src: "#{asset_path}/android-chrome-256x256.png",
          sizes: "256x256",
          type: "image/png",
          purpose: "any"
        },
        {
          src: "#{asset_path}/android-chrome-384x384.png",
          sizes: "384x384",
          type: "image/png",
          purpose: "any"
        },
        {
          src: "#{asset_path}/android-chrome-512x512.png",
          sizes: "512x512",
          type: "image/png",
          purpose: "any"
        },
        {
          src: "#{asset_path}/android-chrome-maskable-36x36.png",
          sizes: "36x36",
          type: "image/png",
          purpose: "maskable"
        },
        {
          src: "#{asset_path}/android-chrome-maskable-48x48.png",
          sizes: "48x48",
          type: "image/png",
          purpose: "maskable"
        },
        {
          src: "#{asset_path}/android-chrome-maskable-72x72.png",
          sizes: "72x72",
          type: "image/png",
          purpose: "maskable"
        },
        {
          src: "#{asset_path}/android-chrome-maskable-96x96.png",
          sizes: "96x96",
          type: "image/png",
          purpose: "maskable"
        },
        {
          src: "#{asset_path}/android-chrome-maskable-144x144.png",
          sizes: "144x144",
          type: "image/png",
          purpose: "maskable"
        },
        {
          src: "#{asset_path}/android-chrome-maskable-192x192.png",
          sizes: "192x192",
          type: "image/png",
          purpose: "maskable"
        },
        {
          src: "#{asset_path}/android-chrome-maskable-256x256.png",
          sizes: "256x256",
          type: "image/png",
          purpose: "maskable"
        },
        {
          src: "#{asset_path}/android-chrome-maskable-384x384.png",
          sizes: "384x384",
          type: "image/png",
          purpose: "maskable"
        },
        {
          src: "#{asset_path}/android-chrome-maskable-512x512.png",
          sizes: "512x512",
          type: "image/png",
          purpose: "maskable"
        }
      ],
      screenshots: [
        {
          src: "#{asset_path}/apple-touch-startup-image-1334x750.png",
          sizes: "1334x750",
          type: "image/png",
          form_factor: "wide"
        },
        {
          src: "#{asset_path}/apple-touch-startup-image-750x1334.png",
          sizes: "750x1334",
          type: "image/png",
          form_factor: "narrow"
        }
      ]
    }
  end

  # /browserconfig.xml
  def browserconfig_dot_xml
    site_root = ENV["VITE_BASE_URL"].present? ? ENV["VITE_BASE_URL"] : "#{Setting.send(:protocol)}://#{Setting.send(:host_name)}"
    asset_path = "#{site_root}/plugin_assets/friday"
    render xml: {
      browserconfig: {
        msapplication: {
          tile: {
            square70x70logo: {src: "#{asset_path}/mstile-70x70.png"},
            square150x150logo: {src: "#{asset_path}/mstile-150x150.png"},
            square310x310logo: {src: "#{asset_path}/mstile-310x310.png"},
            TileColor: "#282F4C"
          }
        }
      }
    }
  end

  # /yandex-browser-manifest.json
  def yandex_browser_manifest_dot_json
    site_root = ENV["VITE_BASE_URL"].present? ? ENV["VITE_BASE_URL"] : "#{Setting.send(:protocol)}://#{Setting.send(:host_name)}"
    asset_path = "#{site_root}/plugin_assets/friday"
    render json: {
      version: "1.0",
      api_version: 1,
      layout: {
        color: "#282F4C",
        logo: "#{asset_path}/yandex-browser-logo.png",
        show_title: true
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

  def send_base64_avatar(avatar)
    avatar_parts = avatar.split(",")
    avatar_data = avatar_parts[1]
    avatar_type = avatar_parts[0].split(";")[0].split(":")[1]
    send_data Base64.decode64(avatar_data), type: avatar_type, disposition: "inline"
  end

  def send_svg_avatar(initials)
    svg = Nokogiri::XML::Builder.new do |xml|
      xml.svg xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", width: "24", height: "24" do
        xml.rect x: "0", y: "0", width: "24", height: "24", fill: "none"
        xml.text_ initials, :x => "50%", :y => "50%", :dy => "0.35em", "text-anchor" => "middle", "font-family" => "Arial", "font-size" => "10", "font-weight" => "700", :fill => "white"
      end
    end
    send_data svg.to_xml, type: "image/svg+xml", disposition: "inline"
  end
end

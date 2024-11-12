module FridayCustomFieldHelper
  def custom_field_types
    {
      DocumentCategoryCustomField: l(:cf_type_document_category_custom_field),
      DocumentCustomField: l(:cf_type_document_custom_field),
      GroupCustomField: l(:cf_type_group_custom_field),
      IssueCustomField: l(:cf_type_issue_custom_field),
      IssuePriorityCustomField: l(:cf_type_issue_priority_custom_field),
      IssueImpactCustomField: l(:cf_type_issue_impact_custom_field),
      ProjectCustomField: l(:cf_type_project_custom_field),
      TimeEntryActivityCustomField: l(:cf_type_time_entry_activity_custom_field),
      TimeEntryCustomField: l(:cf_type_time_entry_custom_field),
      UserCustomField: l(:cf_type_user_custom_field),
      VersionCustomField: l(:cf_type_version_custom_field)
    }
  end

  def custom_field_type_forms
    custom_field = @custom_field
    custom_field ||= CustomField.new
    {
      DocumentCategoryCustomField: {
        field_format: {
          type: "select",
          props: {
            items: Redmine::FieldFormat.as_select(DocumentCategoryCustomField).map { |k, v| {value: k, label: v} },
            disabled: !custom_field.new_record?
          },
          value: custom_field.respond_to?(:field_format) ? custom_field.field_format : nil
        },
        name: {
          type: "text",
          props: {
            required: true
          },
          value: custom_field.respond_to?(:name) ? custom_field.name : nil
        },
        description: {
          type: "textarea",
          value: custom_field.respond_to?(:description) ? custom_field.description : nil
        }
      },
      DocumentCustomField: {
        field_format: {
          type: "select",
          props: {
            items: Redmine::FieldFormat.as_select(DocumentCustomField).map { |k, v| {value: k, label: v} },
            disabled: !custom_field.new_record?
          },
          value: custom_field.respond_to?(:field_format) ? custom_field.field_format : nil
        },
        name: {
          type: "text",
          props: {
            required: true
          },
          value: custom_field.respond_to?(:name) ? custom_field.name : nil
        },
        description: {
          type: "textarea",
          value: custom_field.respond_to?(:description) ? custom_field.description : nil
        }
      },
      GroupCustomField: {
        field_format: {
          type: "select",
          props: {
            items: Redmine::FieldFormat.as_select(GroupCustomField).map { |k, v| {value: k, label: v} },
            disabled: !custom_field.new_record?
          },
          value: custom_field.respond_to?(:field_format) ? custom_field.field_format : nil
        },
        name: {
          type: "text",
          props: {
            required: true
          },
          value: custom_field.respond_to?(:name) ? custom_field.name : nil
        },
        description: {
          type: "textarea",
          value: custom_field.respond_to?(:description) ? custom_field.description : nil
        }
      },
      IssueCustomField: {
        field_format: {
          type: "select",
          props: {
            items: Redmine::FieldFormat.as_select(IssueCustomField).map { |k, v| {value: k, label: v} },
            disabled: !custom_field.new_record?
          },
          value: custom_field.respond_to?(:field_format) ? custom_field.field_format : nil
        },
        name: {
          type: "text",
          props: {
            required: true
          },
          value: custom_field.respond_to?(:name) ? custom_field.name : nil
        },
        description: {
          type: "textarea",
          value: custom_field.respond_to?(:description) ? custom_field.description : nil
        },
        role_ids: {
          type: "select",
          props: {
            items: Role.givable.sorted.map { |role| {value: role.id, label: role.name} },
            multiple: true
          },
          value: custom_field.respond_to?(:role_ids) ? custom_field.role_ids : nil
        },
        tracker_ids: {
          type: "select",
          props: {
            items: Tracker.sorted.map { |tracker| {value: tracker.id, label: tracker.name} },
            multiple: true
          },
          value: custom_field.respond_to?(:tracker_ids) ? custom_field.tracker_ids : nil
        },
        is_for_all: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_for_all) ? custom_field.is_for_all : nil
        },
        project_ids: {
          type: "select",
          props: {
            items: get_project_nested_items(Project.all),
            multiple: true
          },
          value: custom_field.respond_to?(:project_ids) ? custom_field.project_ids : nil
        }
      },
      IssuePriorityCustomField: {
        field_format: {
          type: "select",
          props: {
            items: Redmine::FieldFormat.as_select(IssuePriorityCustomField).map { |k, v| {value: k, label: v} },
            disabled: !custom_field.new_record?
          },
          value: custom_field.respond_to?(:field_format) ? custom_field.field_format : nil
        },
        name: {
          type: "text",
          props: {
            required: true
          },
          value: custom_field.respond_to?(:name) ? custom_field.name : nil
        },
        description: {
          type: "textarea",
          value: custom_field.respond_to?(:description) ? custom_field.description : nil
        }
      },
      IssueImpactCustomField: {
        field_format: {
          type: "select",
          props: {
            items: Redmine::FieldFormat.as_select(IssueImpactCustomField).map { |k, v| {value: k, label: v} },
            disabled: !custom_field.new_record?
          },
          value: custom_field.respond_to?(:field_format) ? custom_field.field_format : nil
        },
        name: {
          type: "text",
          props: {
            required: true
          },
          value: custom_field.respond_to?(:name) ? custom_field.name : nil
        },
        description: {
          type: "textarea",
          value: custom_field.respond_to?(:description) ? custom_field.description : nil
        }
      },
      ProjectCustomField: {
        field_format: {
          type: "select",
          props: {
            items: Redmine::FieldFormat.as_select(ProjectCustomField).map { |k, v| {value: k, label: v} },
            disabled: !custom_field.new_record?
          },
          value: custom_field.respond_to?(:field_format) ? custom_field.field_format : nil
        },
        name: {
          type: "text",
          props: {
            required: true
          },
          value: custom_field.respond_to?(:name) ? custom_field.name : nil
        },
        description: {
          type: "textarea",
          value: custom_field.respond_to?(:description) ? custom_field.description : nil
        },
        role_ids: {
          type: "select",
          props: {
            items: Role.givable.sorted.map { |role| {value: role.id, label: role.name} },
            multiple: true
          },
          value: custom_field.respond_to?(:role_ids) ? custom_field.role_ids : nil
        }
      },
      TimeEntryActivityCustomField: {
        field_format: {
          type: "select",
          props: {
            items: Redmine::FieldFormat.as_select(TimeEntryActivityCustomField).map { |k, v| {value: k, label: v} },
            disabled: !custom_field.new_record?
          },
          value: custom_field.respond_to?(:field_format) ? custom_field.field_format : nil
        },
        name: {
          type: "text",
          props: {
            required: true
          },
          value: custom_field.respond_to?(:name) ? custom_field.name : nil
        },
        description: {
          type: "textarea",
          value: custom_field.respond_to?(:description) ? custom_field.description : nil
        }
      },
      TimeEntryCustomField: {
        field_format: {
          type: "select",
          props: {
            items: Redmine::FieldFormat.as_select(TimeEntryCustomField).map { |k, v| {value: k, label: v} },
            disabled: !custom_field.new_record?
          },
          value: custom_field.respond_to?(:field_format) ? custom_field.field_format : nil
        },
        name: {
          type: "text",
          props: {
            required: true
          },
          value: custom_field.respond_to?(:name) ? custom_field.name : nil
        },
        description: {
          type: "textarea",
          value: custom_field.respond_to?(:description) ? custom_field.description : nil
        },
        role_ids: {
          type: "select",
          props: {
            items: Role.givable.sorted.map { |role| {value: role.id, label: role.name} },
            multiple: true
          },
          value: custom_field.respond_to?(:role_ids) ? custom_field.role_ids : nil
        }
      },
      UserCustomField: {
        field_format: {
          type: "select",
          props: {
            items: Redmine::FieldFormat.as_select(UserCustomField).map { |k, v| {value: k, label: v} },
            disabled: !custom_field.new_record?
          },
          value: custom_field.respond_to?(:field_format) ? custom_field.field_format : nil
        },
        name: {
          type: "text",
          props: {
            required: true
          },
          value: custom_field.respond_to?(:name) ? custom_field.name : nil
        },
        description: {
          type: "textarea",
          value: custom_field.respond_to?(:description) ? custom_field.description : nil
        },
        visible: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:visible) ? custom_field.visible : nil
        },
        editable: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:editable) ? custom_field.editable : nil
        }
      },
      VersionCustomField: {
        field_format: {
          type: "select",
          props: {
            items: Redmine::FieldFormat.as_select(VersionCustomField).map { |k, v| {value: k, label: v} },
            disabled: !custom_field.new_record?
          },
          value: custom_field.respond_to?(:field_format) ? custom_field.field_format : nil
        },
        name: {
          type: "text",
          props: {
            required: true
          },
          value: custom_field.respond_to?(:name) ? custom_field.name : nil
        },
        description: {
          type: "textarea",
          value: custom_field.respond_to?(:description) ? custom_field.description : nil
        },
        role_ids: {
          type: "select",
          props: {
            items: Role.givable.sorted.map { |role| {value: role.id, label: role.name} },
            multiple: true
          },
          value: custom_field.respond_to?(:role_ids) ? custom_field.role_ids : nil
        }
      }
    }
  end

  def custom_field_format_forms
    custom_field = @custom_field
    custom_field ||= CustomField.new
    {
      attachment: {
        extensions_allowed: {
          type: "csv",
          props: {},
          value: custom_field.respond_to?(:extensions_allowed) ? custom_field.extensions_allowed : nil
        },
        is_required: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_required) ? custom_field.is_required : nil
        }
      },
      bool: {
        default_value: {
          type: "select",
          props: {
            items: custom_field.possible_values.map { |v| {value: v, label: v} }
          },
          value: custom_field.respond_to?(:default_value) ? custom_field.default_value : nil
        },
        url_pattern: {
          type: "text",
          props: {},
          value: custom_field.respond_to?(:url_pattern) ? custom_field.url_pattern : nil
        },
        is_required: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_required) ? custom_field.is_required : nil
        }
      },
      date: {
        is_required: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_required) ? custom_field.is_required : nil
        },
        default_value: {
          type: "text",
          props: {
            type: "date"
          },
          value: custom_field.respond_to?(:default_value) ? custom_field.default_value : nil
        },
        url_pattern: {
          type: "text",
          props: {},
          value: custom_field.respond_to?(:url_pattern) ? custom_field.url_pattern : nil
        }
      },
      enumeration: {
        multiple: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:multiple) ? custom_field.multiple : nil
        },
        is_required: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_required) ? custom_field.is_required : nil
        },
        default_value: {
          type: "select",
          props: {
            items: custom_field.enumerations.active.map { |v| {value: v.id.to_s, label: v.name} }
          },
          value: custom_field.respond_to?(:default_value) ? custom_field.default_value : nil
        },
        url_pattern: {
          type: "text",
          props: {},
          value: custom_field.respond_to?(:url_pattern) ? custom_field.url_pattern : nil
        }
      },
      float: {
        is_required: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_required) ? custom_field.is_required : nil
        },
        min_length: {
          type: "text",
          props: {
            type: "number",
            min: 0
          },
          value: custom_field.respond_to?(:min_length) ? custom_field.min_length : nil
        },
        max_length: {
          type: "text",
          props: {
            type: "number",
            min: 0
          },
          value: custom_field.respond_to?(:max_length) ? custom_field.max_length : nil
        },
        regexp: {
          type: "text",
          props: {},
          value: custom_field.respond_to?(:regexp) ? custom_field.regexp : nil
        },
        default_value: {
          type: "text",
          props: {
            type: "number",
            steps: "any"
          },
          value: custom_field.respond_to?(:default_value) ? custom_field.default_value : nil
        }
      },
      int: {
        is_required: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_required) ? custom_field.is_required : nil
        },
        min_length: {
          type: "text",
          props: {
            type: "number",
            min: 0
          },
          value: custom_field.respond_to?(:min_length) ? custom_field.min_length : nil
        },
        max_length: {
          type: "text",
          props: {
            type: "number",
            min: 0
          },
          value: custom_field.respond_to?(:max_length) ? custom_field.max_length : nil
        },
        regexp: {
          type: "text",
          props: {},
          value: custom_field.respond_to?(:regexp) ? custom_field.regexp : nil
        },
        default_value: {
          type: "text",
          props: {
            type: "number",
            steps: "1"
          },
          value: custom_field.respond_to?(:default_value) ? custom_field.default_value : nil
        }
      },
      link: {
        is_required: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_required) ? custom_field.is_required : nil
        },
        min_length: {
          type: "text",
          props: {
            type: "number",
            min: 0
          },
          value: custom_field.respond_to?(:min_length) ? custom_field.min_length : nil
        },
        max_length: {
          type: "text",
          props: {
            type: "number",
            min: 0
          },
          value: custom_field.respond_to?(:max_length) ? custom_field.max_length : nil
        },
        regexp: {
          type: "text",
          props: {},
          value: custom_field.respond_to?(:regexp) ? custom_field.regexp : nil
        },
        default_value: {
          type: "text",
          props: {
            type: "url"
          },
          value: custom_field.respond_to?(:default_value) ? custom_field.default_value : nil
        }
      },
      list: {
        multiple: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:multiple) ? custom_field.multiple : nil
        },
        is_required: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_required) ? custom_field.is_required : nil
        },
        possible_values: {
          type: "lbsv",
          props: {},
          value: custom_field.respond_to?(:possible_values) ? custom_field.possible_values : nil
        },
        default_value: {
          type: "text",
          value: custom_field.respond_to?(:default_value) ? custom_field.default_value : nil
        },
        url_pattern: {
          type: "text",
          props: {},
          value: custom_field.respond_to?(:url_pattern) ? custom_field.url_pattern : nil
        }
      },
      string: {
        is_required: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_required) ? custom_field.is_required : nil
        },
        min_length: {
          type: "text",
          props: {
            type: "number",
            min: 0
          },
          value: custom_field.respond_to?(:min_length) ? custom_field.min_length : nil
        },
        max_length: {
          type: "text",
          props: {
            type: "number",
            min: 0
          },
          value: custom_field.respond_to?(:max_length) ? custom_field.max_length : nil
        },
        regexp: {
          type: "text",
          props: {},
          value: custom_field.respond_to?(:regexp) ? custom_field.regexp : nil
        },
        default_value: {
          type: "text",
          props: {},
          value: custom_field.respond_to?(:default_value) ? custom_field.default_value : nil
        }
      },
      text: {
        is_required: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_required) ? custom_field.is_required : nil
        },
        min_length: {
          type: "text",
          props: {
            type: "number",
            min: 0
          },
          value: custom_field.respond_to?(:min_length) ? custom_field.min_length : nil
        },
        max_length: {
          type: "text",
          props: {
            type: "number",
            min: 0
          },
          value: custom_field.respond_to?(:max_length) ? custom_field.max_length : nil
        },
        regexp: {
          type: "text",
          props: {},
          value: custom_field.respond_to?(:regexp) ? custom_field.regexp : nil
        },
        default_value: {
          type: "text",
          props: {},
          value: custom_field.respond_to?(:default_value) ? custom_field.default_value : nil
        }
      },
      user: {
        multiple: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:multiple) ? custom_field.multiple : nil
        },
        is_required: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_required) ? custom_field.is_required : nil
        },
        user_role: {
          type: "select",
          props: {
            items: Role.givable.sorted.map { |role| {value: role.id, label: role.name} },
            multiple: true
          },
          value: custom_field.respond_to?(:user_role) ? custom_field.user_role : nil
        }
      },
      version: {
        multiple: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:multiple) ? custom_field.multiple : nil
        },
        is_required: {
          type: "checkbox",
          props: {},
          value: custom_field.respond_to?(:is_required) ? custom_field.is_required : nil
        },
        version_status: {
          type: "select",
          props: {
            items: Version::VERSION_STATUSES.map { |k, v| {value: k, label: v} },
            multiple: true
          },
          value: custom_field.respond_to?(:version_status) ? custom_field.version_status : nil
        }
      }
    }
  end

  def custom_field_type_field_format_forms
    custom_field = @custom_field
    custom_field ||= CustomField.new
    {
      IssueCustomField: {
        string: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          },
          searchable: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:searchable) ? custom_field.searchable : nil
          }
        },
        text: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          },
          searchable: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:searchable) ? custom_field.searchable : nil
          }
        },
        link: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        int: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        float: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        date: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        list: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          },
          searchable: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:searchable) ? custom_field.searchable : nil
          }
        },
        bool: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        enumeration: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        user: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        version: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        attachment: {}
      },
      UserCustomField: {
        string: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        text: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        link: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        int: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        float: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        date: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        list: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        bool: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        enumeration: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        user: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        version: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        attachment: {}
      },
      ProjectCustomField: {
        string: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          },
          searchable: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:searchable) ? custom_field.searchable : nil
          }
        },
        text: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          },
          searchable: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:searchable) ? custom_field.searchable : nil
          }
        },
        link: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        int: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        float: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        date: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        list: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          },
          searchable: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:searchable) ? custom_field.searchable : nil
          }
        },
        bool: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        enumeration: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        user: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        version: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        attachment: {}
      },
      VersionCustomField: {
        string: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        text: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        link: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        int: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        float: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        date: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        list: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        bool: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        enumeration: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        user: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        version: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        attachment: {}
      },
      GroupCustomField: {
        string: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        text: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        link: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        int: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        float: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        date: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        list: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        bool: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        enumeration: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        user: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        version: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        attachment: {}
      },
      TimeEntryCustomField: {
        string: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        text: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        link: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        int: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        float: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        date: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        list: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        bool: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        enumeration: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        user: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        version: {
          is_filter: {
            type: "checkbox",
            props: {},
            value: custom_field.respond_to?(:is_filter) ? custom_field.is_filter : nil
          }
        },
        attachment: {}
      }
    }
  end

  def get_project_nested_items(projects)
    result = []
    if projects.any?
      ancestors = []
      projects.sort_by(&:lft).each do |project|
        # Remove ancestors that are no longer part of the current project's hierarchy
        while ancestors.any? && !project.is_descendant_of?(ancestors.last)
          ancestors.pop
        end

        # Create label with '>' symbols to indicate depth level
        depth_indicator = ">" * ancestors.size
        label = "#{depth_indicator} #{project.name}".strip

        # Add the project to the result array as a hash with value and label
        result << {value: project.id, label: label}

        # Add the current project to ancestors stack
        ancestors << project
      end
    end
    result
  end
end

class MondayBoard < ActiveRecord::Base
  include Redmine::SafeAttributes
  # Associations
  belongs_to :monday_instance, class_name: "MondayInstance", foreign_key: "monday_id"
  belongs_to :project, class_name: "Project", foreign_key: "project_id"

  # Validations
  validates :monday_id, presence: true
  validates :project_id, presence: true  # This represents the GitLab API project ID
  validates :board_meta_data, presence: true
  validates :board_field_mapping, presence: true

  def safe_attribute?(attribute)
    # You can add more complex logic here based on attribute security, but for now, return true for all attributes
    true
  end

  def board_field_mappings
    board_field_mapping
  end

  def board_field_mappings=(board_field_mappings)
    self.board_field_mapping = board_field_mappings.to_unsafe_h
  end

  def columns
    board_meta_data["columns"]
  end

  def description
    board_meta_data["description"]
  end

  def item_terminology
    board_meta_data["item_terminology"]
  end

  def name
    board_meta_data["name"]
  end

  def state
    board_meta_data["state"]
  end

  def type
    board_meta_data["type"]
  end

  def url
    board_meta_data["url"]
  end
end

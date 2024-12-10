class MondayInstance < ActiveRecord::Base
  self.table_name = "mondays"
  include Redmine::SafeAttributes
  # Associations
  has_many :monday_boards, dependent: :destroy, class_name: "MondayBoard", foreign_key: "monday_id"
  has_many :monday_users, dependent: :destroy, class_name: "MondayUser", foreign_key: "monday_id"

  # Validations
  validates :name, presence: true
  validates :api_token, presence: true

  # Scopes
  scope :active, -> { where(active: true) }

  def safe_attribute?(attribute)
    # You can add more complex logic here based on attribute security, but for now, return true for all attributes
    true
  end
end

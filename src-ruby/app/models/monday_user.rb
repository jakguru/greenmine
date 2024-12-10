class MondayUser < ActiveRecord::Base
  include Redmine::SafeAttributes
  # Associations
  belongs_to :monday_instance, class_name: "MondayInstance", foreign_key: "monday_id"
  has_many :user_monday_users, class_name: "UserMondayUser", foreign_key: "monday_user_id"
  has_many :users, through: :user_monday_users

  # Validations
  validates :monday_id, presence: true
  validates :user_id, presence: true  # This represents the Monday user ID

  def safe_attribute?(attribute)
    # You can add more complex logic here based on attribute security, but for now, return true for all attributes
    true
  end

  def name
    user_meta_data["name"]
  end

  def email
    user_meta_data["email"]
  end

  def title
    user_meta_data["title"]
  end

  def photo_original
    user_meta_data["photo_original"]
  end

  def redmine_user
    users.first
  end

  def redmine_user=(redmine_user_id)
    set_redmine_user(redmine_user_id)
  end

  def set_redmine_user(redmine_user_id)
    user_monday_user = UserMondayUser.where(monday_user_id: self[:id]).first
    if user_monday_user.nil?
      user_monday_user = UserMondayUser.new(monday_user_id: self[:id])
    elsif redmine_user_id.nil?
      user_monday_user.destroy!
      return true
    end
    user_monday_user.user_id = redmine_user_id
    user_monday_user.save!
  end
end

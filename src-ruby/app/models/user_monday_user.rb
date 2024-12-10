class UserMondayUser < ActiveRecord::Base
  self.table_name = "user_monday_users"
  belongs_to :user
  belongs_to :monday_user

  validates :user_id, presence: true
  validates :monday_user_id, presence: true
end

class IssueSprint < ActiveRecord::Base
  belongs_to :issue
  belongs_to :sprint

  validates :issue_id, presence: true
  validates :sprint_id, presence: true
end

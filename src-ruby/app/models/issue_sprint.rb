class IssueSprint < ActiveRecord::Base
  after_create :push_on_create
  after_destroy :push_on_destroy

  belongs_to :issue
  belongs_to :sprint

  validates :issue_id, presence: true
  validates :sprint_id, presence: true

  def push_on_create
    FridayPlugin::IssuesChannel.broadcast_to(issue, issue)
    FridayPlugin::SprintsChannel.broadcast_to(sprint, sprint)
  end

  def push_on_destroy
    FridayPlugin::IssuesChannel.broadcast_to(issue, issue)
    FridayPlugin::SprintsChannel.broadcast_to(sprint, sprint)
    FridayPlugin::SprintsChannel.broadcast_to(Sprint.backlog, Sprint.backlog)
  end
end

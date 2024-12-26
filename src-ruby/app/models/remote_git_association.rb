class RemoteGitAssociation < ActiveRecord::Base
  belongs_to :associable, polymorphic: true
  belongs_to :issue
end

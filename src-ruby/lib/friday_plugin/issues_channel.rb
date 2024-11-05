module FridayPlugin
  class IssuesChannel < ApplicationCable::Channel
    def subscribed
      issue = Issue.find(params[:id])
      if issue&.visible?(current_user)
        stream_for issue
      else
        reject
      end
    end
  end
end

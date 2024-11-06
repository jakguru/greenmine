module FridayPlugin
  class SprintsChannel < ApplicationCable::Channel
    def subscribed
      sprint = (params[:id] == 0 || params[:id].nil?) ? Sprint.backlog : Sprint.find(params[:id])
      stream_for sprint
    end
  end
end

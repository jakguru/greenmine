module FridayPlugin
  class RealTimeUpdatesChannel < ApplicationCable::Channel
    def subscribed
      stream_from "rtu_#{params[:room]}"
    end
  end
end

class TestChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel#{params[:room]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end

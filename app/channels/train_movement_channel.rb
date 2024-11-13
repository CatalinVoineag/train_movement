class TrainMovementChannel < ApplicationCable::Channel
  def subscribed
    stream_from "train_movement"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

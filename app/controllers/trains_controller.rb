class TrainsController < ApplicationController
  def index
  end

  def movement
    ActionCable.server.broadcast("train_movement", { message: "socket"})
    head :ok
  end
end
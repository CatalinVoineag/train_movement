class TrainMvtAllTocConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      puts message
    end
  end
end

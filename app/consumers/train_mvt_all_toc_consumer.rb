class TrainMvtAllTocConsumer < ApplicationConsumer
  def consume
    stanox_dataset = CSV.parse(File.read("tiplocs-merged-all.csv"), headers: false)

    messages.each do |message|
      json_items = JSON.parse(message.raw_payload)

      json_items.each do |item|
        stanox = item["body"]["loc_stanox"]
        stanox_array = stanox_dataset.find{|element| element.first == stanox}

        next if stanox_array.nil?
        train_id = item["body"]["train_id"] #if train_id.nil?

        if item["header"]["msg_type"] == "0003" && item['body']['toc_id'] == "65"
          ActionCable.server.broadcast(
            "train_movement",
            {
              message: "train is moving",
              lat: stanox_array[6],
              long: stanox_array[5],
              train_id: train_id
            }
          )
        end
      end
    end
  end
end

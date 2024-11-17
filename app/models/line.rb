class Line < ApplicationRecord
  # Liverpool to Manchester Line (Northern Route)
  has_many :coordinates

  def run
    coordinates.each do |coordinate|
      sleep(1)
      ActionCable.server.broadcast(
        'train_movement',
        {
          message: 'train is moving',
          lat: coordinate.lat,
          long: coordinate.long,
          train_id: 1
        }
      )
    end
  end
end

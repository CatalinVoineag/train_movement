require "stomp"

class Movement
  attr_reader :stanox_dataset, :hostname, :username, :password

  def initialize
    @hostname = 'publicdatafeeds.networkrail.co.uk'
    @username = Rails.application.credentials.network_rail_username
    @password = Rails.application.credentials.network_rail_password
    @stanox_dataset = CSV.parse(File.read("tiplocs-merged-all.csv"), headers: false)
  end

  def self.call
    new.call
  end

  def call
    client_headers = { "accept-version" => "1.1", "heart-beat" => "5000,10000", "client-id" => Socket.gethostname, "host" => hostname }
    client_hash = { :hosts => [ { :login => username, :passcode => password, :host => hostname, :port => 61618 } ], :connect_headers => client_headers }

    client = Stomp::Client.new(client_hash)

    # Check we have connected successfully

    raise "Connection failed" unless client.open?
    raise "Connect error: #{client.connection_frame().body}" if client.connection_frame().command == Stomp::CMD_ERROR
    raise "Unexpected protocol level #{client.protocol}" unless client.protocol == Stomp::SPL_11

    puts "Connected to #{client.connection_frame().headers['server']} server with STOMP #{client.connection_frame().headers['version']}"

    # Subscribe to the RTPPM topic and process messages

    train_id = nil

    client.subscribe("/topic/TRAIN_MVT_HF_TOC", { 'id' => client.uuid(), 'ack' => 'client', 'activemq.subscriptionName' => Socket.gethostname + '-TRAIN_MVT_HF_TOC' }) do |msg|

      json_items = JSON.parse(msg.body)

      json_items.each do |item|
        stanox = item["body"]["loc_stanox"]
        stanox_array = stanox_dataset.find{|element| element.first == stanox}

        next if stanox_array.nil?
        train_id = item["body"]["train_id"] #if train_id.nil?

       # if item["body"]["train_id"] == train_id && item["header"]["msg_type"] == "0003"
        if item["header"]["msg_type"] == "0003"
          puts "Train id: #{item['body']['train_id']} #{stanox_array[6]}, #{stanox_array[5]} STANOX: #{stanox}"

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

      #puts msg.body

      client.acknowledge(msg, msg.headers)
    end

    client.join


    # We will probably never end up here

    client.close
    puts "Client close complete"
  end
end

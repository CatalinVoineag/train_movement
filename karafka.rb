# frozen_string_literal: true

class KarafkaApp < Karafka::App
  setup do |config|
    config.client_id = 'TRAIN_MVT_ALL_TOC'
    config.kafka = {
      'bootstrap.servers': 'pkc-z3p1v0.europe-west2.gcp.confluent.cloud:9092',
      'security.protocol': 'SASL_SSL',
      'sasl.mechanism': 'PLAIN',
      'sasl.username': Rails.application.credentials.network_rail_username,
      'sasl.password': Rails.application.credentials.network_rail_password,
      'group.id': Rails.application.credentials.network_rail_group,
      'auto.offset.reset': 'earliest', # Start consuming from the earliest message if no offset is stored
      'ssl.ca.location': '/usr/lib/ssl/certs/ca-certificates.crt'
    }
  end

  config.consumer_persistence = !Rails.env.development?

  Karafka.monitor.subscribe(
    Karafka::Instrumentation::LoggerListener.new(
      log_polling: true
    )
  )

  Karafka.producer.monitor.subscribe(
    WaterDrop::Instrumentation::LoggerListener.new(
      Karafka.logger,
      log_messages: false
    )
  )
  routes.draw do
    topic :TRAIN_MVT_ALL_TOC do
      consumer TrainMvtAllTocConsumer
    end
  end
end

#Karafka::Web.setup do |config|
#  # Report every 10 seconds
#  config.tracking.interval = 10_000
#end
#
#Karafka::Web.enable!

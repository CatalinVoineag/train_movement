require 'net/http'
require 'uri'
require 'json'

class Overpass
  attr_reader :uri

  def initialize
    @uri = URI("https://overpass-api.de/api/interpreter")
  end

  def self.call
    new.call
  end

  def call
    # The query string
    query = <<-QUERY
    [bbox:30.618338,-96.323712,30.591028,-96.330826]
    [out:json]
    [timeout:90]
    ;
    (
        area["name"="Great Britain"];
        way[railway~"^(rail)$"]["name"="Styal Line"](area);
        >;
    );
    out geom;
    QUERY

    # Setting up the HTTP request
    request = Net::HTTP::Post.new(uri)
    request.body = "data=" + URI.encode_www_form_component(query)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    result = JSON.parse(response.body)

   # byebug
    nodes = result.fetch("elements").select{|x| x.fetch('tags', {})['name'] == "Styal Line"}

    nodes.reverse.each do |node|
      node['geometry'].reverse.each do |coordinates|
        Node.find_or_create_by(
          lat: coordinates.fetch('lat'),
          lon: coordinates.fetch('lon'),
          name: node.fetch('tags').fetch('name')
        )
      end
    end

    #puts JSON.pretty_generate(result)
    puts "Done?"
  end
end

class ImportLines
  attr_reader :file_name

  def initialize(file_name)
    @file_name = file_name
  end

  def self.call(file_name)
    new(file_name).call
  end

  def call
    items = RGeo::GeoJSON.decode(File.read(file_name))

    items.map do |item|
      puts 'Inserting'

      hash = item.as_geojson
      next unless hash['properties'] && hash['properties']['other_tags']

      other_tags = JSON.parse("{#{hash['properties']['other_tags'].gsub('=>', ':')}}")
      next unless other_tags['operator'] == 'Network Rail'

      ActiveRecord::Base.transaction do
        line = Line.find_or_create_by!(name: hash.fetch('properties').fetch('name'))

        coordinates = hash.fetch('geometry')['coordinates'].flatten(1)

        coordinate_records = coordinates.map do |coordinate|
          { long: coordinate.first, lat: coordinate.last, line_id: line.id }
        end.uniq!

        Coordinate.insert_all!(coordinate_records)
      end
    end
  end
end

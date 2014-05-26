require 'nokogiri'
require 'json'
require 'addressable/uri'
require 'rest-client'

class IceCreamFinder
  attr_accessor :max_distance, :shoppes
  
  def self.api_key
    begin
      api_key = File.read('.api_key').chomp
    rescue
      puts "Unable to read '.api_key'. Please provide a valid Google API key."
      exit
    end
  end
  
  def parse_directions(directions)
    steps = directions["routes"][0]["legs"][0]["steps"]
    
    steps.each_with_index.map do |step, i|
      "#{i}. " + Nokogiri::HTML(step["html_instructions"])
    end.join("\n")
  end
  
  def get_directions(from_ll, to_ll)
    results = JSON.parse(RestClient.get(create_directions_request(from_ll, to_ll)))   
  end
  
  def create_directions_request(from_ll, to_ll) 
    request = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/directions/json",
      :query_values => {
        origin: from_ll,
        destination: to_ll,
        sensor: false,
        key: IceCreamFinder.api_key
      }
    ).to_s    
  end
  
  def create_shoppes_request(location)
    request = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/place/nearbysearch/json",
      :query_values => {
        location: location, 
        sensor: false,
        radius: 5000,
        query: "ice cream",
        types: "food",
        key: IceCreamFinder.api_key
      }
    ).to_s
  end
  
  def create_location_request(zip)
    request = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/geocode/json",
      :query_values => {
        components: "postal_code:#{zip}", 
        sensor: false, 
        key: IceCreamFinder.api_key
      }
    ).to_s
  end
  
  def shoppes_list(location)
    results = JSON.parse(RestClient.get(create_shoppes_request(location)))
  end

  def location_to_ll(zip)
    results = JSON.parse(RestClient.get(create_location_request(zip)))
    
    results["results"][0]["geometry"]["location"].values.join(',')
  end
  
  def find_me_icecream
    puts "What is your zip code? (e.g. 11201)"
    zip = gets.chomp
    my_ll = location_to_ll(zip)
    top_shop = shoppes_list(my_ll)["results"][0]
    puts "#{top_shop['name']} located at: #{top_shop['vicinity']}"
    shop_ll = top_shop["geometry"]["location"].values.join(',')
    directions = get_directions(my_ll, shop_ll)
    puts parse_directions(directions)
  end
end

if __FILE__ == $PROGRAM_NAME
  i = IceCreamFinder.new
  i.find_me_icecream
end

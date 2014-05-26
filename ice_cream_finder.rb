require 'nokogiri'
require 'json'
require 'addressable/uri'
require 'rest-client'

class IceCreamFinder
  attr_accessor :location, :max_distance, :shoppes
  
  def self.load_api_key
    begin
      api_key = File.read('.api_key').chomp
    rescue
      puts "Unable to read '.api_key'. Please provide a valid Google API key."
      exit
    end
  end
  
  def get_user_input
    # location = 
  end
  
  def choose_shop
    # shop = 
    
    get_directions_for(shop)
  end
  
  def get_directions_for(shop)
    
  end

  def location_to_ll
    # take @location and feed into geocoding to get ll
    # return ll
  end
end

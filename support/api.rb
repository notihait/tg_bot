require 'net/http'
require 'json'
require 'uri'

class Api
  ACCESS_KEY = ENV['WORLDWEATHERONLINE_ACCESS_KEY']
  URL = ENV['WORLDWEATHERONLINE_URL']

  def self.current_weather(city)
    uri = URI(URL)
    uri.query = URI.encode_www_form({
                                      q: city,
                                      num_of_days: 1,
                                      date: 'tomorrow',
                                      key: ACCESS_KEY,
                                      lang: 'uk',
                                      format: 'json'
                                    })
    response = Net::HTTP.get(uri)

    data = JSON.parse(response).dig('data', 'current_condition').first

    {
      wthr: data.dig('lang_uk', 0, 'value'),
      temp: data['temp_C'],
      feelslike: data['FeelsLikeC'],
      humidity: data['humidity'],
      wind: data['windspeedKmph']
    }
  end
end

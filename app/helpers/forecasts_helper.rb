module ForecastsHelper
  def display_fahrenheit(celsius_temperature)
    formatted_temp = ((celsius_temperature * 9.0 / 5.0) + 32).round
    "#{formatted_temp}°F"
  end
end

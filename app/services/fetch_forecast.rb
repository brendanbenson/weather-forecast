class FetchForecast
  # @param [GeocodingService] geocoding_service
  # @param [WeatherForecastService] weather_forecast_service
  def initialize(
    geocoding_service: GeocodingService.new,
    weather_forecast_service: WeatherForecastService.new
  )
    @geocoding_service = geocoding_service
    @weather_forecast_service = weather_forecast_service
  end

  # @param [String] address
  # @return [Forecast]
  def fetch_by_address(address:)
    location = @geocoding_service.location(address: address)
    @weather_forecast_service.forecast(location: location)
  end

  # @param [String] postal_code
  # @return [Forecast]
  def fetch_by_postal_code(postal_code:)
    location = if @weather_forecast_service.forecast_exists?(postal_code: postal_code)
                 Location.new(postal_code: postal_code)
               else
                 @geocoding_service.location(address: postal_code)
               end
    @weather_forecast_service.forecast(location: location)
  end
end

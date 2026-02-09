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
  def fetch_by_address(address)
    location = @geocoding_service.location(address)
    @weather_forecast_service.forecast(location)
  end

  # @param [String] postal_code
  # @return [Forecast]
  def fetch_by_postal_code(postal_code)
    cached_forecast = @weather_forecast_service.cached_forecast(postal_code)
    cached_forecast.presence || fetch_by_address(postal_code)
  end
end

class WeatherForecastService
  class WeatherForecastServiceError < StandardError; end

  # @param [Google::WeatherClient] client
  def initialize(client: nil)
    @client = client || Google::WeatherClient.new(
      base_url: ENV.fetch("WEATHER_API_URL"),
      api_key: ENV.fetch("GOOGLE_API_KEY")
    )
  end

  # @param [Location] location
  # @return [Forecast]
  def forecast(location:)
    key = cache_key(location.postal_code)
    forecast_is_cached = forecast_exists?(postal_code: location.postal_code)
    forecast = Rails.cache.fetch(key, expires_in: 30.minutes) { fetch_forecast(location: location) }
    # forecast = fetch_forecast(location: location)
    forecast.cached = forecast_is_cached
    forecast
  end

  # @param [String] postal_code
  def forecast_exists?(postal_code:)
    key = cache_key(postal_code)
    Rails.cache.exist?(key)
  end

  # @param [String] postal_code
  def cache_key(postal_code)
    "weather_forecast/#{postal_code}"
  end

  private

  # @param [Location] location
  def fetch_forecast(location:)
    current_conditions = fetch_current_conditions(location: location)
    current_temperature = current_conditions.dig("temperature", "degrees")
    forecast = Forecast.new(
      postal_code: location.postal_code,
      current_temperature: current_temperature,
      created_at: Time.current
    )
    raise WeatherForecastServiceError unless forecast.valid?
    forecast
  end

  # @param [Location] location
  def fetch_current_conditions(location:)
    api_response = @client.fetch_current_conditions(latitude: location.latitude, longitude: location.longitude)
    api_response.body.as_json
  end

end

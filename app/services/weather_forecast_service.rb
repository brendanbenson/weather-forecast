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
  def forecast(location)
    key = cache_key(location.postal_code)
    cached = true
    forecast = Rails.cache.fetch(key, expires_in: 30.minutes) do
      cached = false
      fetch_forecast(location: location)
    end
    forecast.cached = cached
    forecast
  end

  # @param [String] postal_code
  def cached_forecast(postal_code)
    forecast = Rails.cache.read(cache_key(postal_code))
    return nil unless forecast
    forecast.cached = true
    forecast
  end

  private

  # @param [String] postal_code
  def cache_key(postal_code)
    "weather_forecast/#{postal_code}"
  end

  # @param [Location] location
  def fetch_forecast(location:)
    current_conditions_future = Concurrent::Future.execute { fetch_current_conditions(location) }
    forecast_data_future = Concurrent::Future.execute { fetch_forecast_data(location) }
    current_conditions = current_conditions_future.value!
    forecast_data = forecast_data_future.value!
    forecast_days = forecast_days(forecast_data)
    current_temperature = current_conditions.dig("temperature", "degrees")
    forecast = Forecast.new(
      current_temperature: current_temperature,
      forecast_days: forecast_days,
      postal_code: location.postal_code,
      created_at: Time.current
    )
    raise WeatherForecastServiceError unless forecast.valid? && forecast_days.all?(&:valid?)
    forecast
  rescue Faraday::Error
    raise WeatherForecastServiceError
  end

  # @param [Location] location
  def fetch_current_conditions(location)
    api_response = @client.fetch_current_conditions(latitude: location.latitude, longitude: location.longitude)
    api_response.body.as_json
  end

  def fetch_forecast_data(location)
    api_response = @client.fetch_forecast(latitude: location.latitude, longitude: location.longitude)
    api_response.body.as_json
  end

  def forecast_days(forecast_data)
    forecast_data.dig("forecastDays")&.map do |raw_forecast_day|
      display_date = raw_forecast_day.dig("displayDate")
      ForecastDay.new(
        date: Date.new(display_date["year"], display_date["month"], display_date["day"]),
        high_temperature: raw_forecast_day.dig("maxTemperature", "degrees"),
        low_temperature: raw_forecast_day.dig("minTemperature", "degrees"),
        conditions: raw_forecast_day.dig("daytimeForecast", "weatherCondition", "description", "text")
      )
    end
  end
end

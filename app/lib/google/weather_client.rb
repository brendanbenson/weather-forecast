module Google
  class WeatherClient
    FORECAST_DAYS = 3

    # @param [String] base_url
    # @param [String] api_key
    def initialize(base_url:, api_key:)
      @base_url = base_url
      @api_key = api_key
    end

    # https://developers.google.com/maps/documentation/weather/current-conditions
    # @param [String] latitude
    # @param [String] longitude
    # @return [Faraday::Response]
    def fetch_current_conditions(latitude:, longitude:)
      connection.get do |req|
        req.url "/v1/currentConditions:lookup", key: @api_key, "location.latitude": latitude, "location.longitude": longitude
      end
    end

    # https://developers.google.com/maps/documentation/weather/daily-forecast
    # @param [String] latitude
    # @param [String] longitude
    # @return [Faraday::Response] A 5-day forecast
    def fetch_forecast(latitude:, longitude:)
      connection.get do |req|
        req.url "/v1/forecast/days:lookup", key: @api_key, "location.latitude": latitude, "location.longitude": longitude, days: FORECAST_DAYS
      end
    end

    private

    # @return [Faraday::Connection]
    def connection
      @connection ||= Faraday.new(url: @base_url) do |f|
        f.response :logger, Rails.logger, bodies: true if Rails.env.development?
        f.response :raise_error
        f.response :json
      end
    end
  end
end
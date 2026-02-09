require "test_helper"

class FetchForecastTest < ActiveSupport::TestCase
  test "#fetch_by_address gets a location and a forecast" do
    fake_location = Location.new(
      latitude: 37.332206,
      longitude: -122.0110271,
      postal_code: "95014",
      country: "US"
    )
    fake_forecast = Forecast.new(
      current_temperature: 50,
      forecast_days: [
        ForecastDay.new(
          date: Date.new(2026, 2, 8),
          high_temperature: 66,
          low_temperature: 46,
          conditions: "Mostly cloudy"
        )
      ]
    )
    mock_geocoding_service = Minitest::Mock.new
    mock_geocoding_service.expect(:location, fake_location, [ "One Apple Park Way, Cupertino, CA 95014" ])

    mock_weather_forecast_service = Minitest::Mock.new
    mock_weather_forecast_service.expect(:forecast, fake_forecast, [ fake_location ])

    fetch_forecast = FetchForecast.new(
      geocoding_service: mock_geocoding_service,
      weather_forecast_service: mock_weather_forecast_service
    )
    result = fetch_forecast.fetch_by_address("One Apple Park Way, Cupertino, CA 95014")

    assert_equal(fake_forecast, result)

    mock_geocoding_service.verify
    mock_weather_forecast_service.verify
  end
end

require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  test "GET /forecasts/new should get new" do
    get new_forecast_url
    assert_response :success
  end

  test "POST /forecasts should create forecast" do
    forecast = Forecast.new(postal_code: "95014")

    fetch_forecast_mock = Minitest::Mock.new
    fetch_forecast_mock.expect(:fetch_by_address, forecast, [], address: "One Apple Park Way, Cupertino, CA 95014")

    FetchForecast.stub(:new, fetch_forecast_mock) do
      post forecasts_path, params: { address_form: { address: "One Apple Park Way, Cupertino, CA 95014" } }
    end

    assert_redirected_to forecast_path("95014")
    fetch_forecast_mock.verify
  end

  test "POST /forecasts should show errors on invalid forecast" do
    post forecasts_path, params: { address_form: { address: "" } }

    assert_response :unprocessable_entity
  end

  test "GET /forecasts/:postal_code should show forecast" do
    forecast = Forecast.new(
      postal_code: "95014",
      current_temperature: 30,
      forecast_days: [
        ForecastDay.new(date: Date.tomorrow, high_temperature: 30, low_temperature: 20, conditions: "Partly cloudy")
      ],
      created_at: DateTime.current,
      cached: false
    )

    fetch_forecast_mock = Minitest::Mock.new
    fetch_forecast_mock.expect(:fetch_by_postal_code, forecast, [], postal_code: "95014")

    FetchForecast.stub(:new, fetch_forecast_mock) do
      get forecast_url("95014")
    end

    assert_response :success
  end
end

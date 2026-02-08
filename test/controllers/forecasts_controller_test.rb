require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @forecast = forecasts(:one)
  end

  test "should get new" do
    get new_forecast_url
    assert_response :success
  end

  test "should create forecast" do
    assert_difference("Forecast.count") do
      post forecasts_url, params: { forecast: {} }
    end

    assert_redirected_to forecast_url(Forecast.last)
  end

  test "should show forecast" do
    get forecast_url(@forecast)
    assert_response :success
  end
end

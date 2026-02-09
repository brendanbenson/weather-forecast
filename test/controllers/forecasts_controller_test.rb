require "test_helper"
require "helpers/google_api_stub_helpers"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  include GoogleApiStubHelpers

  test "GET /forecasts/new renders successfully" do
    get new_forecast_url
    assert_response :success
  end

  test "POST /forecasts creates forecast" do
    stub_successful_geocode(address: "One Apple Park Way, Cupertino, CA 95014")
    stub_successful_current_conditions(latitude: 37.332206, longitude: -122.0110271)
    stub_successful_forecast(latitude: 37.332206, longitude: -122.0110271)

    post forecasts_path, params: { address_form: { address: "One Apple Park Way, Cupertino, CA 95014" } }

    assert_redirected_to forecast_path("95014")
  end

  test "POST /forecasts shows errors on invalid forecast" do
    post forecasts_path, params: { address_form: { address: "" } }

    assert_response :unprocessable_entity
  end

  test "POST /forecasts shows errors on unsuccessful geocode" do
    stub_unsuccessful_geocode(address: "00000")

    post forecasts_path, params: { address_form: { address: "00000" } }

    assert_response :unprocessable_entity
    assert_equal "There was an error finding your address. Please try again.", flash[:alert]
  end

  test "POST /forecasts shows errors on unsuccessful current conditions" do
    stub_successful_geocode(address: "95014")
    stub_unsuccessful_current_conditions(latitude: 37.332206, longitude: -122.0110271)
    stub_successful_forecast(latitude: 37.332206, longitude: -122.0110271)

    post forecasts_path, params: { address_form: { address: "95014" } }

    assert_response :unprocessable_entity
    assert_equal "There was an error checking the weather for your location. Please try again.", flash[:alert]
  end

  test "POST /forecasts shows errors on unsuccessful forecast" do
    stub_successful_geocode(address: "95014")
    stub_successful_current_conditions(latitude: 37.332206, longitude: -122.0110271)
    stub_unsuccessful_forecast(latitude: 37.332206, longitude: -122.0110271)

    post forecasts_path, params: { address_form: { address: "95014" } }

    assert_response :unprocessable_entity
    assert_equal "There was an error checking the weather for your location. Please try again.", flash[:alert]
  end

  test "GET /forecasts/:postal_code shows forecast" do
    stub_successful_geocode(address: "95014")
    stub_successful_current_conditions(latitude: 37.332206, longitude: -122.0110271)
    stub_successful_forecast(latitude: 37.332206, longitude: -122.0110271)

    get forecast_url("95014")

    assert_response :success
  end

  test "GET /forecasts/:postal_code renders 404 when bad postal code" do
    stub_unsuccessful_geocode(address: "00000")

    get forecast_url("00000")

    assert_response :not_found
  end

  test "GET /forecasts/:postal_code renders 404 when current conditions fails" do
    stub_successful_geocode(address: "95014")
    stub_unsuccessful_current_conditions(latitude: 37.332206, longitude: -122.0110271)
    stub_successful_forecast(latitude: 37.332206, longitude: -122.0110271)

    get forecast_url("95014")

    assert_response :not_found
  end

  test "GET /forecasts/:postal_code renders 404 when forecast fails" do
    stub_successful_geocode(address: "95014")
    stub_successful_current_conditions(latitude: 37.332206, longitude: -122.0110271)
    stub_unsuccessful_forecast(latitude: 37.332206, longitude: -122.0110271)

    get forecast_url("95014")

    assert_response :not_found
  end
end

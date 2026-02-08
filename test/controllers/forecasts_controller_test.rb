require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  def stub_successful_geocode(address:)
    stub_request(:get, "https://maps.googleapis.com/maps/api/geocode/json")
      .with(query: hash_including({ "address" => address }))
      .to_return(
        body: file_fixture("geocode_95014.json").read,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_unsuccessful_geocode(address:)
    stub_request(:get, "https://maps.googleapis.com/maps/api/geocode/json")
      .with(query: hash_including({ "address" => address }))
      .to_return(
        body: file_fixture("unsuccessful_geocode_00000.json").read,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_successful_current_conditions(latitude:, longitude:)
    stub_request(:get, "https://weather.googleapis.com/v1/currentConditions:lookup")
      .with(query: hash_including({ "location.latitude" => latitude.to_s, "location.longitude" => longitude.to_s }))
      .to_return(
        body: file_fixture("current_conditions.json").read,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_unsuccessful_current_conditions(latitude:, longitude:)
    stub_request(:get, "https://weather.googleapis.com/v1/currentConditions:lookup")
      .with(query: hash_including({ "location.latitude" => latitude.to_s, "location.longitude" => longitude.to_s }))
      .to_return(
        body: file_fixture("unsuccessful_current_conditions.json").read,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_successful_forecast(latitude:, longitude:)
    stub_request(:get, "https://weather.googleapis.com/v1/forecast/days:lookup")
      .with(query: hash_including({ "location.latitude" => latitude.to_s, "location.longitude" => longitude.to_s, "days" => "3" }))
      .to_return(
        body: file_fixture("forecast.json").read,
        headers: { "Content-Type" => "application/json" }
      )
  end

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
  end

  test "POST /forecasts shows errors on unsuccessful forecast" do
    stub_successful_geocode(address: "95014")
    stub_unsuccessful_current_conditions(latitude: 37.332206, longitude: -122.0110271)
    stub_successful_forecast(latitude: 37.332206, longitude: -122.0110271)

    post forecasts_path, params: { address_form: { address: "95014" } }

    assert_response :unprocessable_entity
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

  test "GET /forecasts/:postal_code renders 404 when forecast fails" do
    stub_successful_geocode(address: "95014")
    stub_unsuccessful_current_conditions(latitude: 37.332206, longitude: -122.0110271)
    stub_successful_forecast(latitude: 37.332206, longitude: -122.0110271)

    get forecast_url("95014")

    assert_response :not_found
  end
end

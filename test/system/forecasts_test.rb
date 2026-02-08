require "application_system_test_case"
require "helpers/google_api_stub_helpers"

class ForecastsTest < ApplicationSystemTestCase
  include GoogleApiStubHelpers

  test "gets a forecast" do
    with_caching do
      stub_successful_geocode(address: "One Apple Park Way, Cupertino, CA 95014")
      stub_successful_current_conditions(latitude: 37.332206, longitude: -122.0110271)
      stub_successful_forecast(latitude: 37.332206, longitude: -122.0110271)

      visit root_url

      fill_in "Enter an address", with: "One Apple Park Way, Cupertino, CA 95014"

      click_on "Get Forecast"

      assert_text "Forecast for 95014"
      assert_text "Current temperature\n50°F"
      assert_text "Saturday\nMostly cloudy High: 66°F Low: 46°F"
      assert_text "Sunday\nPartly sunny High: 68°F Low: 47°F"
      assert_text "Monday\nCloudy High: 66°F Low: 49°F"
      assert_text "Last updated\nless than a minute ago"
      assert_text "Cached\nYes"

      click_on "Check another location"
      assert_text "Weather Forecast"
    end
  end
end

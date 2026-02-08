class GeocodingService
  class GeocodingServiceError < StandardError; end

  # @param [Google::MapsClient] client
  def initialize(client: nil)
    @client = client || Google::MapsClient.new(
      base_url: ENV.fetch("GEOCODING_API_URL"),
      api_key: ENV.fetch("GOOGLE_API_KEY")
    )
  end

  # @return [Location]
  # @param [String] address The address to be geocoded
  def location(address:)
    Rails.cache.fetch(cache_key(address), expires_in: 1.week) do
      geocode_result = @client.geocode_address(address: address).body.as_json
      result_loc = result_location(geocode_result)
      country = country(geocode_result)
      location = Location.new(
        latitude: result_loc.fetch("lat"),
        longitude: result_loc.fetch("lng"),
        postal_code: postal_code(geocode_result),
        country: country
      )
      raise GeocodingServiceError unless location.valid?
      location
    end
  end

  private

  def cache_key(address)
    "address/#{normalized_address(address)}"
  end

  def normalized_address(address)
    address.downcase.gsub(/\s+/, " ").strip
  end

  # @param [Hash] geocode_result
  # @return [String]
  def postal_code(geocode_result)
    geocode_result.dig("results", 0, "address_components")
      &.find { |component| component["types"].include?("postal_code") }&.dig("long_name")
  end

  # @param [Hash] geocode_result
  # @return [String]
  def country(geocode_result)
    geocode_result.dig("results", 0, "address_components")
      &.find { |component| component["types"].include?("country") }&.dig("short_name")
  end

  # @param [Hash] geocode_result
  # @return [Hash]
  def result_location(geocode_result)
    result = geocode_result.dig("results", 0, "geometry", "location")
    raise GeocodingServiceError if result.nil?
    result
  end
end

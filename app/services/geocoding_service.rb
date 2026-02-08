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
      result_loc = result_location(address: address)
      country = country(address: address)
      location = Location.new(
        latitude: result_loc.fetch("lat"),
        longitude: result_loc.fetch("lng"),
        postal_code: postal_code(address: address),
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

  # @param [String] address
  # @return [String]
  def postal_code(address:)
    geocoded_address(address: address).dig("results", 0, "address_components")
      &.find { |component| component["types"].include?("postal_code") }&.dig("long_name")
  end

  # @param [String] address
  # @return [String]
  def country(address:)
    geocoded_address(address: address).dig("results", 0, "address_components")
      &.find { |component| component["types"].include?("country") }&.dig("short_name")
  end

  # @param [String] address
  # @return [Hash]
  def result_location(address:)
    result = geocoded_address(address: address).dig("results", 0, "geometry", "location")
    raise GeocodingServiceError if result.nil?
    result
  end

  # @param [String] address
  def geocoded_address(address:)
    @geocoded_address ||= @client.geocode_address(address: address).body.as_json
  end
end

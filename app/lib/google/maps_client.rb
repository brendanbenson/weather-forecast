module Google
  class MapsClient
    # @param [String] base_url
    # @param [String] api_key
    def initialize(base_url:, api_key:)
      @base_url = base_url
      @api_key = api_key
    end

    # https://developers.google.com/maps/documentation/geocoding/start#geocoding-request-and-response-latitudelongitude-lookup
    # @param [String] address
    # @return [Faraday::Response]
    def geocode_address(address)
      connection.get do |req|
        req.url "/maps/api/geocode/json", address: address, key: @api_key
      end
    end

    private

    def connection
      @connection ||= Faraday.new(url: @base_url) do |f|
        f.response :logger, Rails.logger, bodies: true if Rails.env.development?
        f.response :raise_error
        f.response :json
      end
    end
  end
end
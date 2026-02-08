module GoogleApiStubHelpers
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
end
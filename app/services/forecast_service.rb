class ForecastService
  # @param [String] zip_code 5-digit zip code for which to fetch the weather forecast
  def initialize(zip_code)
    @zip_code = zip_code
  end

  # @return [Forecast]
  def forecast
    Forecast.new
  end
end

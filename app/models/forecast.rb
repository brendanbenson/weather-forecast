class Forecast
  include ActiveModel::API
  def current_temperature
    38
  end

  def zip_code
    "81435"
  end

  alias :id :zip_code
end

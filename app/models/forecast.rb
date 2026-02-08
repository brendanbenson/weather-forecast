class Forecast
  include ActiveModel::API

  attr_accessor :current_temperature, :forecast_days, :created_at, :postal_code, :cached

  alias :id :postal_code

  validates :current_temperature, presence: true
  validates :forecast_days, presence: true
  validates :postal_code, presence: true, length: { is: 5 }
end

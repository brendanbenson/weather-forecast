class ForecastDay
  include ActiveModel::API

  attr_accessor :date, :high_temperature, :low_temperature, :conditions

  validates :high_temperature, :low_temperature, :conditions, presence: true
end

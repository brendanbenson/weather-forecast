class Forecast
  include ActiveModel::API

  attr_accessor :current_temperature, :created_at, :postal_code, :cached

  validates :current_temperature, presence: true

  alias :id :postal_code
end

class Location
  include ActiveModel::API

  attr_accessor :latitude, :longitude, :postal_code, :country

  validates :postal_code, presence: true, length: { is: 5 }
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :country, presence: true, inclusion: { in: ["US"] }
end

class AddressForm
  include ActiveModel::API

  attr_accessor :address

  validates :address, presence: true, length: { minimum: 5, maximum: 255 }
end

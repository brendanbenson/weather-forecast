class ForecastsController < ApplicationController
  # GET /forecasts/new
  def new
    @address_form = AddressForm.new
  end

  # POST /forecasts
  def create
    @address_form = AddressForm.new(address_params)

    unless @address_form.valid?
      render :new, status: :unprocessable_entity and return
    end

    geocoding_service = GeocodingService.new(@address_form.address)
    redirect_to zip_code_forecast_path(geocoding_service.zip_code)
  end

  def show
  end

  private

  def address_params
    params.require(:address_form).permit(:address)
  end
end

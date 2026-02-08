class ForecastsController < ApplicationController
  # GET /forecasts/new
  def new
    @address_form = AddressForm.new
  end

  # POST /forecasts
  def create
    @address_form = AddressForm.new(address_params)
    if @address_form.valid?
      forecast = FetchForecast.new.fetch_by_address(address: @address_form.address)
      redirect_to forecast_path(forecast.id)
    else
      render :new, status: :unprocessable_entity
    end
  rescue GeocodingService::GeocodingServiceError
    flash.now[:alert] = "There was an error finding your address. Please try again."
    render :new, status: :unprocessable_entity
  rescue WeatherForecastService::WeatherForecastServiceError
    flash.now[:alert] = "There was an error checking the weather for your location. Please try again."
    render :new, status: :unprocessable_entity
  end

  def show
    @forecast = FetchForecast.new.fetch_by_postal_code(postal_code: params[:postal_code].to_s)
  rescue GeocodingService::GeocodingServiceError, WeatherForecastService::WeatherForecastServiceError
    not_found
  end

  private

  def address_params
    params.require(:address_form).permit(:address)
  end
end

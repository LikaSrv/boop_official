class AvailabilitiesController < ApplicationController

  def update
    @availability = Availability.find(params[:availability_id])
    @availability.update!(availability_params)
  end

  private

  def availability_params
    params.require(:availability).permit(:start_time, :status, :professional_id)
  end
end

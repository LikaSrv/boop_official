class SlotsController < ApplicationController
  def index
    @selected_date = params[:date]
    @professional = Professional.find(params[:id])

    start_date = params.fetch(:start_date, Date.today).to_date

    render partial: "professionals/all_slot", locals: { selected_date: @selected_date }

  end
end

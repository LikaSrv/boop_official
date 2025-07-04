class PricingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @pricings = Pricing.all.order(:created_at)
  end

  def show
    @pricing = Pricing.find(params[:id])
  end


end

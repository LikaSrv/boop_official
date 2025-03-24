class PaymentsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new ]

  def new
    @order = Order.find(params[:order_id])
  end

end

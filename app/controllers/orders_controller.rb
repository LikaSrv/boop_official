class OrdersController < ApplicationController

  def create
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    pricing = Pricing.find_by(id: params[:order][:pricing_id])
    unless pricing
      return render json: { error: "Ce pricing n'existe pas." }, status: :not_found
    end

    if pricing.stripe_price_id.blank?
      return render json: { error: "Le pricing sélectionné n’a pas de Stripe price_id associé." }, status: :unprocessable_entity
    end

    order = Order.create!(
      pricing: pricing,
      amount: pricing.price,
      state: 'pending',
      user: current_user
    )

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price: pricing.stripe_price_id,
        quantity: 1
      }],
      mode: 'subscription',
      subscription_data: {
        trial_period_days: 180 # 🎉 essai gratuit de 180 jours
      },
      success_url: order_url(order),
      cancel_url: root_url # ou une page d'échec personnalisée
    )

    order.update!(checkout_session_id: session.id)

    render json: { checkout_session_id: session.id }, status: :created

  rescue StandardError => e
    Rails.logger.error "Stripe error: #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
  end


  def show
    @order = current_user.orders.find(params[:id])
  end


end

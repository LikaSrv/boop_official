class OrdersController < ApplicationController

  def create
    Stripe.api_key = ENV['STRIPE_SECRET_KEY'] # Set the secret key

    pricing = Pricing.find(params[:order][:pricing_id])
    order = Order.create!(pricing: pricing, amount: pricing.price, state: 'pending', user: current_user)

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'eur',
          unit_amount: pricing.price_cents,
          product_data: {
            name: pricing.title,
            # images: [pricing.image_url],
          },
          recurring: { interval: 'month' } # Specify the recurring interval (e.g., 'month' or 'year')
        },
        quantity: 1
      }],
      mode: 'subscription', # Ensure mode is set to 'subscription'
      success_url: order_url(order),
      #cancel_url: new_order_payment_path(order)
    )

    order.update(checkout_session_id: session.id)

    render json: { checkout_session_id: session.id }, status: :created
rescue StandardError => e
  render json: { error: e.message }, status: :unprocessable_entity

    #redirect_to new_order_payment_path(order)
  end

  def show
    @order = current_user.orders.find(params[:id])

    # list of all specialty
    @all_specialty = [
      {
        specialty: "Vétérinaire",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/judy-beth-morris-5Bi6MWlWMbw-unsplash.jpg"
      },
      {
        specialty: "Toiletteur",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/toiletteur.jpg"
      },
      {
        specialty: "Comportementaliste",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/comportementalist.jpg"
      },
      {
        specialty: "Pension",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/pension.jpg"
      },
      {
        specialty: "Promeneur",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/promeneur.jpg"
      },
      {
        specialty: "Nutritionniste",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/nutritionniste.jpg"
      },
      {
        specialty: "Petsitter",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/petsitteur.jpg"
      }
    ]

  end


end

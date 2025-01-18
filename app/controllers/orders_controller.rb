class OrdersController < ApplicationController

  def create
    pricing = Pricing.find(params[:pricing_id])
    order  = Order.create!(pricing: pricing, amount: pricing.price, state: 'pending', user: current_user)


    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'eur',
          unit_amount: pricing.price_cents,
          product_data: {
            name: pricing.specialty,
            # images: [pricing.image_url],
          },
        },
        quantity: 1
      }],
      mode: 'payment',
      success_url: order_url(order)
      # cancel_url: new_order_payment_path(order)
    )

    order.update(checkout_session_id: session.id)
    redirect_to new_order_payment_path(order)
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
    index = @all_specialty.index { |specialty| specialty[:specialty] == @order.pricing.specialty }
    @photo = @all_specialty[index][:photo]

  end


end

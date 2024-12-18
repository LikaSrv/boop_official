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
      success_url: order_url(order),
      cancel_url: order_url(order)
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
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1733824916/judy-beth-morris-5Bi6MWlWMbw-unsplash_funbpk.jpg"
      },
      {
        specialty: "Toiletteur",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1733824916/reba-spike-PEQIIwnIGdo-unsplash_yfvjlt.jpg"
      },
      {
        specialty: "Comportementaliste",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1734359896/comportementalist_wthrkt.jpg"
      },
      {
        specialty: "Pension",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1734359894/pension_ujblqm.jpg"
      },
      {
        specialty: "Promeneur",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1733824978/development/m4vlzbcsqfd656mz4bfevhz4gybu.jpg"
      },
      {
        specialty: "Nutritionniste",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1734359894/nutritionniste_jyqrm8.jpg"
      },
      {
        specialty: "Petsitter",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1734359894/petsitter_fskzo9.jpg"
      }
    ]

    index = @all_specialty.index { |specialty| specialty[:specialty] == @order.pricing.specialty }
    @photo = @all_specialty[index][:photo]

  end


end

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="create-order"
export default class extends Controller {
  static values = {
    userId: Number,
    pricingId: Number,
    stripeKey: String
  }

  connect() {
    console.log("Stimulus connecté pour create-order");
  }

  async createOrder(event) {
    event.preventDefault();

    const button = event.currentTarget;

    const userId = this.userIdValue;
    const pricingId = this.pricingIdValue;
    const stripeKey = this.stripeKeyValue;

    console.log("Données pour la commande :", { userId, pricingId });

    try {
      const response = await fetch('/orders', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          order: {
            user_id: userId,
            pricing_id: pricingId
          }
        })
      });

      if (!response.ok) throw new Error('Erreur lors de la création de la commande');

      const data = await response.json();
      console.log("Commande créée:", data);

      const stripe = Stripe(stripeKey);

      stripe.redirectToCheckout({
        sessionId: data.checkout_session_id
      })
      .then((result) => {
        if (result.error) {
          console.error("Erreur Stripe:", result.error.message);
        }
      });
    } catch (error) {
      console.error("Erreur lors de la création de l'order:", error);
    }
  }
}

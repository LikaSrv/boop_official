import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="create-order"
export default class extends Controller {
  static values = { userId: Number, pricingId: Number, stripeKey: String }

  connect() {
    console.log("Hello, Stimulus!");
    console.log("User ID:", this.userIdValue);
    console.log("Pricing ID:", this.pricingIdValue);
    console.log("Order Payload:", {
      user_id: this.userIdValue,
      pricing_id: this.pricingIdValue
    });

    // Attacher l'événement de création de commande
    this.createOrder = this.createOrder.bind(this);
    this.createStripeCheckout = this.createStripeCheckout.bind(this);

    // Assurez-vous que le bouton Stripe est prêt
    const paymentButton = document.getElementById('pay');
    if (paymentButton) {
      paymentButton.addEventListener('click', this.createOrder);
    }
  }

  async createOrder() {
    try {
      const response = await fetch('/orders', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          order: {
            user_id: this.userIdValue,
            pricing_id: this.pricingIdValue
          }
        })
      });

      if (!response.ok) {
        throw new Error('Erreur lors de la création de la commande');
      }

      const data = await response.json();
      console.log("Commande créée:", data);

      // Une fois la commande créée, on lance Stripe
      this.createStripeCheckout(data);
    } catch (error) {
      console.error("Erreur lors de la création de l'order:", error);
    }
  }

  createStripeCheckout(orderData) {
    const paymentButton = document.getElementById('pay');
    if (!paymentButton) return;

    // Initialiser Stripe avec la clé publique
    const stripe = Stripe(this.stripeKeyValue);

    // Passer l'identifiant du sessionId et clientReferenceId
    stripe.redirectToCheckout({
      sessionId: orderData.checkout_session_id,
    })
    .then((result) => {
      if (result.error) {
        console.error("Erreur Stripe:", result.error.message);
      }
    });
  }
}

import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="autoscroll"
export default class extends Controller {
  static targets = ["autoscrollContainer"];

  connect() {
    console.log("hi");
    console.log(this.autoscrollContainerTarget);

    // Démarrer l'autoscroll une fois que le DOM est prêt
    this.startAutoScroll();
  }

  startAutoScroll() {
    let scrollAmount = 1; // Définir la vitesse de défilement

    setInterval(() => {
      const container = this.autoscrollContainerTarget;

      // Ajouter le défilement
      container.scrollLeft += scrollAmount;

      // Vérifier si on atteint la fin pour inverser le sens
      if (container.scrollLeft + container.clientWidth >= container.scrollWidth) {
        scrollAmount = -1; // Revenir en arrière
      } else if (container.scrollLeft <= 0) {
        scrollAmount = 1; // Avancer
      }
    }, 15);
  }
}

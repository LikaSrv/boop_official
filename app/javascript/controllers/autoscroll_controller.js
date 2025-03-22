import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="autoscroll"
export default class extends Controller {
  static targets = ["container"];

  connect() {
    // console.log("hi");
    // console.log(this.autoscrollContainerTarget);

    // Démarrer l'autoscroll une fois que le DOM est prêt
    this.startAutoScroll();
  }

  disconnect() {
    this.stopAutoScroll();
  }

  startAutoScroll() {
    this.interval = setInterval(() => {
      const container = this.containerTarget;

      // Scroll by a smaller amount for smoother animation
      const scrollStep = container.clientWidth / 20; // Adjust this value to control scroll speed

      if (container.scrollLeft + container.clientWidth >= container.scrollWidth) {
        // If we're at the end, scroll back to start smoothly
        container.scrollTo({ left: 0, behavior: 'smooth' });
      } else {
        // Smooth continuous scroll
        container.scrollBy({ left: scrollStep, behavior: 'smooth' });
      }
    }, 50); // Smaller interval for smoother animation
  }

  stopAutoScroll() {
    if (this.interval) {
      clearInterval(this.interval);
    }
  }

  // Pause autoscroll when user interacts with the container
  mouseEnter() {
    this.stopAutoScroll();
  }

  mouseLeave() {
    this.startAutoScroll();
  }
}

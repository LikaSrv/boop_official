import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="autoscroll"
export default class extends Controller {
  static targets = ["container"];

  connect() {
    // console.log("hi");
    // console.log(this.autoscrollContainerTarget);

    this.scrollDirection = 1; // 1 for forward, -1 for backward
    this.startAutoScroll();
  }

  disconnect() {
    this.stopAutoScroll();
  }

  startAutoScroll() {
    this.interval = setInterval(() => {
      const container = this.containerTarget;

      // Very small steps for smoother animation
      const scrollStep = container.clientWidth / 400; // Tiny step size for ultra-smooth movement
      const currentScroll = container.scrollLeft;
      const maxScroll = container.scrollWidth - container.clientWidth;

      // Check if we need to reverse direction
      if (this.scrollDirection > 0 && currentScroll >= maxScroll) {
        this.scrollDirection = -1; // Start scrolling backward
      } else if (this.scrollDirection < 0 && currentScroll <= 0) {
        this.scrollDirection = 1; // Start scrolling forward
      }

      // Apply scroll in current direction (removed 'smooth' behavior as we're already doing small steps)
      container.scrollBy({
        left: scrollStep * this.scrollDirection
      });

    }, 16); // 60fps for smooth animation
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

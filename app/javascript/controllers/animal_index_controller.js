import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="animal-index"
export default class extends Controller {

  static targets = [ "animal" ]

  connect() {
    console.log("hi");
  }

  hover(event) {
    event.currentTarget.classList.add("hovered");
  }

  unhover(event) {
    event.currentTarget.classList.remove("hovered");
  }
}

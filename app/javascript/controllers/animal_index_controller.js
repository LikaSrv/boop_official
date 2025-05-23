import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="animal-index"
export default class extends Controller {

  static targets = [ "animal" ]

  hover(event) {
    event.currentTarget.classList.add("hovered");
  }

  unhover(event) {
    event.currentTarget.classList.remove("hovered");
  }
}

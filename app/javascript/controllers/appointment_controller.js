import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="appointment"
export default class extends Controller {

  static targets = ["selectedDate"]

  highlight(event) {
    console.log("hi");

    console.log(event.currentTarget);
    event.currentTarget.classList.add("bg-white");
  }
}

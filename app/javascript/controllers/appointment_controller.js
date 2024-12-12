import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="appointment"
export default class extends Controller {

  static targets = [ "date", "times"]

  select(event) {
    console.log(this.dateTarget.innerHTML);
    console.log(event.target.dataset.time);
    this.timesTarget.classList.toggle("active");
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="appointment-selected"
export default class extends Controller {
  static targets = [ "selectedDate", "times" ]

  // Connects to data-action="click->appointment-selected#select"
  connect () {
    this.selectedDateTarget.addEventListener('click', e => {
      e.preventDefault();

      this.timesTarget.classList.toggle('d-none');
    });
  }
}

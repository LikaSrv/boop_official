import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="appointment-selected"
export default class extends Controller {
  static targets = ["selectedDate", "times"];
  static values = { apiKey: String };

  connect() {
    this.selectedDateTarget.addEventListener("click", (e) => {
      e.preventDefault();

      this.timesTarget.classList.toggle("d-none");
      this.selectedDateTarget.classList.toggle("bg-primary");
      this.selectedDateTarget.classList.toggle("text-black");
    });
  }

  confirm(event) {
    event.preventDefault();
    const selectedDate = this.selectedDateTarget.innerText.trim();
    const selectedTime = event.target.dataset.time;
    console.log(this.apiKeyValue);


    // Redirection vers la page avec les paramètres date et time
    const url = `/professionals/${this.apiKeyValue}/appointments/new?date=${encodeURIComponent(selectedDate)}&time=${encodeURIComponent(selectedTime)}`;
    window.location.href = url;
  }
}

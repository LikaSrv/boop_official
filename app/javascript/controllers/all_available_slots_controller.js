import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="all-available-slots"
export default class extends Controller {
  static targets = ["monthDates", "dayTimes"];
  static values = { apiKey: String };

  toggleMonth(event) {
    event.preventDefault();
    const monthDates = event.target.nextElementSibling;

    event.currentTarget.classList.toggle("bg-primary");
    event.currentTarget.classList.toggle("text-black");

    monthDates.classList.toggle("d-none");
  }

  toggleDate(event) {
    event.preventDefault();
    const dayTimes = event.target.nextElementSibling;

    event.currentTarget.classList.toggle("bg-primary");
    event.currentTarget.classList.toggle("text-black");

    dayTimes.classList.toggle("d-none");
  }

  confirm(event) {
    event.preventDefault();
    const selectedDate = event.target.closest(".nav-item.dropdown").querySelector("a").innerText.trim();
    const selectedTime = event.target.dataset.time;

    // Redirection vers la page avec les paramètres date et time
    const url = `/professionals/${this.apiKeyValue}/appointments/new?date=${encodeURIComponent(selectedDate)}&time=${encodeURIComponent(selectedTime)}`;
    window.location.href = url;
  }
}

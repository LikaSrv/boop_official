import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"; // You need to import this to use new flatpickr()

// Connects to data-controller="timepicker"
export default class extends Controller {
  connect() {
    console.log("Timepicker connected");

    flatpickr(this.element, {

      enableTime: true,
      noCalendar: true,
      dateFormat: "H:i",
      time_24hr: true
      
    })

  }
}

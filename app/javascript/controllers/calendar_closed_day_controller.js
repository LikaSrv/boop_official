import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"; // N'oublie pas d'importer flatpickr !

// Connects to data-controller="calendar-closed-day"
export default class extends Controller {
  connect() {
    // console.log(this.element.dataset); // Vérifie que tu as bien les bonnes données
    const closedDaysFromData = this.element.dataset.calendarClosedDayValue;
    // console.log(closedDaysFromData);

    // Si `closedDaysFromData` est une chaîne, on doit la convertir en tableau
    const closedDays = JSON.parse(closedDaysFromData).map(day => new Date(day.date).toDateString()); // Formatage des dates
    // console.log(closedDays);

    // Initialisation de flatpickr avec une référence à l'instance
    this.picker = flatpickr(this.element, {
      altInput: true,
      altFormat: "j F Y",
      dateFormat: "d-m-Y",
      minDate: Date.now(),
      disable: [
        (date) => closedDays.includes(date.toDateString()) // Désactive les jours fermés en comparant les dates au format "Date"
      ],
      locale: {
        firstDayOfWeek: 1,
        weekdays: {
          shorthand: ['Dim', 'Lun', 'MAR', 'MER', 'JEU', 'VEN', 'SAM'],
          longhand: ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'],
        },
        months: {
          shorthand: ['Jan', 'Feb', 'Mars', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Dec' ],
          longhand: ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre' ],
        },
      },
    });
  }

  openPicker() {
    if (this.picker) {
      this.picker.open(); // Ouvre le picker
    } else {
      console.error("Flatpickr instance not initialized yet.");
    }
  }
}

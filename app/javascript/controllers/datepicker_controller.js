import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"; // You need to import this to use new flatpickr()

export default class extends Controller {
  connect() {
    flatpickr(this.element, {

      altInput: true,
      altFormat: "j F Y",
      dateFormat: "d-m-Y",

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
    })
  }
}

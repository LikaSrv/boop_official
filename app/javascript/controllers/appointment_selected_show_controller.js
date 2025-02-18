import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"; // Vous devez importer flatpickr pour l'utiliser

// Connecte au data-controller="appointment-selected-show"
export default class extends Controller {
  static targets = ["selectedDate", "times"];
  static values = { apiKey: String, closed_days: Array };

  connect() {
    const closedDaysFromData = this.element.dataset.appointmentSelectedShowClosedDaysValue;
    console.log(closedDaysFromData);

    const allClosedDaysFromData = this.element.dataset.appointmentSelectedShowAllClosedDaysValue;
    console.log(allClosedDaysFromData);

    const closedDays = JSON.parse(closedDaysFromData); // Formatage des dates
    console.log(closedDays);

    const allClosedDays = JSON.parse(allClosedDaysFromData).map(day => new Date(day.date).toDateString()); // Formatage des dates
    console.log(allClosedDays);

    // Fonction pour trouver la prochaine date ouverte
    const findNextOpenDate = () => {
      let currentDate = new Date();  // Date actuelle
      // Si la date actuelle est fermée, on passe au jour suivant
      while (closedDays.includes(currentDate.getDay())) {
        currentDate.setDate(currentDate.getDate() + 1); // On avance d'un jour
      }
      return currentDate;
    };

    const nextOpenDate = findNextOpenDate();
    console.log("Prochaine date ouverte :", nextOpenDate);

    // Fonction pour définir la date maximale (3 mois à partir d'aujourd'hui)
    const maxDate = new Date();
    maxDate.setMonth(maxDate.getMonth() + 6);  // 3 mois à partir de maintenant



    // Initialisation de flatpickr sur l'élément sélectionné
    this.picker = flatpickr(this.selectedDateTarget, {
      altInput: true,
      altFormat: "j F Y",
      dateFormat: "d-m-Y",
      minDate: nextOpenDate,
      maxDate:maxDate,
      defaultDate: nextOpenDate,  // Définir la prochaine date ouverte
      disable: [
        (date) => allClosedDays.includes(date.toDateString()), // Désactive les dates spécifiques
        (date) => closedDays.includes(date.getDay()) // Désactive les jours de la semaine
      ],
      locale: {
        firstDayOfWeek: 1,
        weekdays: {
          shorthand: ['Dim', 'Lun', 'MAR', 'MER', 'JEU', 'VEN', 'SAM'],
          longhand: ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'],
        },
        months: {
          shorthand: ['Jan', 'Feb', 'Mars', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Dec'],
          longhand: ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'],
        },
      },

      onChange: (selectedDates, dateStr, instance) => {
        // Mise à jour du champ caché (selected_date) avec la date choisie
        this.selectedDateTarget.value = dateStr;  // Mets à jour le target avec la date choisie
        // console.log(this.selectedDateTarget);  // Vérification dans la console

        // Vous pouvez aussi mettre à jour `appointmentSelectedShowTarget` ici
        const turboFrame = document.getElementById("show_slots");
        // console.log(turboFrame);

        if (turboFrame) {
          turboFrame.dataset.appointmentSelectedShowTarget = dateStr;  // Met à jour l'attribut data-appointment-selected-show-target
          // console.log(turboFrame.dataset.appointmentSelectedShowTarget);  // Affiche la valeur de data-appointment-selected-show-target
        }
        this.updateSlots(dateStr);
      }
    });
  }

  openPicker() {
    this.selectedDateTarget.focus();
    this.picker.open();
  }

  updateSlots(dateStr) {
    fetch(`/professionals/${this.apiKeyValue}/update_slots?selected_date=${encodeURIComponent(dateStr)}`)
      .then(response => response.text())
      .then(html => {
        // Mettez à jour le contenu du turbo-frame avec le HTML renvoyé
        const turboFrame = document.getElementById("show_slots");
        turboFrame.innerHTML = html;  // Injecte la nouvelle vue
      })
      .catch(error => console.error('Erreur lors de la mise à jour des créneaux :', error));
  }


  confirm(event) {
    event.preventDefault();
    console.log(this.selectedDateTarget);

    const selectedDate = this.selectedDateTarget.value;
    const selectedTime = event.target.dataset.time;
    console.log(this.apiKeyValue);
    console.log(selectedDate);
    console.log(selectedTime);


    // Redirection vers la page avec les paramètres date et time
    const url = `/professionals/${this.apiKeyValue}/appointments/new?date=${encodeURIComponent(selectedDate)}&time=${encodeURIComponent(selectedTime)}`;
    window.location.href = url;
  }
}

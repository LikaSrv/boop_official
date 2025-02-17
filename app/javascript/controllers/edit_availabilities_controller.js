import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"; // Vous devez importer flatpickr pour l'utiliser

// Connects to data-controller="edit-availabilities"
export default class extends Controller {
  static targets = ["day", "time", "selectedDate", "times"];
  static values = {
    apiKey: String,
    icon: String,
    alertTitle: String,
    alertHtml: String,
    confirmButtonText: String,
    confirmButtonColor: String,
    closed_days: Array
  };
  selectedDate = null;

  connect() {
    console.log(this.element.dataset);

    const closedDaysFromData = this.element.dataset.editAvailabilitiesClosedDaysValue;
    console.log(closedDaysFromData);

    // Si `closedDaysFromData` est une chaîne, on doit la convertir en tableau
    const closedDays = JSON.parse(closedDaysFromData);
    console.log(closedDays);

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
      maxDate: maxDate,
      defaultDate: nextOpenDate,  // Définir la prochaine date ouverte
      disable: [
        (date) => closedDays.includes(date.getDay()) // Désactive les jours fermés
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
        const turboFrame = document.getElementById("edit_slots");
        // console.log(turboFrame);

        if (turboFrame) {
          turboFrame.dataset.editAvailabilitiesTarget = dateStr;  // Met à jour l'attribut data-appointment-selected-show-target
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
    fetch(`/professionals/${this.apiKeyValue}/update_edit_slots?selected_date=${encodeURIComponent(dateStr)}`)
      .then(response => response.text())
      .then(html => {
        // Mettez à jour le contenu du turbo-frame avec le HTML renvoyé
        const turboFrame = document.getElementById("edit_slots");
        turboFrame.innerHTML = html;  // Injecte la nouvelle vue
      })
      .catch(error => console.error('Erreur lors de la mise à jour des créneaux :', error));
  }

  initSweetalert(event) {
    event.preventDefault(); // Prevent the form to be submited after the submit button has been clicked

    Swal.fire({
      icon: this.iconValue,
      title: this.TitleValue || "Félicitation!",
      html: this.HtmlValue || "Le rendez-vous a bien été confirmé!",
      confirmButtonText: this.confirmButtonTextValue || "Voir les détails",
      confirmButtonColor: this.confirmButtonColorValue || '#EFA690',
      didOpen: () => {
        confetti({
          particleCount: 100,
          spread: 70,
          origin: { y: 0.6 },
        });
      }
    }).then((action) => {
      if (action.isConfirmed) {
        event.target.submit();
      }
    })
  }

  showDays(event) {
    event.preventDefault();
    const month = event.target.nextElementSibling;

    event.currentTarget.classList.toggle("bg-primary");
    event.currentTarget.classList.toggle("text-black");

    month.classList.toggle("d-none");
  }

  showTimes(event) {
    event.preventDefault();
    const day = event.target.nextElementSibling;

    event.currentTarget.classList.toggle("bg-primary");
    event.currentTarget.classList.toggle("text-black");

    day.classList.toggle("d-none");
  }

  showOptions(event) {
    event.preventDefault();

    // console.log(event.target.dataset);
    const selectedTime = event.target.dataset.time;
    const selectedDate = event.target.dataset.date;
    // console.log(selectedDate);

    const professionalId = event.target.dataset.professionalId;
    const interval = event.target.dataset.professionalInterval;

    // Fusionner la date et l'heure en une chaîne sous le format "YYYY-MM-DD HH:MM"
    const dateTimeString = `${selectedDate} ${selectedTime}`;

    // Créer un objet Date à partir de cette chaîne
    const start_time = new Date(dateTimeString);
    // console.log("Objet Date : ", start_time);


    // Calculer end_time en ajoutant l'intervalle à start_time
    const end_time = new Date(start_time);  // Copie de startTime pour ne pas modifier l'original
    end_time.setMinutes(start_time.getMinutes() + interval);
    // console.log(end_time);

    // Vérifier si la closing hour existe déjà
    const params = new URLSearchParams({
      professional_id: professionalId,
      start_time: start_time.toISOString(),  // Convertir en ISO string
      end_time: end_time.toISOString(),  // Convertir en ISO string
    });

    const slot = event.target;
    console.log(slot);

    Swal.fire({
      title: "Changer ma disponibilité",
      text: "Souhaitez-vous changer votre disponibilité ?",
      icon: "warning",
      showCancelButton: true,
      cancelButtonColor: "#0E0000",
      cancelButtonText: "Annuler",
      confirmButtonText: "Oui",
      confirmButtonColor: '#EFA690'
    }).then((result) => {
      if (result.isConfirmed) {
        console.log("bloquer/débloquer un créneau");
        fetch(`/closing_hours/check?${params.toString()}`, {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
            Accept: "application/json",
          }
        }).then((response) => {
          console.log(response);

          if (!response.ok) {
            throw new Error("Erreur lors de l'envoi des données.");
          }
          return response.json(); // Récupère la réponse en tant que texte brut
        }).then(data => {
          // console.log(data);
          // console.log(data.exists);

          if (data.exists) {
            // console.log('data exists');

            // Supprimer la closing hour existante
            fetch(`/closing_hours/${data.id}`, {
              method: "DELETE",
              headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                Accept: "application/json",
              },
            })
              .then((response) => {
                if (!response.ok) {
                  throw new Error("Erreur lors de la suppression de la closing hour.");
                }
                return response.text();  // Récupère la réponse en tant que texte brut
              })
              .then(() => {
                //get the slot dom


                slot.classList.remove("btn-outline-dark");
                slot.classList.add("btn-outline-primary");


                Swal.fire({
                  title: "La disponibilité a bien été supprimée",
                  icon: "success",
                  confirmButtonColor: '#EFA690'
                });
              })
              .catch((error) => {
                Swal.fire("Erreur", "Impossible de supprimer la closing hour", "error");
                console.error("Erreur :", error);
              });

          } else {
            fetch("/closing_hours", {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                Accept: "application/json",
              },
              body: JSON.stringify({
                closing_hour: {
                  professional_id: professionalId,
                  start_time: start_time,
                  end_time: end_time,
                },
              }),
            }).then((response) => {
              if (!response.ok) {
                throw new Error("Erreur lors de l'envoi des données.");
              }
              return response.text(); // Récupère la réponse en tant que texte brut
            })
              .then((data) => {
                console.log("Réponse JSON :", data);

                slot.classList.add("btn-outline-dark");
                slot.classList.remove("btn-outline-primary");

                console.log(slot);

                Swal.fire({
                  title: "La disponibilité a bien été modifiée",
                  icon: "success",
                  confirmButtonColor: '#EFA690'
                });
              })
              .catch((error) => {
                Swal.fire("Erreur", "Impossible de modifier le statut de l'annonce", "error");
                console.error("Erreur :", error);
              });
          }
        });
      }

    });

  }
}

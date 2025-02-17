import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-availabilities"
export default class extends Controller {
  static targets = ["day", "time"];
  static values = {
    apiKey: String,
    icon: String,
    alertTitle: String,
    alertHtml: String,
    confirmButtonText: String,
    confirmButtonColor: String,
  };
  selectedDate = null;

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

  showTimes(event) {
    event.preventDefault();
    const day = event.target.nextElementSibling;

    this.selectedDate = event.currentTarget.innerText;
    // console.log("Date sélectionnée : ", this.selectedDate);

    event.currentTarget.classList.toggle("bg-primary");
    event.currentTarget.classList.toggle("text-black");

    day.classList.toggle("d-none");
  }

  showOptions(event) {
    event.preventDefault();

    // console.log(event.target.dataset);
    const selectedTime = event.target.dataset.time;
    const professionalId = event.target.dataset.professionalId;
    const interval = event.target.dataset.professionalInterval;

    // Fusionner la date et l'heure en une chaîne sous le format "YYYY-MM-DD HH:MM"
    const dateTimeString = `${this.selectedDate.split('-').reverse().join('-')} ${selectedTime}`;

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

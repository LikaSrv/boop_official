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

    event.currentTarget.classList.toggle("bg-primary");
    event.currentTarget.classList.toggle("text-black");

    day.classList.toggle("d-none");
  }

  toggleTime(event) {
    event.preventDefault();

    const professionalId = this.element.dataset.professionalId;
    console.log("Professional ID:", professionalId);
    const availabilityId = this.element.dataset.availabilityId;
    console.log("Availability ID:", availabilityId);
    const current_status = event.currentTarget.dataset.status;
    console.log("Current status:", current_status);

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

        // Envoi des données au serveur Rails via Fetch POST
        fetch(`/professionals/${professionalId}/update_availibilities/${availabilityId}`, {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
            Accept: "application/json",
          },
          body: JSON.stringify({
            availability: {
              status: !current_status,
            },
          }),
        })
          .then((response) => {
            if (!response.ok) {
              throw new Error("Erreur lors de l'envoi des données.");
            }
            return response.text(); // Récupère la réponse en tant que texte brut
          })
          .then((data) => {
            console.log("Réponse JSON :", data);

            // Mettez à jour dynamiquement le DOM ici
            const statusElement = document.querySelector(`[data-availability-id="${availabilityId}"]`);
            console.log("Status Element:", statusElement);

            if (statusElement) {
              statusElement.classList.toggle("btn-outline-dark");
              statusElement.classList.toggle("btn-outline-primary");
            }

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

}

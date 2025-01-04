import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  static values = {
    icon: String,
    alertTitle: String,
    alertHtml: String,
    confirmButtonText: String,
    confirmButtonColor: String,
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

  // add review alert
  reviewSweetalert(event) {
    event.preventDefault();

    let starRating = 0; // Variable pour stocker les étoiles

    // SweetAlert2 avec étoiles et champ commentaire
    Swal.fire({
      title: "Donnez votre avis",
      html: `
        <div id="star-rating" style="margin-bottom: 10px;">
          <i class="fa-solid fa-star" data-value="1"></i>
          <i class="fa-solid fa-star" data-value="2"></i>
          <i class="fa-solid fa-star" data-value="3"></i>
          <i class="fa-solid fa-star" data-value="4"></i>
          <i class="fa-solid fa-star" data-value="5"></i>
        </div>
        <textarea id="review-text" placeholder="Écrivez votre commentaire ici..." rows="4" style="width: 100%;"></textarea>
      `,
      showCancelButton: true,
      confirmButtonText: "Envoyer",
      preConfirm: () => {
        const reviewText = document.getElementById("review-text").value;
        if (starRating === 0 || !reviewText) {
          Swal.showValidationMessage("Veuillez donner une note et écrire un commentaire.");
        }
        return { rating: starRating, content: reviewText };
      },
      didOpen: () => {
        // Gestion des étoiles interactives
        const stars = document.querySelectorAll("#star-rating .fa-star");
        stars.forEach((star) => {
          star.addEventListener("click", () => {
            starRating = parseInt(star.getAttribute("data-value"));
            stars.forEach((s, index) => {
              s.style.color = index < starRating ? "gold" : "lightgray";
            });
          });
        });
      },
    }).then((result) => {
      if (result.isConfirmed) {
        // Envoi des données au serveur Rails via Fetch POST
        fetch(this.buildUrl(), {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          },
          body: JSON.stringify({
            review: {
              rating: result.value.rating,
              content: result.value.content,
            },
          }),
        })
          .then((response) => {
            if (!response.ok) throw new Error("Erreur lors de l'envoi des données.");
            return response.json();
          })
          .then((data) => {
            Swal.fire("Merci pour votre avis !", "", "success");
            console.log("Réponse du serveur :", data);
            this.addReviewToPage(data.review); // Appelle une fonction pour ajouter l'avis
          })
          .catch((error) => {
            Swal.fire("Erreur", "Impossible d'envoyer votre avis.", "error");
            console.error("Erreur :", error);
          });
      }
    });
  }

  // Construire l'URL pour l'envoi POST
  buildUrl() {
    const professionalId = this.element.dataset.professionalId;
    return `/professionals/${professionalId}/reviews`;
  }


  // Add review to the page without actulisating the page
  addReviewToPage(review) {
    const reviewsContainer = document.getElementById("reviews-container");

    if (reviewsContainer) {
      // Crée dynamiquement un nouvel avis
      const reviewElement = document.createElement("div");
      reviewElement.classList.add("border-bottom", "mt-2");
      reviewElement.style.width = "100%";
      reviewElement.innerHTML = `
        <div class="d-flex flex-row justify-content-between">
          <p> ${review.user.first_name} ${review.user.last_name}</p>
          <p> ${review.rating} / 5</p>
        </div>
          <p> ${review.content} </p>
      `;

      // Ajoute le nouvel avis au conteneur
      reviewsContainer.appendChild(reviewElement);
    } else {
      console.error("L'élément #reviews-container est introuvable dans le DOM.");
    }
  }


  // alert when user is not connected yet
  notConnectedSweetalert(event) {
    event.preventDefault();

    Swal.fire({
      icon: "error",
      title: "Veuillez vous connecter pour donner votre avis",
      confirmButtonText: "Se connecter",
      confirmButtonColor: '#EFA690',
    }).then((action) => {
      if (action.isConfirmed) {
        window.location = "/users/sign_in";
      }
    })
  }

  // add vaccination
  addVaccination(event) {
    event.preventDefault();

    Swal.fire({
      title: "Ajouter un vaccin",
      // <label for="vaccineName" class="form-label">Nom du vaccin</label>
      html: `
        <div class="mb-3">
          <input type="text" id="vaccineName" class="form-control" placeholder="Entrez le nom du vaccin">
        </div>
        <div class="mb-3 text-start">
          <label for="administrationDate" class="form-label ">Date d'administration</label>
          <input type="date" id="administrationDate" class="form-control">
        </div>
        <div class="mb-3 text-start">
          <label for="nextBoosterDate" class="form-label ">Date de prochaine administration</label>
          <input type="date" id="nextBoosterDate" class="form-control">
        </div>
      `,
      focusConfirm: false,
      confirmButtonText: "Enregistrer",
      cancelButtonText: "Annuler", // Personnalise le texte du bouton "Annuler"
      showCancelButton: true,
      customClass: {
        confirmButton: "btn btn-primary", // Classe Bootstrap ou CSS personnalisée
        cancelButton: "btn btn-body-color", // Classe pour le bouton "Annuler"
      },
      preConfirm: () => {
        const vaccineName = document.getElementById("vaccineName").value;
        const administrationDate = document.getElementById("administrationDate").value;
        const nextBoosterDate = document.getElementById("nextBoosterDate").value;

        if (!vaccineName || !administrationDate || !nextBoosterDate) {
          Swal.showValidationMessage("Tous les champs sont obligatoires !");
          return false; // Empêche la fermeture si validation échoue
        }

        return { vaccineName, administrationDate, nextBoosterDate };
      },
    }).then((result) => {
      if (result.isConfirmed) {
        // Envoi des données au serveur Rails via Fetch POST
        fetch(`/pets/${this.element.dataset.petId}/vaccinations`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          },
          body: JSON.stringify({
            vaccination:{
              name: result.value.vaccineName,
              administration_date: result.value.administrationDate,
              next_booster_date: result.value.nextBoosterDate
            },
          }),
        })
        .then((response) => {
          if (!response.ok) throw new Error("Erreur lors de l'envoi des données.");
          return response.json();
        })
        .then((data) => {
          Swal.fire("Le vaccin a été ajouté", "", "success");
          console.log("Réponse du serveur :", data);
          this.addVaccinToPage(data.vaccination); // Appelle une fonction pour ajouter l'avis
        })
        .catch((error) => {
          Swal.fire("Erreur", "Impossible d'enregistrer les données.", "error");
          console.error("Erreur :", error);
        });
      }
    });
  }

  // Add vaccination to the page without actulisating the page
  addVaccinToPage(vaccin) {
    const vaccinsContainer = document.getElementById("vaccins-container");
    // console.log("hi");

    // console.log(Array.from(vaccinsContainer.children).length + 1);
    if (vaccinsContainer) {
      // Crée dynamiquement une nouvelle vaccination
      const vaccinElement = document.createElement("div");
      // Initialisation de la date d'aujourd'hui pour la comparaison
      const today = new Date().toISOString().split("T")[0];  // Format YYYY-MM-DD

      vaccinElement.innerHTML = `
      <div class="d-flex flex-row">
        <p>${Array.from(vaccinsContainer.children).length + 1}.</p>
      <div class="mx-2">
          <p>Nom de vaccin : <strong>${vaccin.name}</strong></p>
          <p>Date d'administration : ${vaccin.administration_date}</p>
          <div class="d-flex flex-row">
            <p>Prochaine date d'injection : </p>
            <p class="mx-2 ${new Date(vaccin.next_booster_date) > new Date(today) ? 'text-success' : 'text-danger'}">
              ${vaccin.next_booster_date}
            </p>
          </div>
        </div>
      </div>
      `;

      // Ajoute la nouvelle vaccination au conteneur
      vaccinsContainer.appendChild(vaccinElement);
    } else {
      console.error("L'élément #vaccins-container est introuvable dans le DOM.");
    }
  }

  // add weight history
  addWeight(event) {
    event.preventDefault();

    Swal.fire({
      title: "Ajouter une historique de poids",
      html: `
        <div class="d-flex flex-row justify-content-between my-4">
          <div class="mb-3 text-start">
            <label for="weight" class="form-label ">Le poids (en kg)</label>
            <input type="text" id="weight" class="form-control" placeholder="Saisir le poids">
          </div>
          <div class="mb-3 text-start">
            <label for="date" class="form-label ">Date de pesée</label>
            <input type="date" id="date" class="form-control">
          </div>
        </div>
      `,
      focusConfirm: false,
      confirmButtonText: "Enregistrer",
      cancelButtonText: "Annuler", // Personnalise le texte du bouton "Annuler"
      showCancelButton: true,
      customClass: {
        confirmButton: "btn btn-primary", // Classe Bootstrap ou CSS personnalisée
        cancelButton: "btn btn-body-color", // Classe pour le bouton "Annuler"
      },
      preConfirm: () => {
        const weight = document.getElementById("weight").value;
        const date = document.getElementById("date").value;

        if (!weight || !date) {
          Swal.showValidationMessage("Tous les champs sont obligatoires !");
          return false; // Empêche la fermeture si validation échoue
        }

        return { weight, date };
      },
    }).then((result) => {
      if (result.isConfirmed) {

        // Envoi des données au serveur Rails via Fetch POST
        fetch(`/pets/${this.element.dataset.petId}/weight_histories`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          },
          body: JSON.stringify({
            weight_history:{
              weight: result.value.weight,
              date: result.value.date,
            },
          }),
        })
        .then((response) => {
          if (!response.ok) throw new Error("Erreur lors de l'envoi des données.");
          return response.json();
        })
        .then((data) => {
          // Appelle le contrôleur Chart pour ajouter le poids localement
          this.application
            .getControllerForElementAndIdentifier(document.querySelector('[data-controller="chart"]'), "chart")
            .addWeight(data.weight_history.weight, data.weight_history.date);

          Swal.fire("Poids ajouté !", "", "success");
        })
        .catch((error) => {
          Swal.fire("Erreur", "Impossible d'enregistrer les données.", "error");
          console.error("Erreur :", error);
        });
      }
    });
  }

}

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

}

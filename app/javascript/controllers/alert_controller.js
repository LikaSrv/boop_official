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
            vaccination: {
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

      // Reconstruire le contenu HTML de la vaccination
      vaccinElement.innerHTML = `
    <div class="card_pro m-1 text-start d-flex flex-row vaccination-item" style="background-color: #f7e6d4;">
      <div class="mx-2">
        <p class="vaccin-name">Nom de vaccin : <strong>${vaccin.name}</strong></p>
        <p class="vaccin-administration-date">Date d'administration : ${vaccin.administration_date}</p>
        <div class="d-flex flex-row">
          <p>Prochaine date d'injection : </p>
          <p class="mx-2 ${new Date(vaccin.next_booster_date) > new Date() ? 'text-success' : 'text-danger'} vaccin-next-booster-date">
            ${vaccin.next_booster_date}
          </p>
        </div>
      </div>
      <div class="d-flex flex-column justify-content-around">
        <a href="#" style="font-size: 12px;"
          data-controller="alert"
          data-action="click->alert#editVaccination"
          data-pet-id="${vaccin.pet_id}"
          data-vaccin-id="${vaccin.id}"
          data-vaccin-name="${vaccin.name}"
          data-administration-date="${vaccin.administration_date}"
          data-next-booster-date="${vaccin.next_booster_date}">
          <i class="fa-solid fa-edit float-end text-primary bg-light shadow myCircleIcon p-3 hoveredCircleButton"></i>
        </a>
        <a href="#" class="hoveredCircleButton my-2" style="font-size: 12px;"
          data-controller="alert"
          data-action="click->alert#deleteVaccination"
          data-pet-id="${vaccin.pet_id}"
          data-vaccin-id="${vaccin.id}">
          <i class="fa-solid fa-trash float-end text-danger bg-light shadow myCircleIcon p-3 hoveredCircleButton"></i>
        </a>
      </div>
  </div>
  `;

      // Ajoute la nouvelle vaccination au conteneur
      vaccinsContainer.appendChild(vaccinElement);
    } else {
      console.error("L'élément #vaccins-container est introuvable dans le DOM.");
    }
  }

  // Delete vaccination
  deleteVaccination(event) {
    event.preventDefault();

    console.log("Current target:", event.currentTarget);
    const vaccinId = event.currentTarget.dataset.vaccinId;
    console.log("vaccinId:", vaccinId);

    Swal.fire({
      title: "Êtes-vous sûr de vouloir supprimer?",
      text: "Vous ne pourrez pas revenir en arrière!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#3085d6",
      cancelButtonColor: "#d33",
      confirmButtonText: "Oui supprimer!",
      cancelButtonText: "Annuler",
    }).then((result) => {
      if (result.isConfirmed) {
        // Envoi de la requête DELETE
        fetch(`/pets/${this.element.dataset.petId}/vaccinations/${vaccinId}`, {
          method: "DELETE",
          headers: {
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          },
        })
          .then((response) => {
            if (!response.ok) throw new Error("Erreur lors de la suppression du vaccin.");
            return response.json();
          })
          .then(() => {
            Swal.fire({
              title: "Supprimé !",
              text: "Le vaccin a été enlevé du carnet de santé.",
              icon: "success",
            });

            // Supprimer l'élément du DOM (optionnel)
            const vaccinationElement = event.target.closest(".vaccination-item"); // Modifier selon votre structure HTML
            if (vaccinationElement) vaccinationElement.remove();
          })
          .catch((error) => {
            console.error("Erreur :", error);
            Swal.fire({
              title: "Erreur",
              text: "Une erreur est survenue lors de la suppression.",
              icon: "error",
            });
          });
      }
    });
  }

  // Edit vaccination
  editVaccination(event) {
    event.preventDefault();

    const vaccinId = event.currentTarget.dataset.vaccinId;
    const vaccinName = event.currentTarget.dataset.vaccinName;
    const administrationDate = event.currentTarget.dataset.administrationdate.replace(/"/g, '');
    const nextBoosterDate = event.currentTarget.dataset.nextboosterdate.replace(/"/g, '');
    console.log("Current target:", event.currentTarget);

    console.log("vaccinId:", vaccinId);
    console.log("vaccinName:", vaccinName);
    console.log("administrationDate:", administrationDate);
    console.log("nextBoosterDate:", nextBoosterDate);



    Swal.fire({
      title: "Modifier les informations d'un vaccin",
      // <label for="vaccineName" class="form-label">Nom du vaccin</label>
      html: `
        <div class="mb-3">
          <input type="text" id="vaccineName" class="form-control" value="${vaccinName}">
        </div>
        <div class="mb-3 text-start">
          <label for="administrationDate" class="form-label ">Date d'administration</label>
          <input type="date" id="administrationDate" class="form-control" value="${administrationDate}">
        </div>
        <div class="mb-3 text-start">
          <label for="nextBoosterDate" class="form-label ">Date de prochaine administration</label>
          <input type="date" id="nextBoosterDate" class="form-control" value="${nextBoosterDate}">
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
      didOpen: () => {
        // S'assurer que les dates sont bien pré-remplies avec les bonnes valeurs
        document.getElementById("administrationDate").value = administrationDate;
        document.getElementById("nextBoosterDate").value = nextBoosterDate;
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
        fetch(`/pets/${this.element.dataset.petId}/vaccinations/${vaccinId}`, {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          },
          body: JSON.stringify({
            vaccination: {
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
            Swal.fire("Le vaccin a été modifié", "", "success");
            console.log("Réponse du serveur :", data);
            // Mettre à jour l'élément dans le DOM
            this.updateVaccinationInPage(data.vaccination);
          })
          .catch((error) => {
            Swal.fire("Erreur", "Impossible d'enregistrer les données.", "error");
            console.error("Erreur :", error);
          });
      }
    });

  }

  // Fonction pour mettre à jour la vaccination dans le DOM sans recharger la page
  updateVaccinationInPage(vaccin) {
    // Sélectionne l'élément correspondant à la vaccination modifiée
    const vaccinElement = document.querySelector('.vaccination-item');
    console.log("vaccinElement:", vaccinElement);


    // Mettre à jour le nom, la date d'administration et la date de la prochaine injection

    vaccinElement.querySelector('.vaccin-name').innerText = vaccin.name;
    vaccinElement.querySelector('.vaccin-administration-date').innerText = vaccin.administration_date.strftime("%d-%m-%Y");
    vaccinElement.querySelector('.vaccin-next-booster-date').innerText = vaccin.next_booster_date.strftime("%d-%m-%Y");
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
            weight_history: {
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

  //Add Pet
  addPet(event) {
    event.preventDefault();

    Swal.fire({
      title: "Ajouter un animal de compagnie",
      html: `
          <div class="d-flex flex-column justify-content-between my-4">
            <div class="mb-3 text-start">
              <label for="name" class="form-label ">Nom : </label>
              <input type="text" id="name" class="form-control" placeholder="Saisir son nom">
            </div>
            <div class="mb-3 text-start">
              <label for="species" class="form-label ">Espèce : </label>
              <input type="text" id="species" class="form-control"  placeholder="Chien, Chat, etc.">
            </div>
          </div>
        `,
      focusConfirm: false,
      confirmButtonText: "Enregistrer",
      cancelButtonText: "Annuler",
      showCancelButton: true,
      customClass: {
        confirmButton: "btn btn-primary",
        cancelButton: "btn btn-body-color",
      },
      preConfirm: () => {
        const name = document.getElementById("name").value;
        const species = document.getElementById("species").value;

        if (!name || !species) {
          Swal.showValidationMessage("Tous les champs sont obligatoires !");
          return false;
        }

        return { name, species };
      },
    }).then((result) => {
      if (result.isConfirmed) {
        const userId = this.element.dataset.alertUserId;

        // Envoi des données au serveur Rails via Fetch POST
        fetch(`/users/${userId}/pets`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
            'Accept': 'application/json',
          },
          body: JSON.stringify({
            pet: {
              name: result.value.name,
              species: result.value.species,
            },
          }),
        })
          .then((response) => {
            if (!response.ok) throw new Error("Erreur lors de l'envoi des données.");
            return response.json();
          })
          .then((data) => {
            Swal.fire({
              icon: "success",
              title: "Succès",
              text: "L'animal a bien été créé !",
              confirmButtonText: "OK",
            }).then(() => {
              // Si c'est via SweetAlert, on recharge la page
              window.location.reload();
            });
          })
          .catch((error) => {
            Swal.fire("Erreur", "Impossible d'envoyer votre avis.", "error");
            console.error("Erreur :", error);
          });
      }
    });
  }

  // Delete pet
  deletePet(event) {
    event.preventDefault();

    const userId = event.currentTarget.dataset.userId;
    console.log("user id:", userId);
    console.log("pet id:", this.element.dataset.petId);

    Swal.fire({
      title: "Êtes-vous sûr de vouloir supprimer?",
      text: "Vous ne pourrez pas revenir en arrière!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#EFA690",
      cancelButtonColor: "#0E0000",
      confirmButtonText: "Oui supprimer!",
      cancelButtonText: "Annuler",
    }).then((result) => {
      if (result.isConfirmed) {
        // Envoi de la requête DELETE
        fetch(`/users/${userId}/pets/${this.element.dataset.petId}`, {
          method: "DELETE",
          headers: {
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          },
        })
          .then((response) => {
            // Vérifiez si la réponse est OK (et a un corps si besoin)
            if (response.ok) {
              if (response.status === 204) {
                Swal.fire({
                  title: "Supprimé !",
                  text: "L'animal a été enlevé.",
                  icon: "success",
                }).then(() => {
                  window.location.href = `/users/${userId}`;  // Redirige
                });
              } else {
                return response.json(); // Convertir la réponse en JSON si elle n'est pas vide
              }
            } else {
              throw new Error("Erreur lors de la suppression.");
            }
          })
          .then((data) => {
            if (data) {
              Swal.fire({
                title: "Supprimé !",
                text: data.message || "L'animal a été enlevé.",
                icon: "success",
              });
            }
          })
          .catch((error) => {
            console.error("Erreur :", error);
            Swal.fire({
              title: "Erreur",
              text: "Une erreur est survenue lors de la suppression.",
              icon: "error",
            });
          });
      }
    });

  }

  // Duplicate a professional profile
  duplicateProfil(event) {
    event.preventDefault();

    const { value: capacity } = Swal.fire({
      title: "Nombre de profils",
      input: "select",
      inputOptions: {
        1: "1 profil",
        2: "2 profils",
        3: "3 profils",
        4: "4 profils",
        5: "5 profils",
        6: "6 profils",
        7: "7 profils",
        8: "8 profils",
        9: "9 profils",
        10: "10 profils"
      },
      inputLabel: "Indiquer le nombre de profils que vous souhaitez dupliquer",
      inputPlaceholder: "Nombre de profil",
      confirmButtonText: "Enregistrer",
      customClass: {
        confirmButton: "btn btn-primary", // Classe Bootstrap ou CSS personnalisée
        cancelButton: "btn btn-body-color", // Classe pour le bouton "Annuler"
      },
    }).then(async (result) => {
      if (result.isConfirmed && result.value) {
        const capacity = parseInt(result.value, 10);

        // Montre un message de chargement
        Swal.fire({
          title: "Duplication en cours...",
          allowOutsideClick: false,
          didOpen: () => {
            Swal.showLoading();
          }
        });

        try {
          // Appelle le backend pour chaque duplication
          const professionalId = this.element.dataset.alertProfessionalId;
          const userId = this.element.dataset.alertUserId;
          console.log("Professional ID:", professionalId);
          console.log(this.element.dataset.alertUserId);
          console.log("User ID:", userId);

          for (let i = 0; i < capacity; i++) {
            await fetch('/professionals/duplicate', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
              },
              body: JSON.stringify({
                professional_id: professionalId, // ID du profil à dupliquer
              }),
            });
          }

          // Succès
          Swal.fire({
            icon: "success",
            title: `${capacity} profil(s) dupliqué(s) avec succès !`,
          });

          // Redirige la page
          window.location.replace(`/users/${userId}/professionals`);
        } catch (error) {
          // Gère les erreurs
          Swal.fire({
            icon: "error",
            title: "Erreur lors de la duplication",
            text: "Veuillez réessayer.",
          });
          console.error("Erreur de duplication:", error);
        }
      }
    });
    if (capacity) {
      Swal.fire(`Indiquez le nombre de profil à dupliquer: ${capacity}`);
    }
  }

  // Pet alert when the problem is solved
  petAlertSolved(event) {
    event.preventDefault();

    const pet_alert_id = this.element.dataset.petAlertId;
    const current_status = event.currentTarget.dataset.status === "true";
    console.log("Current status:", current_status);

    if (!current_status) {

      Swal.fire({
        title: "Le problème de cette annonce est résolu !",
        icon: "success",
        confirmButtonColor: '#EFA690'
      }).then((result) => {
        if (result.isConfirmed) {
          // Envoi des données au serveur Rails via Fetch POST
          fetch(`/pet_alerts/${pet_alert_id}`, {
            method: "PATCH",
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
              Accept: "application/json",
            },
            body: JSON.stringify({
              pet_alert: {
                status: true,
              },
            }),
          })
            .then((response) => {
              if (!response.ok) {
                throw new Error("Erreur lors de l'envoi des données.");
              }
              return response.text(); // Récupère la réponse en tant que texte brut
            })
            .then((text) => {
              const data = text ? JSON.parse(text) : {}; // Parse uniquement si du contenu existe
              console.log("Réponse JSON :", data);
              window.location.reload();
            })
            .catch((error) => {
              Swal.fire("Erreur", "Impossible de modifier le statut de l'annonce", "error");
              console.error("Erreur :", error);
            });
        }
      });
    } else {
      Swal.fire({
        title: "Le problème de cette annonce n'est pas résolu...",
        icon: "warning",
        confirmButtonColor: '#FFC65A'
      }).then((result) => {
        if (result.isConfirmed) {
          // Envoi des données au serveur Rails via Fetch POST
          fetch(`/pet_alerts/${pet_alert_id}`, {
            method: "PATCH",
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
              Accept: "application/json",
            },
            body: JSON.stringify({
              pet_alert: {
                status: false,
              },
            }),
          })
            .then((response) => {
              if (!response.ok) {
                throw new Error("Erreur lors de l'envoi des données.");
              }
              return response.text(); // Récupère la réponse en tant que texte brut
            })
            .then((text) => {
              const data = text ? JSON.parse(text) : {}; // Parse uniquement si du contenu existe
              console.log("Réponse JSON :", data);
              window.location.reload();
            })
            .catch((error) => {
              Swal.fire("Erreur", "Impossible de modifier le statut de l'annonce", "error");
              console.error("Erreur :", error);
            });
        }
      });
    }
  }

}

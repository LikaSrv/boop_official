import { Controller } from "@hotwired/stimulus";
import { Chart, LineController, LineElement, PointElement, LinearScale, Title, CategoryScale } from "chart.js";

// Enregistrer tous les composants nécessaires pour un graphique "line"
Chart.register(LineController, LineElement, PointElement, LinearScale, Title, CategoryScale);

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["chart"];
  chart = null; // Stocker l'instance du graphique

  connect() {
    console.log("ChartController connecté !");

    if (this.hasChartTarget) {
      // console.log("Chart target trouvé :", this.chartTarget);
      this.initializeChart();
    } else {
      console.error("Chart target introuvable !");
    }
  }

  initializeChart() {

    const myLine = this.chartTarget;
    const labels = JSON.parse(myLine.dataset.label);
    const data = JSON.parse(myLine.dataset.values);
    const ids = JSON.parse(myLine.dataset.ids);
    const petId = JSON.parse(myLine.dataset.petid);
    // console.log("Pet ID: ", petId);

    // console.log(ids);


    // Combinez les données pour les trier ensemble
    const combinedData = labels.map((label, index) => ({
      date: label, // Format "YYYY-MM-DD"
      value: data[index],
      id: ids[index],
    }));

    // Triez les données par date
    combinedData.sort((a, b) => new Date(a.date) - new Date(b.date));

    // Recréez les labels et les valeurs triés
    const sortedLabels = combinedData.map(item => item.date);
    const sortedValues = combinedData.map(item => item.value);
    const sortedIds = combinedData.map(item => item.id); // Récupère les IDs

    // Reformatez les dates après le tri
    const formattedLabels = sortedLabels.map(label => {
      const date = new Date(label);
      const day = String(date.getDate()).padStart(2, "0");
      const month = String(date.getMonth() + 1).padStart(2, "0");
      const year = date.getFullYear();
      return `${day}-${month}-${year}`;
    });

    // Si un graphique existe déjà, le détruire avant d'en créer un nouveau
    if (this.chart) {
      this.chart.destroy();
    }

    this.chart = new Chart(myLine, {
      type: "line",
      data: {
        labels: formattedLabels,
        datasets: [
          {
            label: "Suivi de poids",
            data: sortedValues,
            meta: sortedIds,
            borderColor: "rgba(75, 192, 192, 1)",
            borderWidth: 2,
            tension: 0.4,
          },
        ],
      },
      options: {
        responsive: true,
        plugins: {
          legend: { position: "top" },
          tooltip: { enabled: true },
        },
        onClick: (event, elements) => {
          // console.log(event);
          // console.log(elements);

          if (elements.length > 0) {
            const pointIndex = elements[0].index; // Récupérer l'index du point cliqué
            // console.log(pointIndex);
            const datasetIndex = elements[0].datasetIndex;
            // console.log(datasetIndex);
            // console.log(myLine);


            const value = this.chart.data.datasets[datasetIndex].data[pointIndex];
            // console.log("value: ", value);
            const date = this.chart.data.labels[pointIndex];
            // console.log("date: ", date);
            const formattedDate = this.formatDate(date);
            // console.log("formattedDate: ", formattedDate);
            const weightHistoryId = this.chart.data.datasets[datasetIndex].meta[pointIndex];
            // console.log("weightHistoryId: ", weightHistoryId); // Affiche l'ID de WeightHistory



            Swal.fire({
              title: "Modifier les informations",
              // <label for="vaccineName" class="form-label">Nom du vaccin</label>
              html: `<div class="d-flex flex-row justify-content-between my-4">
                <div class="mb-3 text-start">
                  <label for="weight" class="form-label">Le poids (en kg)</label>
                  <input type="text" id="weight" class="form-control" value="${value}">
                </div>
                <div class="mb-3 text-start">
                  <label for="date" class="form-label ">Date de pesée</label>
                  <input type="date" id="date" class="form-control" value="${formattedDate}">
                </div>
              </div>
            `,
              focusConfirm: false,
              confirmButtonText: "Enregistrer",
              cancelButtonText: "Annuler", // Personnalise le texte du bouton "Annuler"
              showCancelButton: true,
              footer: `<a href="#" id="delete-weight-history" class="text-danger">Supprimer</a>`,
              customClass: {
                confirmButton: "btn_custom", // Classe Bootstrap ou CSS personnalisée
                cancelButton: "btn btn-body-color", // Classe pour le bouton "Annuler"
              },
              didOpen: () => {
                // S'assurer que les dates sont bien pré-remplies avec les bonnes valeurs
                document.getElementById("weight").value = value;
                document.getElementById("date").value = formattedDate;
                document.getElementById("delete-weight-history").addEventListener("click", (e) => {
                  e.preventDefault(); // Empêche le comportement par défaut du lien
                  Swal.close(); // Ferme la modal avant d'exécuter la suppression

                  fetch(`/pets/${petId}/weight_histories/${weightHistoryId}`, {
                    method: "DELETE",
                    headers: {
                      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                    },
                  })
                    .then((response) => {
                      if (!response.ok) throw new Error("Erreur lors de la suppression.");
                      return response.json();
                    })
                    .then(() => {
                      Swal.fire("Supprimé !", "La pesée a été supprimée avec succès.", "success");
                      // Supprime l'élément correspondant dans le graphique
                      const pointIndex = this.chart.data.datasets[0].meta.findIndex(
                        (item) => item === weightHistoryId
                      );
                      if (pointIndex !== -1) {
                        this.chart.data.datasets[0].data.splice(pointIndex, 1);
                        this.chart.data.labels.splice(pointIndex, 1);
                        this.chart.data.datasets[0].meta.splice(pointIndex, 1);
                        this.chart.update();
                      }
                    })
                    .catch((error) => {
                      Swal.fire("Erreur", "Impossible de supprimer la pesée.", "error");
                      console.error("Erreur :", error);
                    });
                });
              },
              preConfirm: () => {
                const weight = document.getElementById("weight").value;
                const date = document.getElementById("date").value;

                if (!weight || !formattedDate) {
                  Swal.showValidationMessage("Tous les champs sont obligatoires !");
                  return false; // Empêche la fermeture si validation échoue
                }

                return { weight, formattedDate };
              },
            }).then((result) => {
              if (result.isConfirmed) {
                const updatedWeight = result.value.weight;
                const updatedDate = result.value.formattedDate;

                // Mettre à jour les données dans le graphique avant d'appeler update()
                const pointIndex = this.chart.data.datasets[0].meta.findIndex(item => item === weightHistoryId);

                if (pointIndex !== -1) {
                  // Mettre à jour la valeur et la date dans les datasets
                  this.chart.data.datasets[0].data[pointIndex] = updatedWeight;
                  this.chart.data.labels[pointIndex] = updatedDate;

                  // Mettre à jour les données du graphique
                  this.chart.update();
                }

                // Envoi des données au serveur Rails via Fetch POST
                fetch(`/pets/${petId}/weight_histories/${weightHistoryId}`, {
                  method: "PATCH",
                  headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                  },
                  body: JSON.stringify({
                    weight_history: {
                      weight: result.value.weight,
                      date: result.value.formattedDate,
                    },
                  }),
                })
                  .then((response) => {
                    if (!response.ok) throw new Error("Erreur lors de l'envoi des données.");
                    return response.json();
                  })
                  .then((data) => {
                    Swal.fire("Le poids a été modifié", "", "success");
                    console.log("Réponse du serveur :", data);
                    // Mettre à jour l'élément dans le DOM
                    this.chart.update();
                  })
                  .catch((error) => {
                    Swal.fire("Erreur", "Impossible d'enregistrer les données.", "error");
                    console.error("Erreur :", error);
                  });
              }
            });
          }
        }
      },
    });
  }

  addWeight(weight, date) {
    // Ajoute les nouvelles données au graphique existant
    this.chart.data.labels.push(date);
    this.chart.data.datasets[0].data.push(weight);

    // Met à jour le graphique
    this.chart.update();
  }



  // Fonction pour trier les données par date
  sortData(labels, data) {
    // Combine les dates et les poids dans un tableau d'objets
    const combinedData = labels.map((label, index) => ({
      label,
      data: data[index],
    }));

    // Trier le tableau d'objets par la date (label)
    combinedData.sort((a, b) => new Date(a.label) - new Date(b.label));

    // Séparer les dates et les poids après le tri
    const sortedLabels = combinedData.map(item => item.label);
    const sortedData = combinedData.map(item => item.data);

    // Remplacer les anciennes données triées
    labels.length = 0;  // Vider le tableau des labels
    data.length = 0;  // Vider le tableau des données

    // Ajouter les données triées
    labels.push(...sortedLabels);
    data.push(...sortedData);
  }

  // Fonction pour transformer la date au format "dd-MM-yyyy" en "yyyy-MM-dd"
  formatDate(inputDate) {
    // Séparer la date en jour, mois et année
    const [day, month, year] = inputDate.split('-');

    // Créer une nouvelle date avec les valeurs séparées
    const date = new Date(year, month - 1, day); // Mois commence à 0 en JavaScript

    // Ajuster la date pour être à 00:00:00 du fuseau horaire local
    date.setHours(0, 0, 0, 0);

    // Formatter la date au format "yyyy-MM-dd" en prenant les éléments de la date locale
    const formattedDate = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;

    return formattedDate;
  }
}

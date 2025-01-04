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
      console.log("Chart target trouvé :", this.chartTarget);
      this.initializeChart();
    } else {
      console.error("Chart target introuvable !");
    }
  }

  initializeChart() {

    const myLine = this.chartTarget;
    const labels = JSON.parse(myLine.dataset.label);
    const data = JSON.parse(myLine.dataset.values);

    // Combinez les données pour les trier ensemble
    const combinedData = labels.map((label, index) => ({
      date: label, // Format "YYYY-MM-DD"
      value: data[index],
    }));

    // Triez les données par date
    combinedData.sort((a, b) => new Date(a.date) - new Date(b.date));

    // Recréez les labels et les valeurs triés
    const sortedLabels = combinedData.map(item => item.date);
    const sortedValues = combinedData.map(item => item.value);

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



}

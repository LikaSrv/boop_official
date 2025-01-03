import { Controller } from "@hotwired/stimulus";
import { Chart, LineController, LineElement, PointElement, LinearScale, Title, CategoryScale } from "chart.js";

// Enregistrer tous les composants nécessaires pour un graphique "line"
Chart.register(LineController, LineElement, PointElement, LinearScale, Title, CategoryScale);

// Connects to data-controller="chart"
export default class extends Controller {
  connect() {
    console.log("hi");

    const myLine = document.querySelector('#myLine');
    const worldPopulationGrowth = {
      "2020": 7794798739,
      "2019": 7894798739,
      "2018": 7774798739,
      "2017": 7794798739,
      "2016": 7654798739,
      "2015": 7604798739,
      "2014": 7514798739,
      "2013": 7494798739,
      "2012": 7444798739,
      "2011": 7334798739,
      "2010": 7224798739,
    };

    const mychartLine = new Chart(myLine, {
      type: 'line',
      data: {
        labels: Object.keys(worldPopulationGrowth),
        datasets: [{
          label: 'World Population Growth',
          data: Object.values(worldPopulationGrowth),
          borderColor: 'rgba(75, 192, 192, 1)',
          borderWidth: 2,
          tension: 0.4, // Lissage des courbes
        }]
      },
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'World Population Growth Over Time',
          },
        },
        scales: {
          x: {
            type: 'category', // Utilisation de l'échelle "category"
          },
          y: {
            beginAtZero: true,
          },
        },
      }
    })
  }
}

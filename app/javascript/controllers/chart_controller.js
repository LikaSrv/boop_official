import { Controller } from "@hotwired/stimulus";
import { Chart, LineController, LineElement, PointElement, LinearScale, Title, CategoryScale } from "chart.js";

// Enregistrer tous les composants nécessaires pour un graphique "line"
Chart.register(LineController, LineElement, PointElement, LinearScale, Title, CategoryScale);

// Connects to data-controller="chart"
export default class extends Controller {


  connect() {
    // console.log("hi");

    const myLine = document.querySelector('#myLine');
    const labels = JSON.parse(myLine.dataset.label);
    const data = JSON.parse(myLine.dataset.values);

    new Chart(myLine, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: 'Exemple de données',
          data: data,
          borderColor: 'rgba(75, 192, 192, 1)',
          borderWidth: 2,
          tension: 0.4,
        }],
      },
      options: {
        responsive: true,
        plugins: {
          legend: { position: 'top' },
          tooltip: { enabled: true },
        },
      },
    });
  }
}

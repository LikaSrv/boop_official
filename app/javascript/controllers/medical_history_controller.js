import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="medical-history"
export default class extends Controller {

  static targets =["addButton", "medical_fields"]

  connect() {
    console.log("hi");
  }

  click(event){
    event.preventDefault();
    event.currentTarget.style.display = "none";
    this.medical_fieldsTarget.classList.remove("d-none");
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="medical-history"
export default class extends Controller {

  static targets =["addButton", "medical_fields", "formContainer", "template"]

  connect() {
    console.log("hi");
  }

  click(event){
    event.currentTarget.style.display = "none";
    this.medical_fieldsTarget.classList.remove("d-none");
  }

  addVaccination() {
    event.preventDefault();
    const clone = this.templateTarget.content.cloneNode(true);
    this.formContainerTarget.appendChild(clone);
  }

  remove(event) {
    event.preventDefault();
    const field = event.target.closest(".nested-fields");
    field.querySelector("input[name*='_destroy']").value = "1";
    field.style.display = "none";
  }

}

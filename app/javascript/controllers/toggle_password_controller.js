import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-password"
export default class extends Controller {
  connect() {

    const toggle = document.getElementById("toggle-password");
    const toggleConfirm = document.getElementById("toggle-confirm-password");

    const passwordField = document.getElementById("password-field");
    const confirmpasswordField = document.getElementById("confirm-password-field");

    if (!toggle || !passwordField) return;
    if (!toggleConfirm || !confirmpasswordField) return;

    toggle.addEventListener("click", () => {
      const type = passwordField.getAttribute("type") === "password" ? "text" : "password";
      passwordField.setAttribute("type", type);
      // change l'icône
      toggle.classList.toggle("fa-eye");
      toggle.classList.toggle("fa-eye-slash");
    });

    toggleConfirm.addEventListener("click", () => {
      const type = confirmpasswordField.getAttribute("type") === "password" ? "text" : "password";
      confirmpasswordField.setAttribute("type", type);
      // change l'icône
      toggleConfirm.classList.toggle("fa-eye");
      toggleConfirm.classList.toggle("fa-eye-slash");
    });
  }
}

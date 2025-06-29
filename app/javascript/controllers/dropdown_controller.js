import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { ticketId: String }
  static targets = ["menu"]

  connect() {
    this.boundClose = this.close.bind(this)
  }

  toggle(event) {
    event.stopPropagation()

    // Hide all other open dropdowns
    document.querySelectorAll("[data-dropdown-target='menu']").forEach(el => {
      if (el !== this.menuTarget) el.classList.add("hidden")
    })

    this.menuTarget.classList.toggle("hidden")

    if (!this.menuTarget.classList.contains("hidden")) {
      document.addEventListener("click", this.boundClose)
    }
  }

  close(event) {
    const button = document.getElementById(`menu-button-${this.ticketIdValue}`)
    const dropdown = this.menuTarget

    if (!button.contains(event.target) && !dropdown.contains(event.target)) {
      dropdown.classList.add("hidden")
      document.removeEventListener("click", this.boundClose)
    }
  }
}

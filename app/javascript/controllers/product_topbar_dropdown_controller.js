import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "display"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  select(event) {
    const selectedValue = event.currentTarget.dataset.category
    this.displayTarget.textContent = selectedValue
    this.menuTarget.classList.add("hidden")
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
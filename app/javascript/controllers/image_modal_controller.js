import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-modal"
export default class extends Controller {
  static targets = ["modal", "modalImage", "closeButton"]

  connect() {
    this.showImage = this.showImage.bind(this)
    document.addEventListener("click", this.showImage)
  }

  disconnect() {
    document.removeEventListener("click", this.showImage)
  }

  showImage(event) {
    if (event.target.classList.contains("zoomable-image")) {
      this.modalTarget.style.display = "block"
      this.modalImageTarget.src = event.target.src
    }
  }

  closeModal() {
    this.modalTarget.style.display = "none"
  }
}

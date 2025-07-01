// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.body.classList.add('overflow-hidden')
    document.addEventListener('keydown', this.closeWithKey.bind(this))
    this.element.addEventListener('click', this.closeOnClickOutside.bind(this))
  }

  disconnect() {
    document.body.classList.remove('overflow-hidden')
    document.removeEventListener('keydown', this.closeWithKey.bind(this))
  }

  close() {
    this.element.remove()
    if (this.element.closest('turbo-frame')) {
      this.element.closest('turbo-frame').removeAttribute('src')
    }
  }

  closeOnClickOutside(event) {
    if (event.target === this.element) {
      this.close()
    }
  }

  closeWithKey(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }
}
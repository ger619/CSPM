import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['modalContainer']

  connect() {
    document.body.classList.add('overflow-hidden');
    document.addEventListener('keydown', this.closeWithKey.bind(this));
    this.element.addEventListener('click', this.closeOnClickOutside.bind(this));
  }

  disconnect() {
    document.body.classList.remove('overflow-hidden');
  }

  async close() {
    // Add slide-out class to trigger animation
    this.element.querySelector('.fixed.inset-y-0.right-0').classList.add('slide-out');

    // Wait for animation to complete before removing
    await new Promise((resolve) => setTimeout(resolve, 300));

    // Remove the modal
    this.element.remove();
    if (this.element.closest('turbo-frame')) {
      this.element.closest('turbo-frame').removeAttribute('src');
    }
  }

  closeOnClickOutside(event) {
    if (event.target === this.element) {
      this.close();
    }
  }

  closeWithKey(event) {
    if (event.key === 'Escape') {
      this.close();
    }
  }
}
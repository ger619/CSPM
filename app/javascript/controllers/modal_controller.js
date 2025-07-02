import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['modalContainer'];

  connect() {
    document.body.classList.add('overflow-hidden');

    // ✅ Bind once and store references
    this.boundCloseWithKey = this.closeWithKey.bind(this);
    this.boundCloseOnClickOutside = this.closeOnClickOutside.bind(this);

    document.addEventListener('keydown', this.boundCloseWithKey);
    this.element.addEventListener('click', this.boundCloseOnClickOutside);
  }

  disconnect() {
    document.body.classList.remove('overflow-hidden');

    // ✅ Use stored reference when removing
    document.removeEventListener('keydown', this.boundCloseWithKey);
    this.element.removeEventListener('click', this.boundCloseOnClickOutside);
  }

  async close() {
    const panel = this.element.querySelector('.fixed.inset-y-0.right-0');
    if (panel) panel.classList.add('slide-out');

    await new Promise((resolve) => setTimeout(resolve, 300));

    this.element.remove();
    const frame = this.element.closest('turbo-frame');
    if (frame) frame.removeAttribute('src');
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
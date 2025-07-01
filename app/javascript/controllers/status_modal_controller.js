import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['dropdown']

  toggle() {
    this.dropdownTarget.classList.toggle('hidden');
  }

  close() {
    this.dropdownTarget.classList.add('hidden');
  }

  // Close when clicking outside
  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close();
    }
  }

  // Close when pressing Escape
  closeWithKey(e) {
    if (e.key === 'Escape') {
      this.close();
    }
  }
}
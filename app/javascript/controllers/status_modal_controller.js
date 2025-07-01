import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['dropdown', 'modal']

  connect() {
    document.addEventListener('keydown', this.closeWithKey.bind(this));
    document.addEventListener('click', this.closeOnClickOutside.bind(this));
  }

  disconnect() {
    document.removeEventListener('keydown', this.closeWithKey.bind(this));
    document.removeEventListener('click', this.closeOnClickOutside.bind(this));
  }

  // Status dropdown methods
  toggleDropdown() {
    this.dropdownTarget.classList.toggle('hidden');
  }

  closeDropdown() {
    this.dropdownTarget.classList.add('hidden');
  }

  // Modal methods
  openModal() {
    this.modalTarget.classList.remove('hidden');
    document.body.classList.add('overflow-hidden');
  }

  closeModal() {
    this.modalTarget.classList.add('hidden');
    document.body.classList.add('overflow-auto');
  }

  // Close when clicking outside
  closeOnClickOutside(event) {
    if (!this.element.contains(event.target) && !this.modalTarget.contains(event.target)) {
      this.closeDropdown();
      this.closeModal();
    }
  }

  // Close when pressing Escape
  closeWithKey(e) {
    if (e.key === 'Escape') {
      this.closeDropdown();
      this.closeModal();
    }
  }
}
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['menu', 'display']

  toggle() {
    this.menuTarget.classList.toggle('hidden');
  }

  select(event) {
    const selectedValue = event.currentTarget.dataset.category;
    this.displayTarget.textContent = selectedValue;
    this.menuTarget.classList.add('hidden');

    // Logic for the sorted by in the product topbar index
    const selected = event.target.dataset.category;
    this.displayTarget.textContent = selected;

    // Build the URL with a query param
    const url = new URL(window.location.href);
    url.searchParams.set('sort_by', selected.toLowerCase());

    // Navigate to the new URL
    window.location.href = url.toString();
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add('hidden');
    }
  }
}
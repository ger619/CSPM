import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['form'];

  toggleForm(event) {
    event.preventDefault();
    this.formTarget.classList.toggle('hidden');

    if (!this.formTarget.classList.contains('hidden')) {
      this.formTarget.scrollIntoView({ behavior: 'smooth' });
    }
  }
}
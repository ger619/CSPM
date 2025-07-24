/* global Turbo */
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input']

  submit(event) {
    if (this.inputTarget.value.trim() === '') {
      event.preventDefault();
      const url = new URL(window.location.href);
      url.searchParams.delete('query');
      Turbo.visit(url.toString());
    }
  }
}
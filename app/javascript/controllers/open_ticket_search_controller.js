import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['alert']

  /* eslint-disable class-methods-use-this */
  connect() {
    // Controller is now connected to the alert element
  }

  closeAlert() {
    this.alertTarget.remove(); // Completely removes the modal from the DOM
  }
}
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['initialList', 'fullList', 'showText', 'hideText', 'icon']

  toggle() {
    this.fullListTarget.classList.toggle('hidden');
    this.initialListTarget.classList.toggle('hidden');
    this.showTextTarget.classList.toggle('hidden');
    this.hideTextTarget.classList.toggle('hidden');
    this.iconTarget.classList.toggle('rotate-180');
  }
}
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['content']

  static values = { limit: { type: Number, default: 3000 } }

  connect() {
    this.limitValue = Math.min(this.limitValue, 3000); // Ensure limit does not exceed 1200
    this.updateCounter();
    this.contentTarget.addEventListener('input', (event) => this.enforceLimit(event));
  }

  enforceLimit(event) {
    const textLength = this.contentTarget.textContent.length;

    // If the text exceeds the limit, prevent further typing
    if (textLength > this.limitValue) {
      const excessText = this.contentTarget.textContent.slice(0, this.limitValue);
      this.contentTarget.textContent = excessText;
      event.preventDefault(); // Stop the user from adding more text
    }

    this.updateCounter(textLength);
  }

  updateCounter(textLength = 0) {
    document.getElementById('char-count').innerText = `${Math.min(textLength, this.limitValue)}/${this.limitValue}`;
  }
}
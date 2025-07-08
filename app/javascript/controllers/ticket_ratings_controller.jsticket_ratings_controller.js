import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['modal', 'ratingValue', 'star']

  connect() {
    // Initialize with any existing rating value
    if (this.ratingValueTarget.value) {
      this.highlightStars({ params: { value: this.ratingValueTarget.value } });
    }
  }

  openModal() {
    this.modalTarget.classList.remove('hidden');
  }

  closeModal() {
    this.modalTarget.classList.add('hidden');
  }

  highlightStars(event) {
    const starValue = event?.params?.value || event.target.dataset.value;
    this.starTargets.forEach((star) => {
      star.classList.toggle('orange', star.dataset.value <= starValue);
    });
  }

  resetStars() {
    this.highlightStars({ params: { value: this.ratingValueTarget.value } });
  }

  setRating(event) {
    const { value } = event.target.dataset;
    this.ratingValueTarget.value = value;
    this.highlightStars(event);
  }
}
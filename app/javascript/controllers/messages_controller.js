/* eslint-disable class-methods-use-this, no-undef, no-console */
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['form', 'editForm'];

  // Toggle new message form
  toggleForm(event) {
    event.preventDefault();
    this.formTarget.classList.toggle('hidden');

    if (!this.formTarget.classList.contains('hidden')) {
      this.formTarget.scrollIntoView({ behavior: 'smooth' });
    }
  }

  // Show edit form for a specific message
  showEditForm(event) {
    event.preventDefault();
    const { messageId } = event.currentTarget.dataset;
    const editForm = document.getElementById(`edit-form-${messageId}`);

    // Hide all edit forms
    this.editFormTargets.forEach((form) => form.classList.add('hidden'));

    // Show the clicked form
    if (editForm) {
      editForm.classList.toggle('hidden');
      editForm.scrollIntoView({ behavior: 'smooth' });
    }
  }

  // Handle form submission
  handleSubmit(event) {
    event.preventDefault();
    const form = event.target;
    fetch(form.action, {
      method: form.method,
      body: new FormData(form),
      headers: {
        Accept: 'text/vnd.turbo-stream.html, text/html, application/xhtml+xml',
      },
    })
      .then((response) => response.text())
      .then((html) => {
        Turbo.renderStreamMessage(html);
        // Hide the form after successful submission
        form.closest('[data-messages-target="editForm"]').classList.add('hidden');
      })
      .catch((error) => console.error('Error:', error));
  }
}
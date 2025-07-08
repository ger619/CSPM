import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['software', 'groupware', 'groupwareField']

  static values = {
    projectId: String,
  }

  connect() {
    // Initialize groupware field visibility
    if (!this.softwareTarget.value) {
      this.groupwareFieldTarget.style.display = 'none';
    }
  }

  updateGroupwareOptions(event) {
    const softwareId = event.target.value;
    const groupwareSelect = this.groupwareTarget;
    const groupwareField = this.groupwareFieldTarget;

    // Clear existing options
    groupwareSelect.innerHTML = '<option value="">Select The Product</option>';

    if (softwareId) {
      // Show the field
      groupwareField.style.display = 'block';

      // Fetch groupwares
      fetch(`/projects/${this.projectIdValue}/groupwares?software_id=${softwareId}`, {
        headers: {
          Accept: 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      })
        .then((response) => {
          if (!response.ok) throw new Error('Network response was not ok');
          return response.json();
        })
        .then((groupwares) => {
          groupwares.forEach((groupware) => {
            const option = new Option(groupware.name, groupware.id);
            groupwareSelect.add(option);
          });
        })
        .catch((error) => {
          console.error('Error fetching groupwares:', error);
          groupwareSelect.innerHTML = '<option value="">Error loading groupwares</option>';
        });
    } else {
      // Hide the field
      groupwareField.style.display = 'none';
    }
  }
}
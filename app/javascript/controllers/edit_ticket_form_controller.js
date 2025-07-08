import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['software', 'groupware', 'groupwareField']

  static values = {
    projectId: String,
    selectedGroupwareId: String,
  }

  connect() {
    // Initialize with current values
    if (this.softwareTarget.value) {
      this.updateGroupwareOptions({
        params: {
          softwareId: this.softwareTarget.value,
          selectedGroupwareId: this.selectedGroupwareIdValue,
        },
      });
    }
  }

  updateGroupwareOptions(event) {
    const softwareId = event?.params?.softwareId || event.target.value;
    const selectedGroupwareId = event?.params?.selectedGroupwareId;

    // Clear existing options
    this.groupwareTarget.innerHTML = '<option value="">Select The Product</option>';

    if (softwareId) {
      // Show the field
      this.groupwareFieldTarget.style.display = 'block';

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
            if (groupware.id == selectedGroupwareId) { // eslint-disable-line eqeqeq
              option.selected = true;
            }
            this.groupwareTarget.add(option);
          });
        })
        .catch((error) => {
          console.error('Error fetching groupwares:', error);
          this.groupwareTarget.innerHTML = '<option value="">Error loading groupwares</option>';
        });
    } else {
      // Hide the field
      this.groupwareFieldTarget.style.display = 'none';
    }
  }
}
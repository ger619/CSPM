import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="cease-fire-report"
export default class extends Controller {
  connect() {
    const select = this.element;
    if (!select) return;

    // Remove existing custom multi-select container if it exists
    const existingContainer = select.nextElementSibling;
    if (existingContainer && existingContainer.classList.contains('custom-multi-select-container')) {
      existingContainer.remove();
    }

    const container = document.createElement('div');
    container.classList.add('custom-multi-select-container');

    const button = document.createElement('div');
    button.classList.add('custom-multi-select-btn');
    button.textContent = 'Select Clients';
    container.appendChild(button);

    const optionsContainer = document.createElement('div');
    optionsContainer.classList.add('custom-multi-select-options');
    container.appendChild(optionsContainer);

    select.parentNode.insertBefore(container, select);
    select.style.display = 'none';

    Array.from(select.options).forEach((option) => {
      const label = document.createElement('label');
      const checkbox = document.createElement('input');
      checkbox.type = 'checkbox';
      checkbox.value = option.value;
      checkbox.checked = option.selected;
      checkbox.addEventListener('change', () => {
        option.selected = checkbox.checked;
      });
      label.appendChild(checkbox);
      label.appendChild(document.createTextNode(option.text));
      optionsContainer.appendChild(label);
    });

    button.addEventListener('click', () => {
      optionsContainer.style.display = optionsContainer.style.display === 'block' ? 'none' : 'block';
    });

    document.addEventListener('click', (event) => {
      if (!container.contains(event.target)) {
        optionsContainer.style.display = 'none';
      }
    });

    // Display selected clients on button
    this.updateButtonText(button, select);
  }

  // eslint-disable-next-line class-methods-use-this
  updateButtonText(button, select) {
    const selectedOptions = Array.from(select.selectedOptions).map((option) => option.text).join(', ');
    button.textContent = selectedOptions || 'Select Clients';
  }
}
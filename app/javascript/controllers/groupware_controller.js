// app/javascript/controllers/groupware_controller.js

document.addEventListener('DOMContentLoaded', () => {
  const softwareSelect = document.querySelector('[data-action="change->form#updateGroupwareOptions"]');
  const groupwareSelect = document.getElementById('groupware-select');

  if (softwareSelect && groupwareSelect) {
    softwareSelect.addEventListener('change', () => {
      const softwareId = softwareSelect.value;

      // Clear existing options
      groupwareSelect.innerHTML = '<option value="">Select The Product</option>';

      if (softwareId) {
        fetch(`/groupwares?software_id=${softwareId}`, { headers: { Accept: 'application/json' } })
          .then((response) => response.json())
          .then((data) => {
            data.forEach(groupware => {
              const option = document.createElement('option');
              option.value = groupware.id;
              option.textContent = groupware.name;
              groupwareSelect.appendChild(option);
            });
          })
          .catch(error => console.error('Error fetching groupwares:', error));
      }
    });
  }
});

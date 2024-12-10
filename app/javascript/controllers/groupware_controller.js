document.addEventListener('turbo:load', () => {
  const softwareSelect = document.querySelector('[data-action="change->form#updateGroupwareOptions"]');
  const groupwareSelect = document.getElementById('groupware-select');

  if (softwareSelect && groupwareSelect) {
    softwareSelect.addEventListener('change', () => {
      const softwareId = softwareSelect.value;

      groupwareSelect.innerHTML = '<option value="">Select The Product</option>';

      if (softwareId) {
        fetch(`/groupwares?software_id=${softwareId}`, { headers: { Accept: 'application/json' } })
          .then((response) => {
            if (!response.ok) {
              throw new Error('Network response was not ok.');
            }
            if (response.headers.get('content-type').includes('application/json')) {
              return response.json();
            }
            throw new Error('Unexpected content type');
          })
          .then((data) => {
            if (Array.isArray(data)) {
              data.forEach((groupware) => {
                const option = document.createElement('option');
                option.value = groupware.id;
                option.textContent = groupware.name;
                groupwareSelect.appendChild(option);
              });
            }
          })
          .catch((error) => {
            // eslint-disable-next-line no-console
            console.error(`Failed to fetch groupwares: ${error.message}`);
          });
      }
    });
  }
});
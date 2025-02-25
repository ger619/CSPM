import Tribute from 'tributejs';

document.addEventListener('turbo:load', () => {
  const editor = document.querySelector('#content');
  const currentUrl = window.location.pathname;
  const isAdmin = editor?.dataset.isAdmin === 'true';

  if (editor && isAdmin && (currentUrl.includes('/tickets/new') || currentUrl.match(/\/tickets\/[0-9a-fA-F-]+\/edit/) || currentUrl.includes('/comments/new') || currentUrl.match(/\/comments\/[0-9a-fA-F-]+\/edit/) || currentUrl.includes('/issues/new') || currentUrl.match(/\/issues\/[0-9a-fA-F-]+\/edit/))) {

    const tribute = new Tribute({
      trigger: '@',
      allowSpaces: false,
      lookup: 'key',
      values: async (text, cb) => {

        if (!text.trim()) return cb([]);

        try {
          const response = await fetch(`/users/search?q=${encodeURIComponent(text)}`);
          if (!response.ok) throw new Error('Failed to fetch users');
          
          const users = await response.json();
          console.log('Fetched users:', users);

          if (!Array.isArray(users) || users.length === 0) {
            return cb([]);
          }

          const uniqueUsers = Array.from(new Map(users.map(user => [
            user.id, 
            { 
              key: `${user.first_name} ${user.last_name}`,
              value: `@${user.first_name}`,
              fullName: `${user.first_name} ${user.last_name}`,
              email: `${user.email}` // Store the email for later use
            }
          ])).values());

          cb(uniqueUsers);
        } catch (error) {
          cb([]);
        }
      },
      menuItemTemplate(item) {
        return `<span>${item.original.fullName} (${item.original.email})</span>`;
      },
      selectTemplate(item) {
        return `${item.original.value}`;
      },
      menuClass: 'tribute-container',
      positionMenu(menu, trigger) {
        const rect = trigger.getBoundingClientRect();
        menu.style.left = `${rect.left}px`;
        menu.style.top = `${rect.bottom + window.scrollY}px`;
        menu.style.width = `${rect.width}px`;
      },
    });

    tribute.attach(editor);

    // Listen for Tribute selection event
    editor.addEventListener('tribute-replaced', async (event) => {
      const selectedUser = tribute.current.collection.find(user => user.value === event.detail.item.original.value);

      if (selectedUser && selectedUser.email) {
        console.log('Selected User:', selectedUser);

        // Send the email to the backend
        try {
          const response = await fetch('/notifications/send_email', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content // For Rails
            },
            body: JSON.stringify({ email: selectedUser.email })
          });

          const result = await response.json();
          if (response.ok) {
            console.log('Email notification sent successfully:', result);
          } else {
            console.error('Error sending email notification:', result);
          }
        } catch (error) {
          console.error('Error in API request:', error);
        }
      }
    });
  }
});

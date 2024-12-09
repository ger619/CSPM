document.addEventListener('turbo:load', () => {
  const editor = document.querySelector('#content');
  const currentUrl = window.location.pathname;

  // Check if the current URL matches the ticket form URL
  if (editor && (currentUrl.includes('/tickets/new') || currentUrl.match(/\/tickets\/[0-9a-fA-F-]+\/edit/) || currentUrl.includes('/comments/new') || currentUrl.match(/\/comments\/[0-9a-fA-F-]+\/edit/) || currentUrl.includes('/issues/new') || currentUrl.match(/\/issues\/[0-9a-fA-F-]+\/edit/))) {
    // eslint-disable-next-line no-undef
    const tribute = new Tribute({
      trigger: '@', // Triggers the dropdown when '@' is typed
      allowSpaces: false,
      lookup: 'name', // We'll combine first_name and last_name as 'name'
      values: async (text, cb) => {
        const response = await fetch(`/users/search?q=${text}`);
        const users = await response.json();

        // Use a Set to filter out duplicate names
        const uniqueUsers = Array.from(new Set(
          users.map((user) => `${user.first_name} ${user.last_name}`),
        ));

        // Create the array of objects with unique full names
        cb(uniqueUsers.map((fullName) => ({
          key: fullName, // Display both first and last names
          value: fullName, // Insert full name
        })));
      },
      menuItemTemplate(item) {
        // Display full name in the dropdown
        return `<span>${item.original.key}</span>`;
      },
      selectTemplate(item) {
        // Use only first_name for selection but show full name in input
        return `@${item.original.value}`;
      },
      menuClass: 'tribute-container', // Add custom class to the menu for styling
      positionMenu(menu, trigger) {
        const rect = trigger.getBoundingClientRect();
        menu.style.left = `${rect.left}px`;
        menu.style.top = `${rect.bottom + window.scrollY}px`; // Adjusts menu placement below the text area
        menu.style.width = `${rect.width}px`; // Ensure menu matches the width of the text area
      },
    });

    tribute.attach(editor);
  }
});
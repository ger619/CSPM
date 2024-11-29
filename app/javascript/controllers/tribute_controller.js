document.addEventListener("turbo:load", function () {
  var tribute = new Tribute({
    trigger: '@', // Triggers the dropdown when '@' is typed
    allowSpaces: false,
    lookup: 'name', // We'll combine first_name and last_name as 'name'
    values: async (text, cb) => {
      let response = await fetch(`/users/search?q=${text}`);
      let users = await response.json();

      // Combine first_name and last_name for display
      cb(users.map(user => ({
        key: `${user.first_name} ${user.last_name}`, // Display both first and last names
        value: `${user.first_name} ${user.last_name}` // Insert full name
      })));
    },
    menuItemTemplate: function (item) {
      // Display full name in the dropdown
      return `<span>${item.original.key}</span>`;
    },
    selectTemplate: function (item) {
      // Use only first_name for selection but show full name in input
      return `@${item.original.value}`;
    },
    menuClass: 'tribute-container', // Add custom class to the menu for styling
    positionMenu: function (menu, trigger) {
      const rect = trigger.getBoundingClientRect();
      menu.style.left = `${rect.left}px`;
      menu.style.top = `${rect.bottom + window.scrollY}px`;  // Adjusts menu placement below the text area
      menu.style.width = `${rect.width}px`;  // Ensure menu matches the width of the text area
    }
  });

  let editor = document.querySelector("#content");
  tribute.attach(editor);
});
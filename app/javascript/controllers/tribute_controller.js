import Tribute from 'tributejs';

document.addEventListener('turbo:load', () => {
  const editor = document.querySelector('#content');
  const currentUrl = window.location.pathname;
  const isAdmin = editor?.dataset.isAdmin === 'true';

  if (editor && isAdmin && (currentUrl.includes('/tickets/new') || 
      currentUrl.match(/\/tickets\/[0-9a-fA-F-]+\/edit/) || 
      currentUrl.includes('/comments/new') || 
      currentUrl.match(/\/comments\/[0-9a-fA-F-]+\/edit/) || 
      currentUrl.includes('/issues/new') || 
      currentUrl.match(/\/issues\/[0-9a-fA-F-]+\/edit/))) {

    const tribute = new Tribute({
      trigger: '@',
      allowSpaces: false,
      lookup: 'key', // Ensure this matches the filterable key
      values: async (text, cb) => {
        console.log('Typing:', text); // Debugging: Check if real-time trigger works
        
        if (!text.trim()) return cb([]); // Stop if no meaningful input
        
        try {
          const response = await fetch(`/users/search?q=${encodeURIComponent(text)}`);
          if (!response.ok) throw new Error('Failed to fetch users');
          
          const users = await response.json();
          console.log('Fetched users:', users);

          if (!Array.isArray(users) || users.length === 0) {
            return cb([]); // Prevent errors if users is undefined or empty
          }

          // Ensure unique results by mapping users by ID
          const uniqueUsers = Array.from(new Map(users.map(user => [
            user.id, 
            { 
              key: `${user.first_name} ${user.last_name}`, // Tribute uses this for filtering
              value: `@${user.first_name}`, // This gets inserted in the text
              fullName: `${user.first_name} ${user.last_name}`
            }
          ])).values());

          console.log('Filtered users:', uniqueUsers);
          cb(uniqueUsers);
        } catch (error) {
          console.error('Error fetching users:', error);
          cb([]); // Provide an empty list in case of an error
        }
      },
      menuItemTemplate(item) {
        return `<span>${item.original.fullName}</span>`;
      },
      selectTemplate(item) {
        return `${item.original.value}`; // Inserts "@first_name"
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
  }
});

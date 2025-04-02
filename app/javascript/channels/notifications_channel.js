import consumer from './consumer';

consumer.subscriptions.create('NotificationsChannel', {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },
  // eslint-disable-next-line no-unused-vars
  received(data) {
    const notificationButton = document.getElementById('dropdownNotificationButton');
    if (notificationButton) {
      notificationButton.innerHTML += '<div class="absolute block w-3 h-3 bg-red-500 border-2 border-white rounded-full -top-0.5 start-2.9 dark:border-gray-900"></div>';
    }
  },
});
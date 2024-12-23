// app/javascript/channels/notifications_channel.js
import consumer from './consumer';

consumer.subscriptions.create('NotificationsChannel', {
  connected() {
  },

  disconnected() {
  },

  received() {
  },
});

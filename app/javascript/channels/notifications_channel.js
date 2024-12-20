// app/javascript/channels/notifications_channel.js
import consumer from "./consumer";

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log("Connected to the Notifications Channel!");
  },

  disconnected() {
    console.log("Disconnected from the Notifications Channel!");
  },

  received(data) {
    // Handle the incoming data from the notification broadcast
    console.log(data);
  }
});

// serviceworker.js
// The serviceworker context can respond to 'push' events and trigger
// notifications on the registration property
self.addEventListener("push", function(event) {
  var json = event.data.json();
  self.registration.showNotification(json.title, {
    body: json.body,
    icon: json.icon
  });
});

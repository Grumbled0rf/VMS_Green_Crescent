importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDQncvT9XQW3GjXRJN92VZHYNoLzZ2ugeU",
  authDomain: "vms-green.firebaseapp.com",
  projectId: "vms-green",
  storageBucket: "vms-green.firebasestorage.app",
  messagingSenderId: "799896518184",
  appId: "1:799896518184:web:395ff55661b1e586d9ff1d",
  measurementId: "G-QCNJQ5VDDW"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  console.log("Background message:", message);
  const notificationTitle = message.notification.title;
  const notificationOptions = {
    body: message.notification.body,
    icon: "/icons/Icon-192.png"
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});

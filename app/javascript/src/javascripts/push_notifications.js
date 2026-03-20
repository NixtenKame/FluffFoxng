import Rails from "@rails/ujs";
import Utility from "./utility.js";

function onReady(callback) {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", callback, { once: true });
  } else {
    callback();
  }
}

function urlBase64ToUint8Array(base64String) {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/");
  const rawData = window.atob(base64);
  const outputArray = new Uint8Array(rawData.length);
  for (let i = 0; i < rawData.length; i += 1) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}

async function getRegistration() {
  return navigator.serviceWorker.getRegistration();
}

async function ensureRegistration() {
  return navigator.serviceWorker.register("/service-worker.js");
}

function subscriptionPayload(subscription) {
  const json = subscription.toJSON();
  return {
    endpoint: subscription.endpoint,
    expiration_time: subscription.expirationTime,
    keys: json.keys,
  };
}

async function saveSubscription(subscription) {
  await fetch("/push_subscription", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": Rails.csrfToken(),
    },
    body: JSON.stringify({ subscription: subscriptionPayload(subscription) }),
    credentials: "same-origin",
  });
}

async function deleteSubscription(subscription) {
  await fetch("/push_subscription", {
    method: "DELETE",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": Rails.csrfToken(),
    },
    body: JSON.stringify({ endpoint: subscription.endpoint }),
    credentials: "same-origin",
  });
}

async function updateStatus(controls, statusEl) {
  const registration = await getRegistration();
  const subscription = registration ? await registration.pushManager.getSubscription() : null;

  if (Notification.permission === "denied") {
    statusEl.textContent = "Blocked in browser settings.";
    controls.dataset.status = "blocked";
    return;
  }

  if (subscription) {
    statusEl.textContent = "Enabled.";
    controls.dataset.status = "enabled";
  } else {
    statusEl.textContent = "Disabled.";
    controls.dataset.status = "disabled";
  }
}

async function enablePush(controls, statusEl, vapidPublicKey) {
  if (Notification.permission === "denied") {
    statusEl.textContent = "Blocked in browser settings.";
    return;
  }

  const registration = await ensureRegistration();
  const subscription = await registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: urlBase64ToUint8Array(vapidPublicKey),
  });

  await saveSubscription(subscription);
  await updateStatus(controls, statusEl);
  Utility.notice("Push notifications enabled.");
}

async function disablePush(controls, statusEl) {
  const registration = await getRegistration();
  const subscription = registration ? await registration.pushManager.getSubscription() : null;
  if (!subscription) {
    await updateStatus(controls, statusEl);
    return;
  }

  await deleteSubscription(subscription);
  await subscription.unsubscribe();
  await updateStatus(controls, statusEl);
  Utility.notice("Push notifications disabled.");
}

function initControls(controls) {
  const vapidPublicKey = Utility.meta("push-vapid-public-key");
  const statusEl = controls.querySelector(".push-notification-status");
  const enableButton = controls.querySelector("[data-action='enable']");
  const disableButton = controls.querySelector("[data-action='disable']");

  if (!("serviceWorker" in navigator) || !("PushManager" in window) || !("Notification" in window)) {
    statusEl.textContent = "Not supported in this browser.";
    controls.dataset.status = "unsupported";
    return;
  }

  if (!vapidPublicKey) {
    statusEl.textContent = "Not configured.";
    controls.dataset.status = "disabled";
    return;
  }

  enableButton.addEventListener("click", () => {
    enablePush(controls, statusEl, vapidPublicKey).catch(error => {
      void error;
      Utility.error("Failed to enable push notifications.");
    });
  });

  disableButton.addEventListener("click", () => {
    disablePush(controls, statusEl).catch(error => {
      void error;
      Utility.error("Failed to disable push notifications.");
    });
  });

  updateStatus(controls, statusEl).catch(() => {
    statusEl.textContent = "Status unavailable.";
  });
}

onReady(() => {
  const enabled = Utility.meta("push-enabled") === "true";
  if (!enabled) return;

  const controls = document.getElementById("push-notification-controls");
  if (controls) {
    initControls(controls);
  }
});

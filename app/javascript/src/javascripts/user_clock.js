// Displays the user's local time in the avatar menu.
const UserClock = {
  selectors: {
    clock: ".avatar-menu-clock-time",
  },
  initializedClass: "avatar-menu-clock-time--initialized",

  initializeClock(clockElement) {
    if (!clockElement || clockElement.classList.contains(this.initializedClass)) {
      return;
    }

    const fallbackTimeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    const requestedTimeZone = clockElement.dataset.timezone;
    const timeZone = requestedTimeZone || fallbackTimeZone;
    const options = {
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
      timeZone,
    };

    const updateClock = () => {
      const now = new Date();

      try {
        clockElement.textContent = now.toLocaleTimeString([], options);
      } catch {
        // Fallback for invalid/unknown time zone names from user profile data.
        clockElement.textContent = now.toLocaleTimeString([], {
          ...options,
          timeZone: fallbackTimeZone,
        });
      }
    };

    updateClock();
    window.setInterval(updateClock, 1000);
    clockElement.classList.add(this.initializedClass);
  },

  init() {
    document.querySelectorAll(this.selectors.clock).forEach((clockElement) => {
      this.initializeClock(clockElement);
    });
  },
};

document.addEventListener("DOMContentLoaded", () => {
  UserClock.init();

  // The avatar menu content is loaded asynchronously after first click.
  const observer = new MutationObserver(() => {
    UserClock.init();
  });

  observer.observe(document.body, { childList: true, subtree: true });
});

export default UserClock;

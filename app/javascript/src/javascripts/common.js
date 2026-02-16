import Cookie from "./cookie";
import Utility from "./utility";

function initSearch () {
  const $searchForm = $("#searchform");
  const $searchShow = $("#search-form-show-link");
  const $searchHide = $("#search-form-hide-link");
  if ($searchForm.length) {
    $searchShow.on("click", e => {
      e.preventDefault();
      $searchForm.fadeIn("fast");
      $searchShow.hide();
      $searchHide.show();
    });
    $searchHide.on("click", e => {
      e.preventDefault();
      $searchForm.fadeOut("fast");
      $searchShow.show();
      $searchHide.hide();
    });
  }
}

function initInstallShortcutPrompt () {
  if (!window.localStorage) return;

  const DISMISS_KEY = "flufffox.install_prompt.dismissed_at";
  const DISMISS_DAYS = 14;
  const $body = $("body");

  const isStandalone = window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone === true;
  if (isStandalone) return;

  const dismissedAt = parseInt(localStorage.getItem(DISMISS_KEY) || "0", 10);
  if (dismissedAt > 0) {
    const daysSinceDismiss = (Date.now() - dismissedAt) / (1000 * 60 * 60 * 24);
    if (daysSinceDismiss < DISMISS_DAYS) return;
  }

  const ua = window.navigator.userAgent || "";
  const isIOS = /iPad|iPhone|iPod/.test(ua);
  const isSafari = /Safari/.test(ua) && !/CriOS|FxiOS|EdgiOS/.test(ua);
  const isIOSSafari = isIOS && isSafari;
  const isAndroid = /Android/.test(ua);

  let deferredPrompt = null;
  let shown = false;

  function dismissPrompt () {
    localStorage.setItem(DISMISS_KEY, String(Date.now()));
    $("#install-shortcut-prompt").remove();
  }

  function showPrompt ({ title, message, iosHelp = false, onInstall = null }) {
    if (shown || $("#install-shortcut-prompt").length) return;
    shown = true;

    const helpHtml = iosHelp
      ? "<div class='install-shortcut-ios-help'>On iPhone/iPad: tap <b>Share</b> in Safari, then tap <b>Add to Home Screen</b>.</div>"
      : "";
    const installLabel = iosHelp ? "Got it" : "Install";

    const html = `
      <div id="install-shortcut-prompt" class="install-shortcut-prompt">
        <div class="install-shortcut-card">
          <h3>${title}</h3>
          <p>${message}</p>
          ${helpHtml}
          <div class="install-shortcut-actions">
            <button type="button" class="st-button install-shortcut-accept">${installLabel}</button>
            <button type="button" class="st-button install-shortcut-dismiss">Not now</button>
          </div>
        </div>
      </div>
    `;

    $body.append(html);

    $(".install-shortcut-dismiss").on("click", () => dismissPrompt());
    $(".install-shortcut-accept").on("click", async () => {
      if (typeof onInstall === "function") {
        await onInstall();
      } else {
        dismissPrompt();
      }
    });
  }

  if (isIOSSafari) {
    setTimeout(() => {
      showPrompt({
        title: "Install FluffFox",
        message: "Want a home screen shortcut like an app?",
        iosHelp: true,
      });
    }, 1400);
    return;
  }

  if (!isAndroid) return;

  window.addEventListener("beforeinstallprompt", event => {
    event.preventDefault();
    deferredPrompt = event;

    showPrompt({
      title: "Install FluffFox",
      message: "Install this site as an app shortcut on your home screen?",
      onInstall: async () => {
        if (!deferredPrompt) {
          dismissPrompt();
          return;
        }

        deferredPrompt.prompt();
        try {
          await deferredPrompt.userChoice;
        } catch (_) {
          // Ignore prompt outcome errors.
        }
        deferredPrompt = null;
        dismissPrompt();
      },
    });
  });
}

$(function () {
  // Account notices
  $(".dmail-notice-hide").on("click.danbooru", function (event) {
    event.preventDefault();
    $(".dmail-notice").hide();
    Cookie.put("hide_dmail_notice", "true");
  });

  $("#close-notice-link").on("click.danbooru", function (e) {
    $("#notice").fadeOut("fast");
    e.preventDefault();
  });

  $(".revert-item-link").on("click", e => {
    e.preventDefault();
    const target = $(e.target);
    const noun = target.data("noun");
    if (!confirm(`Are you sure you want to revert ${noun} to this version?`))
      return;
    const path = target.attr("href");
    $.ajax({
      method: "PUT",
      url: path,
      dataType: "json",
    }).done(() => {
      location.reload();
    }).fail(() => {
      Utility.error("Failed to revert to specified version.");
    });
  });

  initSearch();
  initInstallShortcutPrompt();
});

window.submitInvisibleRecaptchaForm = function () {
  document.getElementById("signup-form").submit();
};

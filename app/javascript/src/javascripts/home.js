import Page from "./utility/page";

const Home = {};
Home.ECHO_KEY = "flufffox.home.echoes";

Home.PULSE_STATES = [
  { label: "Night Owl Mode", color: "#5ec5ff", messages: ["Quiet hours, sharp focus.", "Moonlit browsing engaged.", "Low noise, high signal."] },
  { label: "Morning Spark", color: "#ffd166", messages: ["Fresh uploads energy.", "Golden-hour scrolling.", "Starting strong today."] },
  { label: "Peak Traffic", color: "#ff8c42", messages: ["Everything is moving fast.", "Hot posts are rotating.", "Main feed is buzzing."] },
  { label: "Afterglow", color: "#8de969", messages: ["Steady flow, clean vibes.", "Good time for deep dives.", "Calm and consistent."] },
];

Home.getPulseState = function () {
  const hour = new Date().getHours();
  if (hour < 6) return Home.PULSE_STATES[0];
  if (hour < 12) return Home.PULSE_STATES[1];
  if (hour < 18) return Home.PULSE_STATES[2];
  return Home.PULSE_STATES[3];
};

Home.updatePulse = function () {
  const state = Home.getPulseState();
  const message = state.messages[Math.floor(Math.random() * state.messages.length)];

  $("#home-pulse-state").text(state.label);
  $("#home-pulse-message").text(message);
  $("#home-pulse-dot").css("--pulse-color", state.color);
};

Home.readEchoes = function () {
  try {
    return JSON.parse(window.localStorage.getItem(Home.ECHO_KEY)) || [];
  } catch {
    return [];
  }
};

Home.writeEchoes = function (echoes) {
  window.localStorage.setItem(Home.ECHO_KEY, JSON.stringify(echoes));
};

Home.renderEchoes = function () {
  const echoes = Home.readEchoes();
  const $section = $("#home-echo-section");
  const $list = $("#home-echo-list");

  $list.empty();
  if (!echoes.length) {
    $section.prop("hidden", true);
    return;
  }

  echoes.forEach((tags, index) => {
    const $chip = $("<button>")
      .addClass("home-echo-chip")
      .attr("type", "button")
      .attr("data-tags", tags)
      .css("--chip-delay", `${index * 50}ms`)
      .text(tags);
    $list.append($chip);
  });

  $section.prop("hidden", false);
};

Home.saveEcho = function (tags) {
  const normalized = tags.trim().replace(/\s+/g, " ");
  if (!normalized) return;

  const echoes = Home.readEchoes().filter(item => item.toLowerCase() !== normalized.toLowerCase());
  echoes.unshift(normalized);
  Home.writeEchoes(echoes.slice(0, 8));
  Home.renderEchoes();
};

Home.init = function () {

  const $form = $("#home-search-form");
  const $tags = $("#tags");

  let isEmpty = !$tags.val();
  let wasEmpty = isEmpty;
  if (isEmpty) $form.addClass("empty");

  $tags.on("input", () => {
    wasEmpty = isEmpty;
    isEmpty = !$tags.val();

    if (isEmpty && !wasEmpty) $form.addClass("empty");
    else if (!isEmpty && wasEmpty) $form.removeClass("empty");
  });

  $(".home-buttons a").on("click", (event) => {
    if (isEmpty) return; // Act like regular links

    event.preventDefault();
    const extraTags = $(event.currentTarget).attr("tags");
    if (extraTags) {
      $tags.val((index, value) => {
        return value + " " + extraTags;
      });
    }

    $form.trigger("submit");
    return false;
  });

  $form.on("submit", () => {
    Home.saveEcho($tags.val() || "");
  });

  $("#home-echo-list").on("click", ".home-echo-chip", (event) => {
    const selectedTags = $(event.currentTarget).attr("data-tags");
    if (!selectedTags) return;
    $tags.val(selectedTags);
    $form.trigger("submit");
  });

  $("#home-echo-clear").on("click", () => {
    window.localStorage.removeItem(Home.ECHO_KEY);
    Home.renderEchoes();
  });

  Home.updatePulse();
  $("#home-pulse-button").on("click", Home.updatePulse);
  Home.renderEchoes();
};

$(() => {
  if (!Page.matches("static", "home")) return;
  Home.init();
});

export default Home;

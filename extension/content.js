(function () {
  "use strict";

  // Try several selectors so we survive sidebar collapses and minor DOM
  // reshuffles. Return the raw digit string (possibly with a trailing "+").
  const SELECTORS = [
    'a[href="/notifications"]',
    'a[href$="/notifications"]',
    '[aria-label*="unread notification" i]',
  ];

  function readRaw() {
    for (const sel of SELECTORS) {
      const el = document.querySelector(sel);
      if (!el) continue;
      const haystack =
        (el.getAttribute("aria-label") || "") + " " + (el.textContent || "");
      const m = haystack.match(/(\d+\+?)/);
      return m ? m[1] : "";
    }
    return "";
  }

  function tick() {
    const stripped = document.title.replace(/^\(\d+\+?\)\s+/, "");
    const raw = location.pathname === "/notifications" ? "" : readRaw();
    const desired = raw ? `(${raw}) ${stripped}` : stripped;
    if (document.title !== desired) document.title = desired;
  }

  setInterval(tick, 1500);
  tick();
})();

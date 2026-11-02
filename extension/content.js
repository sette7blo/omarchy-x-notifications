(function () {
  "use strict";

  function readCount() {
    const link = document.querySelector('a[href="/notifications"]');
    if (!link) return 0;
    const digits = link.textContent.match(/\d+/);
    return digits ? parseInt(digits[0], 10) : 0;
  }

  function tick() {
    if (location.pathname === "/notifications") return;
    const count = readCount();
    const stripped = document.title.replace(/^\(\d+\)\s+/, "");
    const desired = count > 0 ? `(${count}) ${stripped}` : stripped;
    if (document.title !== desired) document.title = desired;
  }

  setInterval(tick, 1500);
  tick();
})();

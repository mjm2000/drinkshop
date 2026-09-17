(function () {
  const deck = document.getElementById("deck");
  const slides = [...deck.querySelectorAll(".slide")];
  const navLinks = document.getElementById("navLinks");
  const slideCounter = document.getElementById("slideCounter");
  const progressBar = document.getElementById("progressBar");
  const presentBtn = document.getElementById("presentBtn");
  const totalScoreEl = document.getElementById("totalScore");
  const checkProgressEl = document.getElementById("checkProgress");
  const scoreInputs = document.querySelectorAll(".score-input");

  let currentIndex = 0;
  let presentMode = false;

  slides.forEach((slide, i) => {
    const title = slide.dataset.title || `Slide ${i + 1}`;
    const li = document.createElement("li");
    const a = document.createElement("a");
    a.href = `#slide-${i}`;
    a.textContent = title;
    a.addEventListener("click", (e) => {
      e.preventDefault();
      goToSlide(i);
    });
    li.appendChild(a);
    navLinks.appendChild(li);

    slide.id = `slide-${i}`;
  });

  function goToSlide(index) {
    currentIndex = Math.max(0, Math.min(index, slides.length - 1));
    slides[currentIndex].scrollIntoView({ behavior: presentMode ? "instant" : "smooth" });
    updateUI();
  }

  function updateUI() {
    slideCounter.textContent = `${currentIndex + 1} / ${slides.length}`;
    progressBar.style.width = `${((currentIndex + 1) / slides.length) * 100}%`;
    progressBar.setAttribute("aria-valuenow", Math.round(((currentIndex + 1) / slides.length) * 100));

    navLinks.querySelectorAll("a").forEach((a, i) => {
      a.classList.toggle("active", i === currentIndex);
    });
  }

  function getVisibleSlideIndex() {
    const navOffset = parseInt(getComputedStyle(document.documentElement).getPropertyValue("--nav-height")) || 56;
    const viewportMid = window.scrollY + navOffset + (window.innerHeight - navOffset) / 2;

    let closest = 0;
    let closestDist = Infinity;

    slides.forEach((slide, i) => {
      const rect = slide.getBoundingClientRect();
      const slideMid = window.scrollY + rect.top + rect.height / 2;
      const dist = Math.abs(viewportMid - slideMid);
      if (dist < closestDist) {
        closestDist = dist;
        closest = i;
      }
    });

    return closest;
  }

  let scrollTimeout;
  window.addEventListener("scroll", () => {
    if (presentMode) return;
    clearTimeout(scrollTimeout);
    scrollTimeout = setTimeout(() => {
      currentIndex = getVisibleSlideIndex();
      updateUI();
    }, 80);
  }, { passive: true });

  document.addEventListener("keydown", (e) => {
    if (e.target.matches("input, textarea")) return;

    if (e.key === "ArrowRight" || e.key === "ArrowDown" || e.key === " ") {
      e.preventDefault();
      goToSlide(currentIndex + 1);
    } else if (e.key === "ArrowLeft" || e.key === "ArrowUp") {
      e.preventDefault();
      goToSlide(currentIndex - 1);
    } else if (e.key === "Home") {
      e.preventDefault();
      goToSlide(0);
    } else if (e.key === "End") {
      e.preventDefault();
      goToSlide(slides.length - 1);
    } else if (e.key === "f" || e.key === "F") {
      togglePresentMode();
    }
  });

  presentBtn.addEventListener("click", togglePresentMode);

  function togglePresentMode() {
    presentMode = !presentMode;
    document.body.classList.toggle("present-mode", presentMode);
    presentBtn.setAttribute("aria-pressed", String(presentMode));
    presentBtn.textContent = presentMode ? "Exit" : "Present";
    if (presentMode) goToSlide(currentIndex);
  }

  function updateTotalScore() {
    let total = 0;
    scoreInputs.forEach((input) => {
      const val = parseInt(input.value, 10);
      if (!isNaN(val)) total += Math.max(1, Math.min(5, val));
    });
    totalScoreEl.innerHTML = `<strong>${total}</strong>`;
  }

  scoreInputs.forEach((input) => {
    input.addEventListener("input", updateTotalScore);
  });

  function updateCheckProgress() {
    const boxes = document.querySelectorAll('.checklist input[type="checkbox"]:not(:disabled)');
    const checked = document.querySelectorAll('.checklist input[type="checkbox"]:not(:disabled):checked');
    const pct = boxes.length ? Math.round((checked.length / boxes.length) * 100) : 0;
    checkProgressEl.textContent = `${pct}%`;
  }

  document.querySelectorAll('.checklist input[type="checkbox"]').forEach((cb) => {
    cb.addEventListener("change", updateCheckProgress);
  });

  const STORAGE_KEY = "lonewolt-checklist";
  function saveState() {
    const state = {
      checks: {},
      scores: {},
      goNoGo: document.getElementById("goNoGo")?.value,
      nextAction: document.getElementById("nextAction")?.value,
    };

    document.querySelectorAll('.checklist input[type="checkbox"]:not(:disabled)').forEach((cb, i) => {
      state.checks[i] = cb.checked;
    });

    scoreInputs.forEach((input, i) => {
      state.scores[i] = input.value;
    });

    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch (_) { /* ignore */ }
  }

  function loadState() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return;
      const state = JSON.parse(raw);

      const boxes = document.querySelectorAll('.checklist input[type="checkbox"]:not(:disabled)');
      Object.entries(state.checks || {}).forEach(([i, checked]) => {
        if (boxes[i]) boxes[i].checked = checked;
      });

      scoreInputs.forEach((input, i) => {
        if (state.scores?.[i] != null) input.value = state.scores[i];
      });

      if (state.goNoGo) document.getElementById("goNoGo").value = state.goNoGo;
      if (state.nextAction) document.getElementById("nextAction").value = state.nextAction;
    } catch (_) { /* ignore */ }
  }

  document.querySelectorAll("input").forEach((el) => {
    el.addEventListener("change", saveState);
    el.addEventListener("input", saveState);
  });

  loadState();
  updateTotalScore();
  updateCheckProgress();
  updateUI();
})();

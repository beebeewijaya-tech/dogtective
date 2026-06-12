/* ── Scroll reveal ─────────────────────────────────────── */
const observer = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      e.target.classList.add('visible');
      observer.unobserve(e.target);
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll(
  '.feature-card, .screenshot-item, .level-card, .howto-step, .faq-item, .contact-card, .about-grid, .beta-grid'
).forEach(el => {
  el.classList.add('fade-in');
  observer.observe(el);
});

/* ── Nav scroll style ──────────────────────────────────── */
const nav = document.querySelector('.nav');
window.addEventListener('scroll', () => {
  nav?.classList.toggle('scrolled', window.scrollY > 40);
}, { passive: true });

/* ── App Store placeholder ─────────────────────────────── */
document.querySelectorAll('#download-btn, #cta-download-btn').forEach(btn => {
  btn.addEventListener('click', e => {
    e.preventDefault();
    alert('Coming soon to the App Store!');
  });
});

/* ── Typewriter on hero tagline ────────────────────────── */
const taglineEl = document.querySelector('.hero-tagline');
if (taglineEl) {
  const lines = ['Someone stole the bones.', 'Nobody knows who.', 'Until now.'];
  let lineIdx = 0, charIdx = 0;
  taglineEl.innerHTML = '<span class="tw-text"></span><span class="typewriter-cursor"></span>';
  const tw = taglineEl.querySelector('.tw-text');

  function renderLines() {
    const all = [
      ...lines.slice(0, lineIdx),
      lines[lineIdx]?.slice(0, charIdx) ?? ''
    ];
    tw.innerHTML = all.map((l, i) =>
      i === lines.length - 1 ? `<strong>${l}</strong>` : l
    ).join('<br/>');
  }

  function tick() {
    const current = lines[lineIdx];
    if (!current) return;
    charIdx++;
    renderLines();
    if (charIdx >= current.length) {
      if (lineIdx < lines.length - 1) {
        lineIdx++; charIdx = 0;
        setTimeout(tick, 500);
      }
      return;
    }
    setTimeout(tick, 50 + Math.random() * 30);
  }
  setTimeout(tick, 700);
}

/* ── Mystery ticker tape ───────────────────────────────── */
const clues = [
  '🐾 The bones are missing',
  '🔍 Suspect spotted near the park',
  '📋 New evidence found',
  '🐶 Witness refuses to talk',
  '🏙️ Case file opened',
  '✨ Mystery awaits',
  '🐾 Follow the paw prints',
  '🔍 Who took the bones?',
  '📋 Clue #7 discovered',
  '🐶 Someone is hiding something',
];
const tickerWrap = document.createElement('div');
tickerWrap.className = 'ticker-wrap';
const track = document.createElement('div');
track.className = 'ticker-track';
[...clues, ...clues].forEach(text => {
  const span = document.createElement('span');
  span.className = 'ticker-item';
  span.textContent = text;
  track.appendChild(span);
});
tickerWrap.appendChild(track);
document.querySelector('.nav')?.insertAdjacentElement('afterend', tickerWrap);

/* ── Floating background paw prints ───────────────────── */
function spawnBgPaw() {
  const paw = document.createElement('img');
  paw.src = 'assets/paw_prints.png';
  paw.className = 'bg-paw';
  const size = 28 + Math.random() * 48;
  const dur  = 10 + Math.random() * 14;
  paw.style.left   = Math.random() * 100 + 'vw';
  paw.style.bottom = '-70px';
  paw.style.width  = size + 'px';
  paw.style.height = size + 'px';
  paw.style.animationDuration = dur + 's';
  document.body.appendChild(paw);
  setTimeout(() => paw.remove(), (dur + 1) * 1000);
}
for (let i = 0; i < 3; i++) spawnBgPaw();
setInterval(spawnBgPaw, 2200);

/* ── Cursor paw trail ──────────────────────────────────── */
let lastPawTime = 0;
document.addEventListener('mousemove', (e) => {
  if (Date.now() - lastPawTime < 110) return;
  lastPawTime = Date.now();
  const paw = document.createElement('img');
  paw.src = 'assets/paw_prints.png';
  paw.className = 'cursor-paw';
  paw.style.left = (e.clientX - 11) + 'px';
  paw.style.top  = (e.clientY - 11) + 'px';
  paw.style.setProperty('--rot', (Math.random() * 60 - 30) + 'deg');
  document.body.appendChild(paw);
  setTimeout(() => paw.remove(), 900);
});

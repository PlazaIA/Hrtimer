// ⏱️ CRONÔMETRO
let timer;
let seconds = 0;
let isRunning = false;

function formatTime(s) {
  const hrs = String(Math.floor(s / 3600)).padStart(2, '0');
  const mins = String(Math.floor((s % 3600) / 60)).padStart(2, '0');
  const secs = String(s % 60).padStart(2, '0');
  return `${hrs}:${mins}:${secs}`;
}

function updateDisplay() {
  document.getElementById('tempo').value = formatTime(seconds);
}

function startTimer() {
  if (isRunning) return;
  isRunning = true;
  timer = setInterval(() => {
    seconds++;
    updateDisplay();
  }, 1000);
}

function pauseTimer() {
  clearInterval(timer);
  isRunning = false;
}

function resetTimer() {
  pauseTimer();
  seconds = 0;
  updateDisplay();
}

// 🌗 MODO ESCURO / CLARO
document.addEventListener('DOMContentLoaded', () => {
  const toggle = document.getElementById('toggle-theme');
  const currentTheme = localStorage.getItem('theme');

  if (currentTheme === 'dark') {
    document.body.classList.add('dark');
    if (toggle) toggle.textContent = '☀️';
  }

  if (toggle) {
    toggle.addEventListener('click', () => {
      document.body.classList.toggle('dark');
      const isDark = document.body.classList.contains('dark');
      toggle.textContent = isDark ? '☀️' : '🌙';
      localStorage.setItem('theme', isDark ? 'dark' : 'light');
    });
  }
});

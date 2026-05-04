(function () {
    const btn  = document.getElementById('darkModeToggle');
    const icon = document.getElementById('darkModeIcon');
    const html = document.documentElement;

    function apply(dark) {
        html.setAttribute('data-theme', dark ? 'dark' : 'light');
        icon.className = dark ? 'bi bi-sun-fill' : 'bi bi-moon-fill';
        localStorage.setItem('theme', dark ? 'dark' : 'light');
    }

    // Applique le thème sauvegardé immédiatement
    const saved = localStorage.getItem('theme');
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    apply(saved ? saved === 'dark' : prefersDark);

    btn.addEventListener('click', function () {
        apply(html.getAttribute('data-theme') !== 'dark');
    });
})();

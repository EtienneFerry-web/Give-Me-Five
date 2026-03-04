const antiSpoiler = document.querySelectorAll('#spoiler');
  antiSpoiler.forEach(spoiler => {
    spoiler.addEventListener('click', () => {
        spoiler.style.display = 'none';
      });
  });



document.querySelectorAll(".pageMovieNote").forEach(movie => {
    const note = parseFloat(movie.dataset.note);
    const starsContainer = movie.querySelector(" .stars");

    starsContainer.innerHTML = "";

    for (let i = 1; i <= 5; i++) {
        const star = document.createElement("i");

        if (note >= i) {
            star.className = "bi bi-star-fill";
        } else if (note >= i - 0.5) {
            star.className = "bi bi-star-half";
        } else {
            star.className = "bi bi-star";
        }

        starsContainer.appendChild(star);
    }
});


window.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.splide').forEach(slider => {
    new Splide(slider, {
      type: 'slide',
      drag: 'free',
      autoWidth: true,
      gap: '0.3rem',
      arrows: false,
      pagination: false,
      focus: false,
    }).mount();
  });
});

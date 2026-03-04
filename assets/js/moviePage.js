/**
 * @file moviePage.js
 * @description Manages anti-spoiler overlays, movie page ratings, and secondary Splide sliders.
 */

/**
 * @function initAntiSpoiler
 * @description Hides the spoiler overlay when a user clicks on it to reveal content.
 * @param {string} #spoiler - The ID of the spoiler element. 
 * Note: If using multiple spoilers, consider using a class (.spoiler) instead of an ID.
 */

const antiSpoiler = document.querySelectorAll('#spoiler');
  antiSpoiler.forEach(spoiler => {
    spoiler.addEventListener('click', () => {
        spoiler.style.display = 'none';
      });
  });

/**
 * @function generatePageMovieStars
 * @description Converts numerical data-note values into Bootstrap star icons for the movie page.
 * @param {number} data-note - The rating value (e.g., 3.5) from the HTML element.
 */

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

/**
 * @function initSecondarySliders
 * @description Initializes all secondary Splide instances with 'slide' mode and free drag.
 * @requires Splide.js
 */

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

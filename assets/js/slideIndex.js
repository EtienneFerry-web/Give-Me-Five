/**
 * @file slideIndex.js
 * @description handles the initialization of the Splide.js carousel and 
 * the dynamic generation of star ratings based on data attributes.
 */

/**
 * @function initSplide
 * @description Initializes the Splide slider with continuous auto-scroll 
 * and responsive breakpoints for different screen sizes.
 */

document.addEventListener('DOMContentLoaded', function () {
  new Splide('.splide', {
    type: 'loop',
    drag: 'free',
    focus: false,
    perPage: 6,
    gap: '2px',
    pagination: false,
    arrows: false,
    autoWidth: true,
    autoHeight: false,
    preloadPages: 3,
    clones: 10,
    lazyLoad: false,
    updateOnMove: true,
    breakpoints: {
      1024: { perPage: 4, gap: '0.5rem' },
      768:  { perPage: 2, gap: '0.5rem' },
    },
    autoScroll: { speed: 2 },
  }).mount(window.splide.Extensions);
});


/**
 * @function generateStars
 * @description Selects all elements with the class .movieNote, reads the 
 * @param {number} data-note - The rating value to convert into stars.
 * @description Injects Bootstrap Icon (bi) classes into the stars container.
 */

document.querySelectorAll(".movieNote").forEach(movie => {
    const note = parseFloat(movie.dataset.note);
    const starsContainer = movie.querySelector(" .stars");

    starsContainer.innerHTML = "";

    for (let i = 1; i <= 5; i++) {
        const star = document.createElement("i");

        if (note >= i) {
            star.className = "bi bi-star-fill";
        } else if (Math.round(note) >= i - 0.5) {
            star.className = "bi bi-star-half";
        } else {
            star.className = "bi bi-star";
        }

        starsContainer.appendChild(star);
    }
});

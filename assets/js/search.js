/**
 * @file search.js
 * @description Generates a visual star rating for the movie detail page.
 */

/**
 * @function generatePageStars
 * @description Selects all elements with the .pageMovieNote class, parses the rating,
 * and dynamically injects the corresponding Bootstrap Icons (Full, Half, or Empty).
 * * @param {string} .pageMovieNote - The container holding the movie data.
 * @param {number} data-note - The numerical rating value (e.g., 4.5).
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

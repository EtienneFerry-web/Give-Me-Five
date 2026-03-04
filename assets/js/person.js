/**
 * @file person.js
 * @description Generates dynamic star ratings for specific person-related movie lists.
 */

/**
 * @function generatePersonStars
 * @description Iterates through elements with the .moviePerson class to convert 
 * numerical data attributes into visual Bootstrap star icons.
 * * @param {string} .moviePerson - The wrapper element for the movie item.
 * @param {number} data-note - The rating value (1-5) extracted from the dataset.
 */

document.querySelectorAll(".moviePerson").forEach(movie => {
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

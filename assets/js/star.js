/**
 * @file star.js
 * @description Manages movie ratings with half-stars support and AJAX updates.
 */

// --- GLOBAL VARIABLES ---
const stars = document.querySelectorAll('.rating i');
const inputNote = document.querySelectorAll('#note');
const noteAverage = document.getElementById('average');
const noteForm = document.getElementById('deleteNoteForm');
var csrfToken = document.querySelector('meta[name="csrf_token"]').content;
let antiSpam = false;
let time;

const urlParams = new URLSearchParams(window.location.search);
const movieId = window.location.pathname.split('/').pop();

// --- INITIALIZATION ---
/** Initial setup when the page is loaded */
document.addEventListener('DOMContentLoaded', initializeStars);

// --- FUNCTIONS ---

/**
 * @brief Sets initial star display based on hidden input values.
 */
function initializeStars() {
    let currentValue = null;
    inputNote.forEach(input => {
        if (input.value && !currentValue) {
            currentValue = parseFloat(input.value);
        }
    });

    if (currentValue !== null && currentValue > 0) {
        stars.forEach(s => {
            const starValue = parseFloat(s.dataset.value);

            if (currentValue % 1 === 0.5 && starValue === Math.ceil(currentValue)) {
                s.classList.remove('bi-star', 'bi-star-fill');
                s.classList.add('bi-star-half');
            } else if (starValue <= currentValue) {
                s.classList.remove('bi-star', 'bi-star-half');
                s.classList.add('bi-star-fill');
            } else {
                s.classList.remove('bi-star-fill', 'bi-star-half');
                s.classList.add('bi-star');
            }
        });
    }
}

/**
 * @brief Synchronizes all rating inputs with the selected value.
 * @param {number} value - The rating value.
 */
function updateNote(value) {
    inputNote.forEach(input => {
        input.value = value;
    });
}

/**
 * @brief Sends the rating to the server via an asynchronous request.
 * @async
 * @param {number} value - The rating to insert.
 */
async function insertNote(value) {
    try {
        const response = await fetch(`${url}movie/note/${movieId}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken
            },
            body: JSON.stringify({ intNote: value })
        });
        
        console.log("rq envoyer");
        if (!response.ok) {
            throw new Error(`HTTP Error: ${response.status}`);
        }

        const data = await response.json();
        noteAverage.textContent = Number.parseFloat(data.average).toFixed(2);
        updateAvg(data.average);

    } catch (erreur) {
        console.error("Problem during recovery:", erreur.message);
    }
}

/**
 * @brief Updates the visual average rating display (non-interactive stars).
 * @param {number} value - The new average value.
 */
function updateAvg(value) {
    const note = parseFloat(value);
    const starsContainer = document.querySelector(".stars");

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
}

// --- EVENT LISTENERS ---

/** Handles star interaction (click) for rating */
stars.forEach(star => {
    star.addEventListener('click', (e) => {
        clearTimeout(time);
        noteForm.classList.remove('d-none', 'd-block');
        
        const rect = star.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const isHalf = x < rect.width / 2;

        let value = parseFloat(star.dataset.value);
        if (isHalf) {
            value -= 0.5;
        }

        updateNote(value);

        // Debounce before sending to server
        time = setTimeout(() => {
            insertNote(value);
        }, 500);

        // Visual update for interactive stars
        stars.forEach(s => {
            const dataValue = parseFloat(s.dataset.value);
            s.classList.remove('bi-star-fill', 'bi-star-half', 'bi-star');

            if (dataValue <= value) {
                s.classList.add('bi-star-fill');
            } else if (dataValue - 0.5 === value) {
                s.classList.add('bi-star-half');
            } else {
                s.classList.add('bi-star');
            }
        });
    });
});

/** Handles the "Share" button click to copy URL */
document.getElementById('shareMovie').addEventListener('click', (e) => {
    navigator.clipboard.writeText(window.location.href);
    e.target.textContent = "URL copiée !";

    setTimeout(() => {
        e.target.innerHTML = "PARTAGER &#8599;";
    }, 1500);
});
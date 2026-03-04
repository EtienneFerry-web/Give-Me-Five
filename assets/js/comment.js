/**
 * @brief Initializes the interactive star rating system.
 * * Sets up click listeners on star icons to handle full and half-star ratings
 * using the mouse position relative to the star's width. Includes a 
 * debounce timer before calling the server-side insertion.
 */

function initStars() {
    const stars = document.querySelectorAll('.rating i');
    const inputNote = document.getElementById('note');
    let antiSpam = false;

    stars.forEach(star => {
      star.addEventListener('click', (e) => {

        clearTimeout(time);

        const rect = star.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const isHalf = x < rect.width / 2;

        let value = parseFloat(star.dataset.value);
        if (isHalf) {
          value -= 0.5;
        }

        inputNote.value = value;

        time = setTimeout(() => {
          insertNote(value);
        }, 500);


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
}

/**
 * @brief Renders the visual state of stars based on a given value.
 * @param {number|string} value - The rating value to display.
 * * Iterates through star elements and assigns the correct Bootstrap icon
 * class (full, half, or empty) to match the provided rating.
 */

function renderStars(value) {
    const stars = document.querySelectorAll('.rating i');
    const note = parseFloat(value);

    stars.forEach(star => {
        const sVal = parseFloat(star.dataset.value);

        star.classList.remove('bi-star', 'bi-star-fill', 'bi-star-half');

        if (note >= sVal) {
            star.classList.add('bi-star-fill');
        } else if (note === sVal - 0.5) {
            star.classList.add('bi-star-half');
        } else {
            star.classList.add('bi-star');
        }
    });
}

/**
 * @brief Transforms a static comment container into an editable form.
 * @param {number|string} reviewId - The unique ID of the review/comment.
 * * Dynamically injects an HTML form into the comment container, pre-filling it
 * with current data and re-initializing the star system for the new form.
 */

function enableEdit(reviewId) {
  const container = document.querySelector(`#comment-container-${reviewId}`);
  const movieId = document.getElementById('movie').dataset.movie;
  const currentText = container.querySelector('.comment-text').innerText;
  const currentNote = container.querySelector('.note-display').innerText;

  container.innerHTML = `
      <p>Si votre commentaire est modifier les like réinisialiter !</p>
      <form method="post" class="py-3">
          <div class="py-2">
              <label for="comment" class="form-label fw-bold">Donnez votre avis</label>
              <textarea
                  id="comment"
                  name="comment"
                  class="form-control"
                  rows="4"
                  placeholder="Votre commentaire"
              >${currentText}</textarea>
          </div>
          <div class="row align-items-center">
              <div class="col-md-8 rating user-select-none text-center text-md-start py-2 mt-auto">
                  <span class="spanMovie">Votre Note :
                  <!--Data value for ,5 with double click-->
                  <i class="bi bi-star" data-value="1"></i>
                  <i class="bi bi-star" data-value="2"></i>
                  <i class="bi bi-star" data-value="3"></i>
                  <i class="bi bi-star" data-value="4"></i>
                  <i class="bi bi-star" data-value="5"></i>
                  </span>
                  <!--input value for rating score-->
                  <input type="hidden" name="rating" id="note" value="${currentNote}" class="form-control {if isset($arrError['noteRating'])} is-invalid {/if}">
              </div>
              <input type="hidden" name="csrf_token" value="${csrfToken}">
              <input type="hidden" name="id" value="${reviewId}">
              <input type="hidden" name="movieId" value="${movieId}">
              <div method="post" class="d-block ms-auto col-auto">
                <button type="button" class="spanMovie border-0 edit-comment bg-transparent" onclick="location.reload()">Annuler</button>
              </div>
              <div method="post" class="d-block ms-auto col-auto">
                  <button type="submit" class="spanMovie border-0 edit-comment bg-transparent">Enregistrer</button>
              </div>

          </div>
      </form>
    `;
  renderStars(currentNote);
  initStars();
}

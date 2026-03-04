/**
 * @file person.js
 * @description Manages the data transfer between the trigger button and the ban confirmation modal.
 */

/**
 * @function initBanModal
 * @description Listens for the Bootstrap modal 'show' event to dynamically 
 * populate the modal fields with the target user's ID and Username.
 * * @param {string} data-userid - The unique ID of the user to be banned.
 * @param {string} data-pseudo - The display name/nickname of the user.
 */

document.addEventListener('DOMContentLoaded', function () {
    const modalBan = document.getElementById('modalBan');
    if (modalBan) {
        modalBan.addEventListener('show.bs.modal', function (event) {

            const button = event.relatedTarget;

            const userId = button.getAttribute('data-userid');
            const pseudo = button.getAttribute('data-pseudo');

            const inputId = modalBan.querySelector('#modalIdUser');
            const spanPseudo = modalBan.querySelector('#modalPseudo');

            inputId.value = userId;
            spanPseudo.textContent = pseudo;
        });
    }
});

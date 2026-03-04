/**
 * @file permission.js
 * @description Initializes all Bootstrap tooltips found on the page.
 */

/**
 * @function initTooltips
 * @description Scans the DOM for any elements with the 'data-bs-toggle="tooltip"' 
 * attribute and initializes them using the Bootstrap Tooltip class.
 * @requires bootstrap.bundle.js
 */

document.addEventListener('DOMContentLoaded', function () {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl)
    })
});
/**
 * @file autoCompletion.js
 * @description Search bar logic with autocomplete and local history.
 */

// --- GLOBAL VARIABLES ---
const searchForm = document.querySelector('#formSearch');
const searchBar = document.getElementById('searchBar');
const sugesContainer = document.getElementById('suggestions');
// var csrfToken = document.querySelector('meta[name="csrf_token"]').content;
let historique = JSON.parse(localStorage.getItem('allSearch')) || [];
let timer;

// --- INITIALIZATION ---
if (searchBar.value.trim() !== '') {
    saveSearch(searchBar.value);
}

// --- FUNCTIONS ---

/**
 * @brief Saves the search keyword to localStorage.
 * @param {string} keyword - The term to save.
 */
function saveSearch(keyword) {
    if (!historique.some(item => item.label === keyword)) {
        historique.unshift({ label: keyword });
    }
    localStorage.setItem('allSearch', JSON.stringify(historique.slice(0, 5)));
}

/**
 * @brief Fetches suggestion data from the server.
 */
async function searchData() {
    const keywords = searchBar.value;
    try {
        const response = await fetch(`${url}search/autoComplete`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken
            },
            body: JSON.stringify({ keywords: keywords })
        });
        
        console.log("rq envoyer");
        if (!response.ok) {
            throw new Error(`HTTP Error: ${response.status}`);
        }

        const data = await response.json();
        affichSuggestion(data);

    } catch (error) {
        console.error("Search error:", error.message);
    }
}

/**
 * @brief Renders the suggestion list in the DOM.
 * @param {Array} content - List of search results or history.
 */
function affichSuggestion(content) {
    sugesContainer.innerHTML = '';
    sugesContainer.style.display = 'flex';
    searchBar.style.borderRadius = '24px 24px 0 0';
    
    if (content.length > 0) {
        content.forEach(index => {
            const div = document.createElement('div');
            div.classList.add('suggestion-item');
            div.id = 'divSugesstion';

            if (index['type'] === 'movie') {
                div.innerHTML = `<i class="bi bi-film fs-4"></i>    ${index['label']}`;
            } else if(index['type'] === 'person'){
                div.innerHTML = `<i class="bi-star-fill fs-4"></i>    ${index['label']}`;
            } else if(index['type'] === 'user'){
                div.innerHTML = `<i class="bi bi-person fs-4"></i>    ${index['label']}`;
            } else {
                div.innerHTML = `<i class="bi bi-clock-history fs-4"></i>    ${index['label']}`;
            }

            sugesContainer.appendChild(div);
        });
        clickContent();
    } else {
        sugesContainer.innerHTML = "<div class='suggestion-item text-center'>Aucun Resultat trouvé ! </div>";
    }
}

/**
 * @brief Attaches click events to generated suggestion items.
 */
function clickContent() {
    const divSug = sugesContainer.querySelectorAll('#divSugesstion');
    divSug.forEach(e => {
        e.addEventListener('click', () => {
            const content = e.textContent;
            searchBar.value = content.trim();
            searchForm.submit();
        });
    });
}

// --- EVENT LISTENERS ---

searchForm.addEventListener('submit', function (e) {
    if (searchBar.value.trim() === '') {
        e.preventDefault();
        searchBar.classList.add('is-invalid');
    }
});

searchForm.addEventListener('click', function (e) {
    e.stopPropagation();
    console.log('input');
});

document.addEventListener('click', () => {
    searchBar.style.borderRadius = '24px';
    sugesContainer.style.display = 'none';
    console.log('document');
});

searchBar.addEventListener('focus', () => {
    if (searchBar.value.trim() === '') {
        if (historique.length > 0) {
            affichSuggestion(historique);
        }
    } else {
        searchData();
    }
});

searchBar.addEventListener('input', () => {
    searchBar.classList.remove('is-invalid');
    console.log('test');
    clearTimeout(timer);
    
    if (searchBar.value.trim() !== '') {
        if (!sugesContainer.querySelector('.ellipsis-loader')) {
            sugesContainer.innerHTML = `<div class="suggestion-item ellipsis-loader">
                                          <span></span><span></span><span></span>
                                        </div>`;
        }
        timer = setTimeout(() => {
            searchData();
        }, 200);
    } else {
        affichSuggestion(historique);
    }
});
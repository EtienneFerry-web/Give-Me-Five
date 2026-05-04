{extends file="views/layout_view.tpl"}
{block name="title" prepend}Recherche de films — {/block}

{block name="content"}
<section class="container-fluid px-3 px-md-4 py-4">

    {* ── En-tête ── *}
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h1 class="fw-bold mb-0">
                <i class="bi bi-film me-2"></i>
                {if $searchedTitle != ''}
                    Résultats pour "<span class="text-primary">{$searchedTitle|escape:'html'}</span>"
                {else}
                    Explorer les films
                {/if}
            </h1>
            <p class="text-muted small mb-0 mt-1">Catalogue de films</p>
        </div>
        <a href="{$smarty.env.BASE_URL}movie/home" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-house me-1"></i> Accueil
        </a>
    </div>

    <div class="row g-4">

        {* ── Sidebar filtres ── *}
        <aside class="col-12 col-lg-3">
            <div class="card border-0 shadow-sm rounded-4 sticky-top" style="top: 80px;">
                <div class="card-body p-4">
                    <h5 class="fw-bold mb-3">
                        <i class="bi bi-funnel me-2"></i>Filtres
                    </h5>

                    <form method="GET" action="{$smarty.env.BASE_URL}rapidMovie/search" id="filterForm">

                        {* Recherche par titre *}
                        <div class="mb-3">
                            <label class="form-label fw-semibold small text-uppercase text-muted">Titre</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0">
                                    <i class="bi bi-search text-muted"></i>
                                </span>
                                <input
                                    type="text"
                                    name="title"
                                    class="form-control border-start-0 ps-0"
                                    placeholder="Ex : Inception…"
                                    value="{$searchedTitle|escape:'html'}"
                                >
                            </div>
                            <small class="text-muted">La recherche par titre ignore les filtres ci-dessous.</small>
                        </div>

                        <hr class="my-3">

                        {* Genre *}
                        <div class="mb-3">
                            <label class="form-label fw-semibold small text-uppercase text-muted">Genre</label>
                            <select name="genre" class="form-select form-select-sm">
                                {foreach from=$arrGenres key=slug item=label}
                                    <option value="{$slug}" {if $activeGenre == $slug}selected{/if}>
                                        {$label}
                                    </option>
                                {/foreach}
                            </select>
                        </div>

                        {* Pays *}
                        <div class="mb-3">
                            <label class="form-label fw-semibold small text-uppercase text-muted">Disponible en</label>
                            <select name="country" class="form-select form-select-sm">
                                {foreach from=$arrCountries key=code item=name}
                                    <option value="{$code}" {if $activeCountry == $code}selected{/if}>
                                        {$name}
                                    </option>
                                {/foreach}
                            </select>
                        </div>

                        {* Tri *}
                        <div class="mb-3">
                            <label class="form-label fw-semibold small text-uppercase text-muted">Trier par</label>
                            <select name="order_by" class="form-select form-select-sm">
                                {foreach from=$arrSortOptions key=key item=label}
                                    <option value="{$key}" {if $activeOrder == $key}selected{/if}>
                                        {$label}
                                    </option>
                                {/foreach}
                            </select>
                        </div>

                        {* Années *}
                        <div class="mb-3">
                            <label class="form-label fw-semibold small text-uppercase text-muted">Année de sortie</label>
                            <div class="row g-2">
                                <div class="col-6">
                                    <input
                                        type="number"
                                        name="year_min"
                                        class="form-control form-control-sm"
                                        placeholder="De"
                                        min="1900"
                                        max="{$smarty.now|date_format:'%Y'}"
                                        value="{if $activeYearMin}{$activeYearMin}{/if}"
                                    >
                                </div>
                                <div class="col-6">
                                    <input
                                        type="number"
                                        name="year_max"
                                        class="form-control form-control-sm"
                                        placeholder="À"
                                        min="1900"
                                        max="{$smarty.now|date_format:'%Y'}"
                                        value="{if $activeYearMax}{$activeYearMax}{/if}"
                                    >
                                </div>
                            </div>
                        </div>

                        {* Note minimale *}
                        <div class="mb-4">
                            <label class="form-label fw-semibold small text-uppercase text-muted">
                                Note minimale : <span id="ratingDisplay">{if $activeRatingMin}{$activeRatingMin}{else}0{/if}</span>/100
                            </label>
                            <input
                                type="range"
                                name="rating_min"
                                class="form-range"
                                min="0"
                                max="100"
                                step="5"
                                value="{if $activeRatingMin}{$activeRatingMin}{else}0{/if}"
                                id="ratingRange"
                                oninput="document.getElementById('ratingDisplay').textContent = this.value"
                            >
                            <div class="d-flex justify-content-between">
                                <small class="text-muted">0</small>
                                <small class="text-muted">50</small>
                                <small class="text-muted">100</small>
                            </div>
                        </div>

                        <div class="d-grid gap-2">
                            <button type="submit" class="btnCustom">
                                <i class="bi bi-search me-1"></i> Rechercher
                            </button>
                            <a href="{$smarty.env.BASE_URL}rapidMovie/search" class="btn btn-outline-secondary btn-sm">
                                <i class="bi bi-x-circle me-1"></i> Réinitialiser
                            </a>
                        </div>

                    </form>
                </div>
            </div>
        </aside>

        {* ── Résultats ── *}
        <div class="col-12 col-lg-9">

            {* Filtres actifs *}
            {if $boolHasFilters}
                <div class="d-flex flex-wrap gap-2 mb-3">
                    {if $searchedTitle != ''}
                        <span class="badge bg-primary rounded-pill px-3 py-2">
                            <i class="bi bi-search me-1"></i>{$searchedTitle|escape:'html'}
                        </span>
                    {/if}
                    {if $activeGenre != ''}
                        <span class="badge bg-secondary rounded-pill px-3 py-2">
                            <i class="bi bi-tag me-1"></i>{$arrGenres[$activeGenre]|escape:'html'}
                        </span>
                    {/if}
                    {if $activeYearMin || $activeYearMax}
                        <span class="badge bg-secondary rounded-pill px-3 py-2">
                            <i class="bi bi-calendar me-1"></i>
                            {if $activeYearMin}{$activeYearMin}{else}…{/if}
                            –
                            {if $activeYearMax}{$activeYearMax}{else}…{/if}
                        </span>
                    {/if}
                    {if $activeRatingMin}
                        <span class="badge bg-warning text-dark rounded-pill px-3 py-2">
                            <i class="bi bi-star-fill me-1"></i>≥ {$activeRatingMin}/100
                        </span>
                    {/if}
                </div>
            {/if}

            {* Erreurs API *}
            {if isset($arrError) && $arrError|@count > 0}
                <div class="alert alert-danger d-flex align-items-start gap-3 rounded-3 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill fs-4 flex-shrink-0 mt-1"></i>
                    <div>
                        <strong>Une erreur est survenue :</strong><br>
                        {foreach from=$arrError item=strError}
                            <span>{$strError|escape:'html'}</span>
                        {/foreach}
                    </div>
                </div>

            {* Grille de films *}
            {elseif isset($arrMovieToDisplay) && $arrMovieToDisplay|@count > 0}
                <p class="text-muted small mb-3">
                    <strong>{$arrMovieToDisplay|@count}</strong> film{if $arrMovieToDisplay|@count > 1}s{/if} trouvé{if $arrMovieToDisplay|@count > 1}s{/if}
                </p>

                <div class="row row-cols-2 row-cols-sm-2 row-cols-md-3 row-cols-xl-4 g-3" id="moviesGrid">
                    {foreach from=$arrMovieToDisplay item=objMovie}
                    <div class="col">
                        <div class="card h-100 border-0 shadow-sm rounded-4 movie-card overflow-hidden">

                            <a href="{$smarty.env.BASE_URL}movie/moviePage/{$objMovie->getId()}" class="d-block position-relative movie-poster-wrap">
                                {if $objMovie->getPhoto()}
                                    <img
                                        src="{$objMovie->getPhoto()}"
                                        alt="{$objMovie->getTitle()|escape:'html'}"
                                        class="card-img-top movie-poster"
                                        loading="lazy"
                                    >
                                {else}
                                    <div class="movie-poster-placeholder d-flex align-items-center justify-content-center bg-dark text-white">
                                        <i class="bi bi-film fs-1 opacity-25"></i>
                                    </div>
                                {/if}

                                {* Badge note /5 *}
                                {if $objMovie->getRating() > 0}
                                    <span class="position-absolute top-0 end-0 m-2 badge bg-warning text-dark rounded-pill shadow-sm">
                                        <i class="bi bi-star-fill me-1"></i>{$objMovie->getRating()|string_format:"%.1f"}/5
                                    </span>
                                {/if}

                                {* Overlay au hover *}
                                <div class="movie-overlay d-flex align-items-center justify-content-center">
                                    <span class="btn btn-light btn-sm rounded-pill">
                                        <i class="bi bi-play-fill me-1"></i>Voir le film
                                    </span>
                                </div>
                            </a>

                            <div class="card-body p-3 d-flex flex-column">
                                <h6 class="card-title fw-bold mb-1 text-truncate-2">
                                    {$objMovie->getTitle()|escape:'html'}
                                </h6>
                                {if $objMovie->getRelease_date()}
                                    <small class="text-muted mb-2">
                                        <i class="bi bi-calendar3 me-1"></i>{$objMovie->getRelease_date()}
                                    </small>
                                {/if}
                                {if $objMovie->getDescription()}
                                    <p class="card-text text-muted small text-truncate-3 mb-0 flex-grow-1">
                                        {$objMovie->getSummary(120)}
                                    </p>
                                {/if}
                            </div>

                        </div>
                    </div>
                    {/foreach}
                </div>

            {* Aucun résultat *}
            {else}
                <div class="text-center py-5">
                    <i class="bi bi-search fs-1 text-muted opacity-25 d-block mb-3"></i>
                    <h4 class="fw-bold">Aucun film trouvé</h4>
                    <p class="text-muted">
                        {if $searchedTitle != ''}
                            Aucun résultat pour "<strong>{$searchedTitle|escape:'html'}</strong>".
                        {else}
                            Aucun film ne correspond aux filtres sélectionnés.
                        {/if}
                    </p>
                    <a href="{$smarty.env.BASE_URL}rapidMovie/search" class="btn btn-outline-primary mt-2">
                        <i class="bi bi-arrow-counterclockwise me-1"></i>Réinitialiser les filtres
                    </a>
                </div>
            {/if}

        </div>
    </div>
</section>

<style>
.movie-card {
    transition: transform .25s ease, box-shadow .25s ease;
}
.movie-card:hover {
    transform: translateY(-6px);
    box-shadow: 0 12px 30px rgba(0,0,0,.15) !important;
}
.movie-poster-wrap {
    overflow: hidden;
    height: 280px;
}
.movie-poster {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform .35s ease;
}
.movie-poster-placeholder {
    width: 100%;
    height: 100%;
}
.movie-card:hover .movie-poster {
    transform: scale(1.05);
}
.movie-overlay {
    position: absolute;
    inset: 0;
    background: rgba(0,0,0,.45);
    opacity: 0;
    transition: opacity .25s ease;
}
.movie-card:hover .movie-overlay {
    opacity: 1;
}
.text-truncate-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}
.text-truncate-3 {
    display: -webkit-box;
    -webkit-line-clamp: 3;
    -webkit-box-orient: vertical;
    overflow: hidden;
}
@media (max-width: 991.98px) {
    .movie-poster-wrap { height: 220px; }
}
</style>
{/block}

<div class="row py-3 border-bottom">

    {* Colonne image *}
    <div class="col-4 col-md-3 text-center my-auto">
        <a href="{$smarty.env.BASE_URL}movie/moviePage/{$objMovie->getId()}">
            {if $objMovie->getPhoto() && $objMovie->getPhoto()|substr:0:4 == 'http'}
                {* Image venant de l'API : URL absolue *}
                <img
                    src="{$objMovie->getPhoto()}"
                    alt="{$objMovie->getTitle()|escape:'html'}"
                    class="img-fluid rounded shadow-sm"
                    style="max-height:220px; object-fit:cover; width:100%;"
                    loading="lazy"
                >
            {elseif $objMovie->getPhoto()}
                {* Image locale stockée dans assets/img/movie/ *}
                <img
                    src="{$smarty.env.BASE_URL}assets/img/movie/{$objMovie->getPhoto()}"
                    alt="{$objMovie->getTitle()|escape:'html'}"
                    class="img-fluid rounded shadow-sm"
                    style="max-height:220px; object-fit:cover; width:100%;"
                    loading="lazy"
                >
            {else}
                {* Placeholder si aucune image *}
                <div class="bg-secondary d-flex align-items-center justify-content-center rounded"
                     style="height:180px; width:100%;">
                    <i class="bi bi-film fs-1 text-white opacity-50"></i>
                </div>
            {/if}
        </a>
    </div>

    {* Colonne informations *}
    <div class="col-8 col-md-9 text-start d-flex flex-column justify-content-center gap-2">

        {* Titre *}
        <a href="{$smarty.env.BASE_URL}movie/moviePage/{$objMovie->getId()}" class="text-decoration-none text-dark">
            <h2 class="h5 fw-bold mb-1">{$objMovie->getTitle()|escape:'html'}</h2>
        </a>

        {* Année de sortie *}
        {if $objMovie->getRelease_date()}
            <small class="text-muted">
                <i class="bi bi-calendar3 me-1"></i>{$objMovie->getRelease_date()}
            </small>
        {/if}

        {* Synopsis via getSummary (tronque proprement à 160 caractères) *}
        <p class="mb-1 text-muted small">
            {if $objMovie->getDescription()}
                {$objMovie->getSummary(160)}
            {else}
                <em>Aucun synopsis disponible.</em>
            {/if}
        </p>

        {* Note *}
        {if $objMovie->getRating()}
            <span class="pageMovieNote spanMovie d-flex align-items-center gap-1" data-note="{$objMovie->getRating()}">
                <span class="stars d-inline-block"></span>
                <span class="note d-inline-block small text-warning fw-semibold">
                    <i class="bi bi-star-fill"></i> {$objMovie->getRating()}
                </span>
            </span>
        {/if}

        {* Likes *}
        <span class="movieLikes d-flex align-items-center gap-1 spanMovie text-muted small">
            <i class="bi bi-heart-fill text-danger"></i>
            <span>{$objMovie->getLike()}</span>
        </span>

    </div>
</div>

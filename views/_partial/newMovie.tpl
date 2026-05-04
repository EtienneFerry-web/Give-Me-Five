<li class="splide__slide" style="width:180px;">
    <div class="border-0 shadow-sm rounded-4 movie-card overflow-hidden" style="width:180px;">
        <a href="{$smarty.env.BASE_URL}movie/moviePage/{$objMovie->getId()}" class="d-block position-relative" style="height:260px;">
            {if $objMovie->getPhoto()|substr:0:4 == 'http'}
                <img src="{$objMovie->getPhoto()}" alt="{$objMovie->getTitle()|escape:'html'}" class="movie-poster" loading="lazy" style="width:100%;height:100%;object-fit:cover;">
            {elseif $objMovie->getPhoto() != ''}
                <img src="{$smarty.env.BASE_URL}assets/img/movie/{$objMovie->getPhoto()}" alt="{$objMovie->getTitle()|escape:'html'}" class="movie-poster" loading="lazy" style="width:100%;height:100%;object-fit:cover;">
            {else}
                <div class="d-flex align-items-center justify-content-center bg-dark text-white" style="width:100%;height:100%;">
                    <i class="bi bi-film fs-1 opacity-25"></i>
                </div>
            {/if}

            {if $objMovie->getRating() > 0}
                <span class="position-absolute top-0 end-0 m-2 badge bg-warning text-dark rounded-pill shadow-sm" style="font-size:.7rem;">
                    <i class="bi bi-star-fill me-1"></i>{$objMovie->getRating()|string_format:"%.1f"}/5
                </span>
            {/if}

            <div class="movie-overlay d-flex align-items-center justify-content-center">
                <span class="btn btn-light btn-sm rounded-pill">
                    <i class="bi bi-play-fill me-1"></i>Voir le film
                </span>
            </div>
        </a>

        <div class="p-2 bg-white">
            <p class="fw-bold mb-1 small text-truncate" title="{$objMovie->getTitle()|escape:'html'}">{$objMovie->getTitle()|escape:'html'}</p>
            <small class="text-muted"><i class="bi bi-heart-fill text-danger me-1"></i>{$objMovie->getLike()}</small>
        </div>
    </div>
</li>

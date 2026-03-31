<li class="splide__slide hoverMovie">
    <a href="{$smarty.env.BASE_URL}movie/moviePage/{$objMovie->getId()}">
        {if $objMovie->getPhoto()|substr:0:4 == 'http'}
            <img src="{$objMovie->getPhoto()}" loading="eager" alt="Couverture de film"/>
        {else}
            <img src="{$smarty.env.BASE_URL}assets/img/movie/{$objMovie->getPhoto()}" loading="eager" alt="Couverture de film"/>
        {/if}

        <span class="movieNote spanMovie" data-note="{$objMovie->getRating()}">
            <span class="stars"></span>
        </span>

        <span class="movieLikes">
              <i class="bi bi-heart-fill"></i>{$objMovie->getLike()}
        </span>
    </a>
</li>

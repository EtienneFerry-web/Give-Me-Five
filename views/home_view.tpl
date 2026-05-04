{extends file="views/layout_view.tpl"}
{block name="title" prepend}Accueil{/block}
{block name="description"}Bienvenue sur notre accueil !!!!{/block}

{block name="css_variation"}
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@splidejs/splide@4.1.4/dist/css/splide-core.min.css">
    <style>
    .movie-card {
        transition: transform .25s ease, box-shadow .25s ease;
    }
    .movie-card:hover {
        transform: translateY(-6px);
        box-shadow: 0 12px 30px rgba(0,0,0,.15) !important;
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
    </style>
{/block}

{block name="content"}
    
    <section id="hero" class=" container  row mx-auto py-5">
        <div class="col-12 col-md-6 d-flex flex-column justify-content-center text-center text-md-start  py-5">
            {if !isset($smarty.session.user)}
            <h1>Bienvenue sur give me five</h1>
            <p class="py-3">Connectez-vous ou créez un compte pour accéder à toutes nos fonctionnalités et partager votre avis sur vos films préférés !</p>
            <div>
                <a href="{$smarty.env.BASE_URL}user/login" class="btnCustom ">Se connecter</a>
                <a href="{$smarty.env.BASE_URL}user/createAccount" class="btnCustom ">S'incrire</a>
            </div>
            {else}
            <h1>Bienvenue {$pseudo} </h1>

            <p class="py-3">Faites-nous découvrir votre univers ! Partagez vos pépites et donnez une note à vos classiques favoris.</p>
            {/if}
        </div>

        <div class="col-12 col-md-6 text-center py-5 logo">
            <img src="{$smarty.env.BASE_URL}assets/img/logo_givemefive.png" alt="icon du site">
        </div>
    </section>
    <section id="newMovie" class="container-fluid py-5 text-center">
      <h2>Les Nouveautés du mois</h2>
      <div class="splide py-5">
        <div class="splide__track">
          <ul class="splide__list">
            {foreach from=$arrMovieToDisplay item=objMovie}
              {include file="views/_partial/newMovie.tpl"}
            {/foreach}
          </ul>
        </div>
      </div>
    </section>

    <section id="topRated" class="container-fluid py-5 text-center">
      <h2>Les Mieux Notés</h2>
      <div class="splide py-5">
        <div class="splide__track">
          <ul class="splide__list">
            {foreach from=$arrTopRatedToDisplay item=objMovie}
              {include file="views/_partial/newMovie.tpl"}
            {/foreach}
          </ul>
        </div>
      </div>
    </section>

    <section id="mostPopular" class="container-fluid py-5 text-center">
      <h2>Les Plus Aimés</h2>
      <div class="splide py-5">
        <div class="splide__track">
          <ul class="splide__list">
            {foreach from=$arrMostPopularToDisplay item=objMovie}
              {include file="views/_partial/newMovie.tpl"}
            {/foreach}
          </ul>
        </div>
      </div>
    </section>
{/block}

{block name="js"}

    <script src="https://cdn.jsdelivr.net/npm/@splidejs/splide-extension-auto-scroll@0.5.3/dist/js/splide-extension-auto-scroll.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@splidejs/splide@4.1.4/dist/js/splide.min.js"></script>
    <script src="{$smarty.env.BASE_URL}assets/js/slideIndex.js"></script>

{/block}

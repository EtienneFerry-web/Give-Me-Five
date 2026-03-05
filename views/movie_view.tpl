{extends file="views/layout_view.tpl"}
{block name="title" prepend}{$objMovie->getTitle()}{/block}
{block name="description"}Voici la page {$objMovie->getTitle()} !{/block}

{block name="css_variation"}
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@splidejs/splide@4.1.4/dist/css/splide-core.min.css">
<link rel="stylesheet" href="{$smarty.env.BASE_URL}assets/css/slideMovie.css">
{/block}

{block name="content"}
<section class="container-xxl row mx-auto" id="movie">
    <div class="col-12 col-md-4 py-1 py-md-5 text-center my-auto">
        <h1 class="d-block d-md-none">{$objMovie->getTitle()}</h1>
        <img src="{$smarty.env.BASE_URL}assets/img/movie/{$objMovie->getPhoto()}" alt="" class="img-fluid w-75 w-md-50">
        <div class="py-3 text-center w-75 w-md-50 mx-auto">
            <span class="pageMovieNote spanMovie" data-note="{$objMovie->getRating()}">
                <span class="stars d-inline-block"></span>
                <span class="note d-inline-block" id="average" >{$objMovie->getRating()}</span>
            </span>
            <span class="movieLikes py-2 d-flex gap-1 spanMovie justify-content-center border-0 bg-transparent w-100 p-0 text-reset"><i class="bi bi-heart-fill me-1"></i> {$objMovie->getLike()}</span>
        </div>
    </div>
<div class="col-12 col-md-8 py-3 py-md-5 text-center text-md-start">
    <h1 class="d-md-block d-none mb-3">{$objMovie->getTitle()}</h1>

    <div class="mb-3">
        <span class="spanMovie d-block py-1"><strong>Durée :</strong> {$objMovie->getLength()}</span>
        <span class="spanMovie d-block py-1"><strong>Date de sortie :</strong> {$objMovie->getDateFormat()}</span>
        <span class="spanMovie d-block py-1"><strong>Pays :</strong> {$objMovie->getCountry()}</span>
    </div>

    <p class="px-2 px-md-0 mb-4">{$objMovie->getDescription()}</p>

    <div class="py-3 py-md-4">
        <h3 class="mb-3">Casting</h3>
        <div class="row g-2 justify-content-center justify-content-md-start">
            {foreach from=$arrPersToDisplay item=objPerson}
                <div class="col-6 col-sm-4 col-md-3">
                    <a class="spanMovie d-block text-truncate" href="{$smarty.env.BASE_URL}person/personPage/{$objPerson->getId()}">
                        {$objPerson->getFullName()}
                    </a>
                </div>
            {foreachelse}
                <p class="text-muted py-3 m-0">Nous n'avons pas le casting de ce film !</p>
            {/foreach}
        </div>
    </div>

    <div class="d-flex flex-wrap align-items-center gap-3 justify-content-center justify-content-md-start mb-4">
        <a href="{$objMovie->getTrailer()}" target="_blank" class="spanMovie link">Voir le trailer &#8599;</a>
        <a id="shareMovie" class="spanMovie link" style="cursor:pointer;">Partager &#8599;</a>
        {if $curDate->format('Y-m-d') < $objMovie->getRelease_date()}
        <a href="{$smarty.env.BASE_URL}movie/addToCalendar/{$objMovie->getId()}" 
               class="btn btn-outline-dark btn-sm" 
               title="Ajouter la sortie à mon agenda">
                <i class="bi bi-calendar-plus"></i>
        </a>
        {/if}
    </div>

    
    {if isset($smarty.session.user) && $curDate->format('Y-m-d') >= $objMovie->getRelease_date()}
    <div class="row g-3 justify-content-center justify-content-md-start align-items-center">
        <div class="col-12 col-sm-auto">
            <form method="POST">
                <input type="hidden" name="likeMovieBtn" value="{$objMovie->getId()}">
                <button type="submit" class="movieLikes d-flex align-items-center gap-2 spanMovie border-0 bg-transparent p-0 mx-auto mx-md-0" style="cursor: pointer;">
                    Liker : {if $objMovie->getUser_liked()}<i class="bi bi-heart-fill fs-4"></i>{else} <i class="bi bi-heart fs-4"></i>{/if}
                </button>
                <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
            </form>
        </div>

        <div class="d-flex flex-row align-items-center justify-content-center justify-content-md-start gap-2 col-auto">
            <div class="col-auto">
                <form method="post" class="m-0">
                    <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                    <div class="rating user-select-none d-flex align-items-center gap-1">
                        <span class="spanMovie me-2">Votre Note :</span>
                        <i class="bi bi-star fs-4" data-value="1"></i>
                        <i class="bi bi-star fs-4" data-value="2"></i>
                        <i class="bi bi-star fs-4" data-value="3"></i>
                        <i class="bi bi-star fs-4" data-value="4"></i>
                        <i class="bi bi-star fs-4" data-value="5"></i>
                        <input type="hidden" name="rating" id="note" value="{$objMovie->getNoteUser()}" class="form-control {if isset($arrError['noteRating'])} is-invalid {/if}">
                    </div>
                </form>
            </div>

            <div class="col-auto">
                <form method="post" class="{if $objMovie->getNoteUser() == 0 }d-none{/if} m-0" id="deleteNoteForm">
                    <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                    <button class="border-0 bg-transparent p-0 d-flex align-items-center" type="submit" name="deleteNoteUser" style="cursor: pointer;">
                        <i class="bi bi-trash fs-4"></i>
                    </button>
                </form>
            </div>
        </div>


    <div class="mt-4">
        <button class="border-0 bg-transparent p-0" data-bs-toggle="modal" data-bs-target="#reportModal" title="Signaler">
            {if $objMovie->getReported() == 0}
                <i class="bi bi-flag fs-3"></i>
            {else}
                <i class="bi bi-flag-fill fs-3"></i>
            {/if}
        </button>
    </div>
{/if}
    <div class="modal fade" id="reportModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <form method="POST" class="modal-content">
                <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                <div class="modal-header border-0">
                    <h5 class="modal-title">Signaler : {$objMovie->getTitle()}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body text-center text-md-start">
                    {if $objMovie->getReported() == 0}
                        <p>Pour que votre signalement soit pris en charge, veuillez renseigner la raison :</p>
                        <textarea name="repMovie" class="form-control" rows="4" placeholder="Raison du signalement..."></textarea>
                    {else}
                        <p>Voulez-vous vraiment supprimer votre signalement ?</p>
                    {/if}
                </div>

                <div class="modal-footer border-0 justify-content-center">
                    <button type="button" class="btn btn-outline-dark px-4" data-bs-dismiss="modal">Annuler</button>
                    {if $objMovie->getReported() == 0}
                        <button type="submit" class="btn btn-outline-success px-4">Valider</button>
                    {else}
                        <button type="submit" name="repDelete" value="delete" class="btn btn-outline-danger px-4">Supprimer</button>
                    {/if}
                </div>
            </form>
        </div>
    </div>
</div>
</section>

{if count($arrImagesToDisplay) > 0 || isset($smarty.session.user) && $curDate->format('Y-m-d') >= $objMovie->getRelease_date()}
<section  id="imgMovie" class="container py-5 text-center">
    <h2>Images du film</h2>
    {if count($arrImagesToDisplay) < 20 && isset($smarty.session.user)}
    <form method="post" class="row text-center" enctype="multipart/form-data">
        <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
        <div class="col-10 p-2 mx-auto">
            <input type="file" class="form-control" accept="image/*" name="images">
        </div>
        <button type="submit" class="btnCustom py-2 col-10 mx-auto">Enregistrer</button>
    </form>
    {/if}
    <div class="splide">
      <div class="splide__track">
        <ul class="splide__list">
        {foreach from=$arrImagesToDisplay item=objImage}
            <li class="splide__slide">
                <img src="{$smarty.env.BASE_URL}assets/img/movie/{$objImage->getPhoto()}" />
            </li>
          {/foreach}
        </ul>
      </div>
    </div>
</section>
{/if}
{if $curDate->format('Y-m-d') >= $objMovie->getRelease_date()}
{if isset($smarty.session.user)}
    <section id="addComment" class="container text-center py-5">
        <h2>Avis</h2>
        <div class="text-start py-2">
            <form method="post">
                <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                <div class="py-2">
                    <label for="comment" class="form-label fw-bold">Donnez votre avis</label>
                    <textarea
                        id="comment"
                        name="com_comment"
                        class="form-control {if isset($arrError['com_comment'])} is-invalid {/if}"
                        rows="4"
                        placeholder="Écrivez votre commentaire..."
                    >{$strComment}</textarea>
                </div>
                <div class="row align-items-center">
                    <div class="col-md-8 rating user-select-none text-center text-md-start py-2">
                        <span class="spanMovie">Votre Note :
                        <!--Data value for ,5 with double click-->
                        <i class="bi bi-star" data-value="1"></i>
                        <i class="bi bi-star" data-value="2"></i>
                        <i class="bi bi-star" data-value="3"></i>
                        <i class="bi bi-star" data-value="4"></i>
                        <i class="bi bi-star" data-value="5"></i>
                        </span>
                        <!--input value for rating score-->
                        <input type="hidden" name="rating" id="note" value="{$objMovie->getNoteUser()}" class="form-control {if isset($arrError['noteRating'])} is-invalid {/if}">

                    </div>
                    <div class="col-md-4 mw-100 " >
                        <!--On click verify if ratings value > NULL & comment can be empty-->
                        <input type="submit" value="Envoyer" class="btnCustom w-100">
                    </div>
                </div>
            </form>
        </div>

    </section>
     {/if}
    <section id="userComment" class="container py-5">
        <h3 class="py-3">Avis utilisateurs</h3>
        <div class="allComment">
                {if count($arrCommentToDisplay) === 0}
                    <h3 class='text-center py-3'>aucun commentaire</h3>
                {else}
                    {foreach from=$arrCommentToDisplay item=comment}
                        {include file="views/_partial/commentMovie.tpl"}
                    {/foreach}
                {/if}
        </div>
    </section>
{else}
    <section class="container text-center py-3">
        <h3>Les commentaires seront disponibles lorsque le film sera sorti !</h3>
    </section>

{/if}
{/block}

{block name="js"}
    <script src="https://cdn.jsdelivr.net/npm/@splidejs/splide-extension-auto-scroll@0.5.3/dist/js/splide-extension-auto-scroll.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@splidejs/splide@4.1.4/dist/js/splide.min.js"></script>
    <script src="{$smarty.env.BASE_URL}assets/js/moviePage.js"></script>
    <script src="{$smarty.env.BASE_URL}assets/js/star.js"> </script>
{/block}

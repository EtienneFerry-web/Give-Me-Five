{extends file="views/layout_view.tpl"}
{block name="title" prepend}Page profil utilisateur{/block}
{block name="description"}Voici le profil de {$objUser->getPseudo()}{/block}

{block name="css_variation"}
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@splidejs/splide@4.1.4/dist/css/splide-core.min.css">
    <link rel="stylesheet" href="{$smarty.env.BASE_URL}assets/css/slideMovie.css">
{/block}

{block name="content"}

<section id="user" class="container py-2">
   <div class="col-12 row text-center align-items-center text-md-start py-4 mx-auto">
    <div class="col-8 col-md-3 col-lg-2 mx-auto mb-3 mb-md-0">
        <img src="{$smarty.env.BASE_URL}assets/img/users/{$objUser->getPhoto()}" alt="image de profil" class="img-fluid rounded-circle">
    </div>
    <div class="col-12 col-md-9 col-lg-10">
        <div class="row gy-2">
            <div class="col-12 col-md-10">
                <h1 class="fs-2 fs-md-1">{$objUser->getPseudo()}</h1>
                <p class="mb-1">{$objUser->getBio()}</p>
            </div>
            <div class="col-12 col-md-2 d-flex d-md-block justify-content-center">
                <div class="row g-4">
                    <div class="d-flex flex-column align-items-center border-end border-dark col-6">
                        <span class="h5">{$objStat->getNbLike()}</span>
                        <span class="h5">Like</span>
                    </div>
                    <div class="d-flex flex-column align-items-center col-6">
                        <span class="h5">{$objStat->getNbComment()}</span>
                        <span class="h5">Review</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="row align-items-center g-2 mt-1 justify-content-center justify-content-md-start">
            <div class="col-auto">
                <span class="spanMovie border-0 d-flex align-items-center">
                    {if $objUser->getUser_funct_id() == 1}Utilisateur{elseif $objUser->getUser_funct_id() == 2}Modérateur{else}Administrateur{/if}
                    {if isset($smarty.session.user) && $smarty.session.user.user_id == $smarty.get.id}
                        <a href="{$smarty.env.BASE_URL}user/permissions" class="text-dark mx-2" data-bs-toggle="tooltip" data-bs-placement="right" data-bs-title="Consulter mes droits">
                            <i class="bi bi-question-circle fs-3"></i>
                        </a>
                    {/if}
                </span>
            </div>

            {if isset($smarty.session.user) && $smarty.session.user.user_id == $smarty.get.id}
                <div class="col-auto ms-md-auto">
                    <a href="{$smarty.env.BASE_URL}user/settingsUser" class="btn btn-outline-primary btn-sm d-flex align-items-center gap-1">
                        <i class="bi bi-gear fs-5"></i><span>Gestion du compte</span>
                    </a>
                </div>
            {/if}

            {if isset($smarty.session.user)
                && $smarty.session.user.user_id == $smarty.get.id
                && $smarty.session.user.user_funct_id != 1}
                <div class="col-auto">
                    <a href="{$smarty.env.BASE_URL}admin/dashboard" class="btn btn-outline-dark btn-sm d-flex align-items-center gap-1">
                        <i class="bi bi-speedometer2 fs-5"></i><span>Dashboard</span>
                    </a>
                </div>

            {elseif isset($smarty.session.user) && $smarty.session.user.user_id != $smarty.get.id}
                <div class="col-auto ms-md-auto">
                    {if $objUser->getReported() == 0}
                        <button class="border-0 bg-transparent p-0" data-bs-toggle="modal" data-bs-target="#reportModal">
                            <i class="bi bi-flag fs-3"></i>
                        </button>
                        <div class="modal fade" id="reportModal" tabindex="-1">
                            <div class="modal-dialog modal-dialog-centered">
                                <form method="POST" class="modal-content">
                                    <div class="modal-header border-0">
                                        <h5 class="modal-title">Signaler : {$objUser->getPseudo()}</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <p>Pour que votre signalement soit prit en charge veuillez renseigner la raison !</p>
                                        <textarea name="repUser" class="form-control" placeholder="Raison du signalement..."></textarea>
                                    </div>
                                    <div class="modal-footer border-0 mx-auto">
                                        <button type="button" class="btn btn-outline-dark px-3" data-bs-dismiss="modal">Annuler</button>
                                        <button type="submit" class="btn btn-outline-success px-3">Valider</button>
                                    </div>
                                    <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                                </form>
                            </div>
                        </div>
                    {else}
                        <button class="border-0 bg-transparent p-0" data-bs-toggle="modal" data-bs-target="#reportModal">
                            <i class="bi bi-flag-fill fs-3"></i>
                        </button>
                        <div class="modal fade" id="reportModal" tabindex="-1">
                            <div class="modal-dialog modal-dialog-centered">
                                <form method="POST" class="modal-content">
                                    <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                                    <div class="modal-header border-0">
                                        <h5 class="modal-title">Signaler : {$objUser->getPseudo()}</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <p>Voulez-vous vraiment supprimer votre signalement ?</p>
                                    </div>
                                    <div class="modal-footer border-0 mx-auto">
                                        <button type="button" class="btn btn-outline-dark px-3" data-bs-dismiss="modal">Annuler</button>
                                        <button type="submit" name="repDelete" value="delete" class="btn btn-outline-danger px-3">Supprimer</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    {/if}
                </div>
            {/if}
        </div>
    </div>
</div>
{if count($arrMovieToDisplay) > 0}
    <div class="col-12 py-2">
        <div class="like py-3 col-12">
            <span class="spanMovie d-block col-12">Films Likés</span>
            <div class="splide py-2">
              <div class="splide__track">
                <ul class="splide__list">
                    {foreach from=$arrMovieToDisplay item=objLike}
                        {include file="views/_partial/likeUser.tpl"}
                    {/foreach}
                </ul>
              </div>
            </div>
        </div>
    </div>
</section>
{/if}
{if count($arrImageToDisplay) > 0}
    <section  id="imgMovie" class="container py-5 text-center">
        <h2>Image Partager Par l'utilisateur</h2>
        <div class="splide">
            <div class="splide__track">
                <ul class="splide__list">
                {foreach from=$arrImageToDisplay item=objImage}
                    {if (isset($smarty.session.user)) && ($smarty.session.user.user_id == $smarty.get.id || $smarty.session.user.user_funct_id >= 2)}
                    <li class="splide__slide position-relative overlay-container">
                        <img src="{$smarty.env.BASE_URL}assets/img/movie/{$objImage->getPhoto()}" class="img-fluid" />

                        <form method="POST" class="delete-overlay">
                            <input type="hidden" name="deleteImage" value="{$objImage->getId()}">
                            <button type="submit" class="border-0 bg-transparent p-3">
                                <i class="bi bi-trash fs-1 text-white"></i>
                            </button>
                            <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                        </form>
                    </li>
                    {else}
                    <li class="splide__slide">
                        <img src="{$smarty.env.BASE_URL}assets/img/movie/{$objImage->getPhoto()}" />
                    </li>
                    {/if}

                {/foreach}
                </ul>
            </div>
        </div>
    </section>
{/if}
{if !empty($arrCommentToDisplay)}
<section id="review" class="container text-center py-4">
    <h2>Avis</h2>
    <div class="col-12 col-md-10 mx-auto py-1 scrollList">
        {foreach $arrCommentToDisplay as $review}
            {include file="views/_partial/reviewMovie.tpl"}
        {foreachelse}
        <div class="col-12 text-center py-3">
            <h3 class="border-0">Cet Utilisateur n'a pas de review</h3>
        </div>
        {/foreach}
    </div>
</section>
{/if}
{if isset($smarty.session.user) && $smarty.session.user.user_id == $smarty.get.id}
<section class="container py-5">
    <div class="mt-4">
        <h2 class="fw-bold text-uppercase mb-3 text-center">Vos Signalement</h2>
        <ul class="list-group list-group-flush border-top border-dark">

            {foreach from=$arrReportToDisplay item=objReport}
                {include file='views/_partial/reportUser.tpl'}
            {foreachelse}
                <li class="list-group-item text-center">Aucun Signalements trouvé.</li>
            {/foreach}

        </ul>
    </div>
</section>
{/if}
{/block}

{block name="js"}
    <script src="https://cdn.jsdelivr.net/npm/@splidejs/splide-extension-auto-scroll@0.5.3/dist/js/splide-extension-auto-scroll.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@splidejs/splide@4.1.4/dist/js/splide.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="{$smarty.env.BASE_URL}assets/js/moviePage.js"></script>
    <script src="{$smarty.env.BASE_URL}assets/js/comment.js"></script>
    <script src="{$smarty.env.BASE_URL}assets/js/star.js"> </script>
    <script src="{$smarty.env.BASE_URL}assets/js/permission.js"> </script>
{/block}

{extends file="views/layout_view.tpl"}

{block name="title" prepend}Dashboard - Signalements{/block}

{block name="description"}Dashboard des signalements de Give Me Five{/block}

{block name="css_variation"}
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css">
    <link rel="stylesheet" href="{$smarty.env.BASE_URL}assets/css/style.css">
{/block}

{block name="content"}

<section id="dashboard" class="container py-5">

        <h1>DashBoard</h1>
        <nav class="py-2 row g-2">
            <div class="py-2 row g-2">
                <a id="user" href="{$smarty.env.BASE_URL}admin/dashboard" class="nav-link col-2">Home</a>
                {if isset($smarty.session.user) && $smarty.session.user.user_funct_id == 3}<a id="user" href="{$smarty.env.BASE_URL}user/allUser" class="nav-link col-2">Utilisateurs</a>{/if}
                <a id="addMovie" href="{$smarty.env.BASE_URL}movie/allMovie" class="nav-link col-2">Films</a>
                <a id="person" href="{$smarty.env.BASE_URL}person/allPerson" class="nav-link col-2">Célébrités</a>
                <a id="report" href="{$smarty.env.BASE_URL}report/allReport" class="nav-link col-2  active">Signalement</a>
            </div>
        </nav>


    <h2 class="mb-4 py-2">Gestion des Signalements</h2>

    <section class="mb-5">
        <h3 class="h4"><i class="bi bi-chat-left-text me-2"></i>Signalements : Commentaires</h3>
        <div class="container-fluid p-3">
            {foreach from=$arrRepComToDisplay item=objReport}
                <form method="post" class="row border-bottom py-3 align-items-center">
                    <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                    <div class="col-md-1 fw-bold">#{$objReport->getId()}</div>
                    <div class="col-md-3 d-flex align-items-center">
                        <a class="text-decoration-none text-dark d-flex align-items-center" href="{$smarty.env.BASE_URL}user/userPage/{$objReport->getReportedUserId()}">
                            <img src="{$smarty.env.BASE_URL}assets/img/users/{$objReport->getPhoto()}" class="rounded-circle border me-2" style="width: 40px; height: 40px; object-fit: cover;" alt="Photo de profil">
                            <span class="fw-bold">{$objReport->getPseudo()}</span>
                        </a>
                    </div>
                    <div class="col-md-4">
                        <p class="m-0 fw-bold">Raison: {$objReport->getReason()}</p>
                        <p class="m-0 ">Commentaire: {$objReport->getComContent()}</p>
                    </div>
                    <div class="col-md-4 d-flex justify-content-end align-items-center gap-2">
                    {if isset($smarty.session.user) && $smarty.session.user.user_funct_id == 3}
                        {if !$objReport->getUserBan()}
                            <button type="button"
                                    class="btn btn-outline-danger btn-sm px-3"
                                    data-bs-toggle="modal"
                                    data-bs-target="#modalBan"
                                    data-userid="{$objReport->getReportedUserId()}"
                                    data-pseudo="{$objReport->getPseudo()}">
                                Bannir
                            </button>
                        {/if}
                        {/if}
                        {if $objReport->getUserBan()} <button type="submit" name="unBanUser" value="{$objReport->getReportedUserId()}" class="btn btn-outline-success btn-sm px-3">Débannir</button>{/if}
                        <button type="submit" name="addRemoveSpoiler" value="{$objReport->getReportedComId()}" class="btn btn-outline-warning btn-sm">{if $objReport->getSpoiler() == 0} Add Spoiler {else} Remove Spoiler {/if}</button>
                        <button type="submit" name="deleteComment" value="{$objReport->getReportedComId()}" class="btn btn-outline-danger btn-sm">Supprimer</button>
                        <button type="submit" name="deleteRep" value="{$objReport->getId()}" class="btn btn-outline-success btn-sm px-3">Valider</button>
                    </div>
                </form>
            {foreachelse}
                <p class="text-muted py-3 m-0">Aucun signalement de commentaire.</p>
            {/foreach}
        </div>
    </section>
    {if isset($smarty.session.user) && $smarty.session.user.user_funct_id == 3}
    <section class="mb-5">
        <h3 class="h4"><i class="bi bi-people me-2"></i>Signalements : Utilisateurs</h3>
        <div class="container-fluid p-3">
            {foreach from=$arrRepUserToDisplay item=objReport}
                <div class="row border-bottom py-3 align-items-center">
                    <div class="col-md-1 fw-bold">#{$objReport->getReportedUserId()}</div>
                    <div class="col-md-3 d-flex align-items-center">
                        <a class="text-decoration-none text-dark d-flex align-items-center" href="{$smarty.env.BASE_URL}user/userPage/{$objReport->getReportedUserId()}">
                            <img src="{$smarty.env.BASE_URL}assets/img/users/{$objReport->getPhoto()|default:'default-user.png'}"
                                 class="rounded-circle border me-2"
                                 style="width: 40px; height: 40px; object-fit: cover;" alt="Photo">
                            <span class="fw-bold text-dark">{$objReport->getPseudoUser()}</span>
                        </a>
                    </div>
                    <p class="col-md-4 m-0 fw-bold">Raison: {$objReport->getReason()}</p>
                    <div class="col-md-4 d-flex justify-content-end gap-2">
                    {if !$objReport->getUserBan()}
                        <button type="button"
                                class="btn btn-outline-danger btn-sm px-3"
                                data-bs-toggle="modal"
                                data-bs-target="#modalBan"
                                data-userid="{$objReport->getReportedUserId()}"
                                data-pseudo="{$objReport->getPseudoUser()}">
                            Bannir
                        </button>
                    {/if}
                        <a href="{$smarty.env.BASE_URL}user/settingsAllUser/{$objReport->getReportedUserId()}" class="btn btn-sm btn-outline-dark px-3">Modifier</a>
                        <form method="post" class="m-0">
                            <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                           {if $objReport->getUserBan()} <button type="submit" name="unBanUser" value="{$objReport->getReportedUserId()}" class="btn btn-outline-success btn-sm px-3">Débannir</button>{/if}
                            <button type="submit" name="deleteRep" value="{$objReport->getId()}" class="btn btn-outline-success btn-sm px-3">Valider</button>
                        </form>
                    </div>
                </div>
            {foreachelse}
                <p class="text-muted py-3 m-0">Aucun signalement d'utilisateur en attente.</p>
            {/foreach}
        </div>
    </section>
    {/if}
    <div class="modal fade" id="modalBan" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <form method="post" class="modal-content">
                <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                <div class="modal-header">
                    <h5 class="modal-title">Bannir : <span id="modalPseudo"></span></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="id" id="modalIdUser">

                    <div class="mb-3">
                        <label for="banReason" class="form-label fw-bold">Raison du bannissement :</label>
                        <textarea class="form-control" name="reason" id="banReason" rows="4" placeholder="Expliquez la raison..." required></textarea>
                    </div>
                    <p class="small text-muted">Cette action lancera la procédure de bannissement.</p>
                </div>
                <div class="modal-footer">

                    <button type="button" class="btn btn-dark" data-bs-dismiss="modal">Annuler</button>
                    <button type="submit" class="btn btn-danger">Valider</button>
                </div>
            </form>
        </div>
    </div>

    <section class="mb-5">
        <h3 class="h4"><i class="bi bi-film me-2"></i>Signalements : Films</h3>
        <div class="container-fluid p-3">
            {foreach from=$arrRepMovieToDisplay item=objReport}
                <form method="post" class="row border-bottom py-3 align-items-center">
                    <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                    <div class="col-md-1 fw-bold">#{$objReport->getReportedMovieId()}</div>
                    <a href="{$smarty.env.BASE_URL}movie/moviePage/{$objReport->getReportedMovieId()}"class="col-md-3 d-flex align-items-center text-decoration-none text-dark">
                        <span class="fw-bold">{$objReport->getTitle()}</span>
                    </a>
                    <p class="col-md-4 m-0 fw-bold">Raison: {$objReport->getReason()}</p>
                    <div class="col-md-4 d-flex justify-content-end gap-2">
                         <a href="{$smarty.env.BASE_URL}movie/deleteMovie/{$objReport->getReportedMovieId()}" class="btn btn-outline-danger btn-sm px-3" onclick="return confirm('Vous allez supprimer le film {$objReport->getTitle()|escape:'javascript'}')">Supprimer</a>
                         <a href="{$smarty.env.BASE_URL}movie/addEditMovie/{$objReport->getReportedMovieId()}" class="btn btn-sm btn-outline-dark px-3">Modifier</a>
                         <button type="submit" name="deleteRep" value="{$objReport->getId()}" class="btn btn-outline-success btn-sm px-3">Valider</button>
                    </div>
                </form>
            {foreachelse}
                 <p class="text-muted py-3 m-0">Aucun signalement de film.</p>
            {/foreach}
        </div>
    </section>
</section>
{/block}

{block name="js"}
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="{$smarty.env.BASE_URL}assets/js/popUp.js"></script>
{/block}

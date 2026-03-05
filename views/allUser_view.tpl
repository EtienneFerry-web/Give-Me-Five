{extends file="views/layout_view.tpl"}
{block name="title" prepend}Dashboard{/block}
{block name="description"}Dashboard des Utilisateurs de Give Me Five{/block}

{block name="css_variation"}
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css">
    <link rel="stylesheet" href="/Projet2/assets/css/style.css">
{/block}


{block name="content"}
<section id="dashboard" class="container py-5">
    <h1>DashBoard</h1>

    <div class="py-2 row g-2">
        <a id="user" href="{$smarty.env.BASE_URL}admin/dashboard" class="nav-link col-2">Home</a>
        {if isset($smarty.session.user) && $smarty.session.user.user_funct_id == 3}<a id="user" href="{$smarty.env.BASE_URL}user/allUser" class="nav-link col-2">Utilisateurs</a>{/if}
        <a id="addMovie" href="{$smarty.env.BASE_URL}movie/allMovie" class="nav-link col-2">Films</a>
        <a id="person" href="{$smarty.env.BASE_URL}person/allPerson" class="nav-link col-2">Célébrités</a>
        <a id="report" href="{$smarty.env.BASE_URL}report/allReport" class="nav-link col-2">Signalement</a>
    </div>

    <div id="ficheMovie" class="d-flex flex-column">
        <h2>Tous les Utilisateurs</h2>

        <form class="row g-1 align-items-center py-3" method="GET">
            <div class="col-12 col-md-5 p-0">
                <input class="form-control" type="search" placeholder="Rechercher..." name="search" value="{$searchTerm|default:''}">
            </div>
            <div class="col-12 col-md-5 p-0">
                <select class="form-select" name="filter" onchange="this.form.submit()">
                    <option value="all"     {if $filter == 'all'}selected{/if}>Tous Les Grades</option>
                    <option value="asc"     {if $filter == 'asc'}selected{/if}>Croissant</option>
                    <option value="desc"    {if $filter == 'desc'}selected{/if}>Decroissant</option>
                    <option value="admin"   {if $filter == 'admin'}selected{/if}>Administrateurs</option>
                    <option value="modo"    {if $filter == 'modo'}selected{/if}>Modérateurs</option>
                    <option value="user"    {if $filter == 'user'}selected{/if}>Utilisateurs</option>
                </select>
            </div>
            <div class="col-12 col-md-2 p-0">
                <button type="submit" class="w-100 p-1 btnCustom" id="sendUser">Recherche</button>
            </div>
        </form>

        <div class="allMovie">
            {foreach from=$arrUserToDisplay item=objUser}
                <div class="row g-2 align-items-center py-2 border-bottom">
                    <div class="col-2 col-md-1">
                        <span class="spanMovie fw-bold">#{$objUser->getId()}</span>
                    </div>
                    <div class="col-10 col-md-5">
                    <a class="text-decoration-none" href="{$smarty.env.BASE_URL}user/userPage/{$objUser->getId()}"><span class="spanMovie">{$objUser->getPseudo()}</span></a>
                    </div>
                    <div class="col-12 col-md-6 d-flex justify-content-center justify-content-md-end gap-3">

                        {if $smarty.session.user.user_funct_id > $objUser->getUser_funct_id() && !$objUser->getBanAt()}
                        <form action="{$smarty.env.BASE_URL}user/updateGrade/{$objUser->getId()}" method="post">
                            <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                            <select name="user_funct_id" class="form-select form-select-sm" onchange="this.form.submit()">
                                <option value="1" {if $objUser->getUser_funct_id() ==1}selected{/if} >Utilisateur</option>
                                <option value="2" {if $objUser->getUser_funct_id() ==2}selected{/if} >Modérateur</option>

                            {if $smarty.session.user.user_funct_id == 3}
                                    <option value="3" {if $objUser->getUser_funct_id() == 3}selected{/if}>Administrateur</option>
                            {/if}
                            </select>
                        </form>
                        {else}
                            <span >
                                {if     $objUser->getUser_funct_id() == 1}Utilisateur
                                {elseif $objUser->getUser_funct_id() == 2}Modérateur
                                {elseif $objUser->getUser_funct_id() == 3}Administrateur
                                {/if}
                            </span>
                        {/if}
                        {if !$objUser->getBanAt()}
                        {if $smarty.session.user.user_funct_id > $objUser->getUser_funct_id() || $smarty.session.user.user_id == $objUser->getId()}
                            <button type="button"
                                    class="btn btn-outline-danger btn-sm px-5"
                                    data-bs-toggle="modal"
                                    data-bs-target="#modalBan"
                                    data-userid="{$objUser->getId()}"
                                    data-pseudo="{$objUser->getPseudo()}">
                                Bannir
                            </button>
                            
                                <a href="{$smarty.env.BASE_URL}user/settingsAllUser/{$objUser->getId()}" class="btn btn-sm btn-outline-dark px-5">Modifier</a>
                            
                                <a href="{$smarty.env.BASE_URL}user/deleteAccount/{$objUser->getId()}"
                                    class="btn btn-sm btn-outline-danger px-5"
                                    onclick="return confirm('Vous allez supprimer le film {$objUser->getPseudo()|escape:'javascript'}')">
                                    Supprimer
                                </a>
                            {/if}
                        {elseif $objUser->getBanAt()}
                            <form method="post">
                                <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                                <button type="submit" name="unBanUser" value="{$objUser->getId()}" class="btn btn-outline-success btn-sm px-5">Débannir</button>
                            </form>
                        {/if}
                    </div>
                </div>
            {/foreach}
        </div>
    </div>
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
</section>
{/block}

{block name="js"}
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="{$smarty.env.BASE_URL}assets/js/popUp.js"></script>
{/block}

{extends file="views/layout_view.tpl"}
{block name="title" prepend}Dashboard{/block}
{block name="description"}Dashboard film de Give Me Five{/block}

{block name="css_variation"}
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css">
    <link rel="stylesheet" href="{$smarty.env.BASE_URL}assets/css/style.css">
{/block}


{block name="content"}
    <section id="dashboard" class="container py-5">
        <h1>DashBoard</h1>

        <div class="py-2 row g-2">
            <a id="user" href="{$smarty.env.BASE_URL}admin/dashboard" class="nav-link col-2">Home</a>
            {if isset($smarty.session.user) && $smarty.session.user.user_funct_id == 3}<a id="user" href="{$smarty.env.BASE_URL}user/allUser" class="nav-link col-2">Utilisateurs</a>{/if}
            <a id="addMovie" href="{$smarty.env.BASE_URL}movie/allMovie" class="nav-link col-2 active">Films</a>
            <a id="person" href="{$smarty.env.BASE_URL}person/allPerson" class="nav-link col-2">Célébrités</a>
            <a id="report" href="{$smarty.env.BASE_URL}report/allReport" class="nav-link col-2">Signalement</a>
        </div>

        <div id="" class="d-flex flex-column">
            <h2>Tous les fidzqdqzdqlms</h2>

            <form class="row g-1 align-items-center py-3" method="get">
                <div class="col-12 col-md-3 p-0">
                    <input class="form-control" type="search" placeholder="Rechercher..." name="search"
                        value="{$search|default:''}">
                </div>
                <div class="col-12 col-md-3 p-0">
                    <select class="form-select" name="filter" onchange="this.form.submit()">
                        <option value="0" {if $filter == '0'}selected{/if}>Tous les genres</option>
                        {foreach from=$arrCatToDisplay item=arrDetCategory}
                            <option class="form-control" value="{$arrDetCategory->getId()}"
                                {if $filter == $arrDetCategory->getId()}selected{/if}>
                                {$arrDetCategory->getCategories()}
                            </option>
                        {/foreach}
                    </select>
                </div>
                <div class="col-6 col-md-3 p-0">
                    <select class="form-select" name="sort" onchange="this.form.submit()">
                        <option value="asc" {if $sort == 'asc' || $sort == ''}selected{/if}>Nom (A-Z)</option>
                        <option value="desc" {if $sort == 'desc'}selected{/if}>Nom (Z-A)</option>
                    </select>
                </div>
                <div class="col-12 col-md-3 p-0">
                    <button type="submit" class="w-100 p-1 btnCustom" id="sendMovie">Recherche</button>
                </div>
            </form>

            <div>
                {foreach from=$arrMovieToDisplay item=objMovie}
                    <div class="row g-2 align-items-center py-2 border-bottom">
                        <div class="col-2 col-md-1">
                            <span class="spanMovie fw-bold">#{$objMovie->getId()}</span>
                        </div>
                        <div class="col-10 col-md-5">
                            <a class="text-decoration-none"
                                href="{$smarty.env.BASE_URL}movie/moviePage/{$objMovie->getId()}"><span
                                    class="spanMovie">{$objMovie->getTitle()}</span></a>
                        </div>
                        <div class="col-12 col-md-6 d-flex justify-content-center justify-content-md-end gap-3">
                            <a href="{$smarty.env.BASE_URL}movie/addEditMovie/{$objMovie->getId()}"
                                class="btn btn-sm btn-outline-dark px-5">Modifier</a>
                            <a href="{$smarty.env.BASE_URL}movie/deleteMovie/{$objMovie->getId()}"
                                class="btn btn-sm btn-outline-danger px-5"
                                onclick="return confirm('Vous allez supprimer le film {$objMovie->getTitle()|escape:'javascript'}')">
                                Supprimer
                            </a>
                        </div>
                    </div>
                {/foreach}
            </div>
        </div>
        <div class="py-3">
            <h2>Proposition des Utilisateurs</h2>
                {foreach from=$arrMovieNotPublishedToDisplay item=objMovie}
                    <div class="row g-2 align-items-center py-2 border-bottom">
                        <div class="col-2 col-md-1">
                            <span class="spanMovie fw-bold">#{$objMovie->getId()}</span>
                        </div>
                        <div class="col-10 col-md-5">
                            <a class="text-decoration-none"
                                href="{$smarty.env.BASE_URL}movie/moviePage/{$objMovie->getId()}"><span
                                    class="spanMovie">{$objMovie->getTitle()}</span></a>
                        </div>
                        <div class="col-12 col-md-6 d-flex justify-content-center justify-content-md-end gap-3">
                            <a href="{$smarty.env.BASE_URL}movie/addEditMovie/{$objMovie->getId()}"
                                class="btn btn-sm btn-outline-dark  px-5">Voir</a>
                            <a href="{$smarty.env.BASE_URL}movie/deleteMovie/{$objMovie->getId()}"
                                class="btn btn-sm btn-outline-danger px-5"
                                onclick="return confirm('Vous allez supprimer le film {$objMovie->getTitle()|escape:'javascript'}')">
                                Refuser
                            </a>
                            <a href="{$smarty.env.BASE_URL}movie/publishMovie/{$objMovie->getId()}"
                                class="btn btn-sm btn-outline-success px-5"
                                onclick="return confirm('Vous allez publié le film {$objMovie->getTitle()|escape:'javascript'}')">
                                Valider
                            </a>
                        </div>
                    </div>
                {/foreach}
            </div>
    </section>
    
{/block}

{block name="js"}
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
{/block}

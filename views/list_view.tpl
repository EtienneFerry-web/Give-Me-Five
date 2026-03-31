{extends file="views/layout_view.tpl"}
{block name="title" prepend}Catalogue de films{/block}
{block name="description"}Découvrez les films populaires disponibles en streaming, alimentés par l'API Streaming Availability.{/block}

{block name="content"}
<section id="listFilter" class="container py-5">

    {* En-tête de la page *}
    <div class="row align-items-center mb-4">
        <div class="col-12 col-md-8">
            <h1 class="fw-bold">
                {if isset($strSearch) && $strSearch != ''}
                    Résultats pour "<span class="text-primary">{$strSearch|escape:'html'}</span>"
                {else}
                    🎬 Films populaires en streaming
                {/if}
            </h1>
            <p class="text-muted mb-0">Films disponibles via l'API Streaming Availability.</p>
        </div>
        <div class="col-12 col-md-4 text-md-end mt-3 mt-md-0">
            <a href="{$smarty.env.BASE_URL}movie/home" class="btn btn-outline-secondary">
                <i class="bi bi-house me-1"></i> Retour à l'accueil
            </a>
        </div>
    </div>

    {* Barre de recherche rapide *}
    <div class="row mb-4">
        <div class="col-12 col-md-6 col-lg-4">
            <form method="GET" action="{$smarty.env.BASE_URL}movie/list" class="d-flex gap-2">
                <input
                    type="text"
                    name="search"
                    class="form-control"
                    placeholder="Rechercher un film…"
                    value="{if isset($strSearch)}{$strSearch|escape:'html'}{/if}"
                    id="searchInput"
                >
                <button type="submit" class="btn btn-primary px-3">
                    <i class="bi bi-search"></i>
                </button>
            </form>
        </div>
    </div>

    {* Bloc d'erreur API *}
    {if isset($arrError) && $arrError|@count > 0}
        <div class="alert alert-danger d-flex align-items-center gap-3 rounded-3 shadow-sm" role="alert">
            <i class="bi bi-exclamation-triangle-fill fs-4 flex-shrink-0"></i>
            <div>
                <strong>Une erreur est survenue :</strong><br>
                {foreach from=$arrError item=strError}
                    <span>{$strError|escape:'html'}</span>
                {/foreach}
            </div>
        </div>

    {* Liste des films *}
    {elseif isset($arrMovieToDisplay) && $arrMovieToDisplay|@count > 0}
        <div class="scrollList">
            {foreach from=$arrMovieToDisplay item=objMovie}
                {include file="views/_partial/movieList.tpl"}
            {/foreach}
        </div>

    {* Aucun résultat *}
    {else}
        <div class="text-center py-5">
            <i class="bi bi-film fs-1 text-muted opacity-50 d-block mb-3"></i>
            <h3 class="fw-bold">Aucun film trouvé</h3>
            <p class="text-muted">
                {if isset($strSearch) && $strSearch != ''}
                    Aucun résultat pour "<strong>{$strSearch|escape:'html'}</strong>".
                    Essayez avec un autre titre.
                {else}
                    L'API n'a retourné aucun film pour le moment. Veuillez réessayer plus tard.
                {/if}
            </p>
            <a href="{$smarty.env.BASE_URL}movie/list" class="btn btn-outline-primary mt-2">
                Voir tous les films
            </a>
        </div>
    {/if}

</section>
{/block}
{extends file="views/layout_view.tpl"}

{block name="content"}
<div class="container my-5">
    <div class="row mb-4 align-items-center">
        <div class="col-md-8">
            <h1 class="display-4 fw-bold text-primary">Résultats pour "{$searchedTitle|escape}"</h1>
            <p class="lead text-muted">Voici les films trouvés via l'API Streaming Availability.</p>
        </div>
        <div class="col-md-4 text-end">
            <a href="index.php?ctrl=movie&action=home" class="btn btn-outline-secondary">
                <i class="fas fa-home"></i> Retour à l'accueil
            </a>
        </div>
    </div>

    {if isset($arrError) && $arrError|@count > 0}
        <div class="alert alert-danger shadow-sm border-0 rounded-4 p-4" role="alert">
            <div class="d-flex align-items-center">
                <i class="fas fa-exclamation-triangle fa-2x me-3"></i>
                <div>
                    <h4 class="alert-heading fw-bold mb-1">Oups ! Une erreur est survenue</h4>
                    {foreach from=$arrError item=strError}
                        <p class="mb-0">{$strError}</p>
                    {/foreach}
                </div>
            </div>
        </div>
    {elseif isset($arrResult) && $arrResult|@count > 0}
        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
            {foreach from=$arrResult item=movie}
                <div class="col">
                    <div class="card h-100 border-0 shadow-lg hover-transform transition-all" style="border-radius: 1.5rem; overflow: hidden;">
                        <div class="position-relative">
                            {if isset($movie.imageSet.verticalPoster.w480)}
                                <img src="{$movie.imageSet.verticalPoster.w480}" class="card-img-top" alt="{$movie.title|escape}" style="height: 400px; object-fit: cover;">
                            {elseif isset($movie.imageSet.verticalPoster.w240)}
                                <img src="{$movie.imageSet.verticalPoster.w240}" class="card-img-top" alt="{$movie.title|escape}" style="height: 400px; object-fit: cover;">
                            {else}
                                <div class="bg-dark d-flex align-items-center justify-content-center text-white" style="height: 400px;">
                                    <i class="fas fa-film fa-3x opacity-25"></i>
                                </div>
                            {/if}
                            <div class="position-absolute bottom-0 start-0 w-100 p-3 bg-gradient-dark text-white">
                                <span class="badge bg-warning text-dark rounded-pill px-3 py-2">
                                    <i class="fas fa-star me-1"></i> {$movie.rating|default:'N/A'}
                                </span>
                            </div>
                        </div>
                        <div class="card-body p-4">
                            <h5 class="card-title fw-bold mb-2 text-truncate-2">{$movie.title|escape}</h5>
                            <p class="card-text text-muted small text-truncate-3 mb-3">
                                {$movie.overview|default:'Aucun synopsis disponible.'}
                            </p>
                            <div class="d-grid mt-auto">
                                <a href="{$movie.streamingOptions.fr[0].link|default:'#'}" target="_blank" class="btn btn-primary rounded-pill fw-bold">
                                    <i class="fas fa-play me-2"></i> Voir maintenant
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            {/foreach}
        </div>
    {else}
        <div class="text-center py-5">
            <i class="fas fa-search fa-4x text-muted mb-4 opacity-25"></i>
            <h3 class="fw-bold">Aucun film trouvé</h3>
            <p class="text-muted">Essayez avec un autre titre ou vérifiez votre connexion.</p>
        </div>
    {/if}
</div>

<style>
    .hover-transform:hover {
        transform: translateY(-10px);
        box-shadow: 0 20px 40px rgba(0,0,0,0.2) !important;
    }
    .transition-all {
        transition: all 0.3s ease-in-out;
    }
    .bg-gradient-dark {
        background: linear-gradient(to top, rgba(0,0,0,0.8) 0%, rgba(0,0,0,0) 100%);
    }
    .text-truncate-2 {
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }
    .text-truncate-3 {
        display: -webkit-box;
        -webkit-line-clamp: 3;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }
</style>
{/block}

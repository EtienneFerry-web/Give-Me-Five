{extends file="views/layout_view.tpl"}
{block name="title" prepend}Accès interdit — {/block}

{block name="content"}
<section class="container d-flex flex-column align-items-center justify-content-center text-center py-5" style="min-height:60vh">
    <h1 class="display-1 fw-bold">403</h1>
    <p class="lead text-muted mb-4">Vous n'avez pas accès à cette page.</p>
    <a href="{$smarty.env.BASE_URL}" class="btnCustom">Retour à l'accueil</a>
</section>
{/block}

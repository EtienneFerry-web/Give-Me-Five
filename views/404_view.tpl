{extends file="views/layout_view.tpl"}
{block name="title" prepend}Page introuvable — {/block}

{block name="content"}
<section class="container d-flex flex-column align-items-center justify-content-center text-center py-5" style="min-height:60vh">
    <h1 class="display-1 fw-bold">404</h1>
    <p class="lead text-muted mb-4">Cette page est introuvable.</p>
    <a href="{$smarty.env.BASE_URL}" class="btnCustom">Retour à l'accueil</a>
</section>
{/block}

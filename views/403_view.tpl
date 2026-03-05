{extends file="views/layout_view.tpl"}
{block name="title" prepend}403{/block}
{block name="description"}Erreur 403, page introuvable{/block}

{block name="content"}
<div class="container-fluid d-flex align-items-center justify-content-center bg-white" style="min-height: 75vh;">
    <div class="text-center w-100">
        
        <h1 class="display-1 fw-bolder mb-0 text-dark" style="font-size: clamp(5rem, 20vw, 15rem); line-height: 1;">
            403
        </h1>
        
        <p class="h4 text-uppercase fw-light mb-5 text-dark" style="letter-spacing: 0.5rem;">
            Accès Interdit
        </p>

        <div class="d-flex flex-wrap justify-content-center gap-3">
            {if !isset($smarty.session.user)}
                <a href="{$smarty.env.BASE_URL}user/login" class="btn btn-outline-dark btn-lg rounded-0 px-5 fw-bold">
                    Se connecter
                </a>
            {/if}
            <a href="{$smarty.env.BASE_URL}page/contact" class="btn btn-outline-dark btn-lg rounded-0 px-5 fw-bold">
                Contactez-nous
            </a>
        </div>
        
    </div>
</div>
{/block}



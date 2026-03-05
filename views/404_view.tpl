{extends file="views/layout_view.tpl"}
{block name="title" prepend}404{/block}
{block name="description"}Erreur 404, page introuvable{/block}

{block name="css_variation"}
    <link rel="stylesheet" href="{$smarty.env.BASE_URL}assets/css/404.css">
{/block}

{block name="content"}
<section id="zone">
    <div id="canvas">
        <div id="dvd-logo" class="dvd-box">
            <svg viewBox="0 0 160 90">
                <rect x="5" y="5" width="150" height="80" rx="75" ry="75"
                    fill="none" stroke="currentColor" stroke-width="4" />

                <text x="50%" y="40" dominant-baseline="middle" text-anchor="middle"
                    class="text-404" fill="currentColor">404</text>

                <text x="50%" y="65" dominant-baseline="middle" text-anchor="middle"
                    class="text-notfound" fill="currentColor">NOT FOUND</text>
            </svg>
        </div>
    </div>
</section>
{/block}

{block name="js"}
    <script src="{$smarty.env.BASE_URL}assets/js/404.js"> </script>
{/block}

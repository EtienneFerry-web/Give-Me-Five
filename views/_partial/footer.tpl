    <footer>
        <div class="container text-center py-5">
            <a href="{$smarty.env.BASE_URL}page/mention" class="p-2 nav-link {$strPage ==="mention" ? "active" : ""}">Mentions légales</a>|
            <a href="{$smarty.env.BASE_URL}page/policy" class="p-2 nav-link {$strPage ==="policy" ? "active" : ""}">Politique de confidentialité</a>
            <div>© 2026 GIVE ME FIVE. Tous droits réservés.</div>
        </div>
    </footer>
    <script>
        var url = "{$smarty.env.BASE_URL}";
        var csrfToken = "{$smarty.session.csrf_token}";
    </script>
    {if isset($smarty.session.user)}
        <script src="{$smarty.env.BASE_URL}assets/js/activity.js"></script>
    {/if}
    <script src="{$smarty.env.BASE_URL}assets/js/autoCompletion.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    {block name="js"}{/block}
</body>
</html>

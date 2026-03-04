{extends file="views/layout_view.tpl"}
{block name="title" prepend}Mot de passe oublié{/block}
{block name="description"}Renseigner son mail pour changer son mot de passe{/block}

{block name="content"}
    <section id="login" class="container py-5 my-auto " style="min-height: 75vh;">
        <div class="mx-auto" style="width: 100%;">
            <h1 class="text-center">Mot de passe oublié</h1>
            <p class="mx-auto text-center py-2">Renseigner son mail pour changer son mot de passe</p>
            <form method="post">
                <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                <div class="form-group py-2">
                    <label for="" class="form-label">Mot de Passe</label>
                    <input type="text" name="pwd" value="" class="form-control">
                </div>
                <div class="form-group py-2">
                    <label for="" class="form-label">Confirmation du Mots de Passe</label>
                    <input type="text" name="pwdConfirm" value="" class="form-control">
                </div>
                <input class="w-100 btnCustom" type="submit" value="Se connecter">
            </form>
        </div>
    </section>
{/block}
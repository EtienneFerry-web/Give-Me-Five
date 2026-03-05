{extends file="views/layout_view.tpl"}
{block name="title" prepend}Mot de passe oublié{/block}
{block name="description"}Renseigner son mail pour changer son mot de passe{/block}

{block name="content"}
    <section id="login" class="container d-flex flex-column justify-content-center" style="min-height: 75vh;">
    
        <div class="mx-auto" style="width: 100%;">
            <h1 class="text-center">Mot de passe oublié</h1>
            <p class="text-center py-2">Renseignez votre e-mail pour changer votre mot de passe.</p>
            
            <form method="post">
                <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                <div class="form-group py-3">
                    <label class="form-label">Adresse e-mail</label>
                    <input type="email" name="email" class="form-control {if (isset($arrError['email']))} is-invalid{/if}"
                        value="{$objUser->getEmail()}" placeholder="E-mail">
                </div>
                <input class="w-100 btnCustom" type="submit" value="Envoyer">
            </form>
        </div>

    </section>
{/block}
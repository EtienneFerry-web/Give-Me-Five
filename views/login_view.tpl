{extends file="views/layout_view.tpl"}
{block name="title" prepend}Connexion{/block}
{block name="description"}Connectez-vous pour une expérience personnalisée{/block}

{block name="content"}
    <section id="login" class="container py-5 my-auto" style="min-height: 75vh;" >
        <!-- include messages  -->
        <h1 class="text-center">Connexion</h1>
        <p class="mx-auto text-center py-2">Si vous n'avez pas de compte, vous pouvez en créer un sur la page <a
                href="{$smarty.env.BASE_URL}user/createAccount" class="text-dark">d'inscription</a> !</p>
        <form method="post">
            <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
            <div class="form-group py-3">
                <label class="form-label">Adresse e-mail</label>
                <input type="email" name="email" class="form-control {if (isset($arrError['email']))} is-invalid{/if}"
                    value="{$objUser->getEmail()}" placeholder="E-mail">
            </div>
            <div class="form-group py-3">
                <label class="form-label">Mot de passe</label>
                <input type="password" name="pwd" class="form-control {if (isset($arrError['pwd']))} is-invalid {/if}"
                    value="" placeholder="Mot de Passe">
            </div>

            <input class="w-100 btnCustom" type="submit" value="Se connecter">
            <a href="{$smarty.env.BASE_URL}user/forgotPwd" class="text-dark">Mot de passe oublié ?</a>

        </form>
    </section>
{/block}
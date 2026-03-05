{extends file="views/layout_view.tpl"}
{block name="title" prepend}Ajouter un film{/block}
{block name="description"}Ici vous pouvez ajouter un film !{/block}
{block name="content"}
    <section class="container py-5 my-auto">
	    <h1 class="text-center">Inscription</h1>
		<p class="mx-auto text-center py-2">Créez votre compte en quelques secondes et débloquez des fonctionnalités exclusives : notes personnalisées, listes de favoris et bien plus encore !</p>
		<form method="post">
            <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
            <div class="form-group py-2">
                <label  class="form-label">Nom :</label>
                <input  type="text" 
                        name="name"
                        class="form-control {if (isset($arrError['name']))} is-invalid {/if} "  
                        value="{$objUser->getName()}"
                        placeholder="Nom">
            </div>
            <div class="form-group py-2">
                <label  class="form-label">Prénom :</label>
                <input  type="text"
                        name="firstname"
                        class="form-control {if (isset($arrError['firstname']))} is-invalid {/if}"  
                        value="{$objUser->getFirstname()}"
                        placeholder="Prenom">
            </div>
            <div class="form-group py-2">
                <label  class="form-label">Pseudo :</label>
                <input  type="text"
                        name="pseudo"
                        class="form-control {if (isset($arrError['pseudo']))} is-invalid {/if}"  
                        value="{$objUser->getPseudo()}"
                        placeholder="Pseudo">
            </div>
            <div class="form-group py-2">
                <label for="date" class="form-label">Date de naissance :</label>
     			<input
    				type="date"
    				class="form-control"
    				id="birthdate"
    				name="birthdate"
    				aria-describedby="date-help"
    				value="{$objUser->getBirthdate()}" >
     			<small id="date-help" class="form-text text-muted">
        				Format: JJ/MM/AAAA
                </small>
            </div>
            <div class="form-group py-2">
                <label class="form-label">Adresse e-mail :</label>
                <input  type="email" 
                        name="email"
                        class="form-control {if (isset($arrError['email']))} is-invalid{/if}" 
                        value="{$objUser->getEmail()}"
                        placeholder="E-mail">
            </div>
            <div class="form-group py-2">
                <label class="form-label" >Mot de passe :</label>
                <input  type="password" 
                        name="pwd"
                        class="form-control {if (isset($arrError['pwd']))} is-invalid {/if}"  
                        placeholder="Mot de Passe">
            </div>
            <div class="form-group py-2">
                <label class="form-label">Confirmation du mot de passe :</label>
                <input  type="password" 
                        name="pwd_confirm"
                        class="form-control {if (isset($arrError['pwd_confirm']))} is-invalid {/if}"  
                        placeholder="Confirmation du mot de passe">
            </div>
            <input class="w-100 btnCustom" type="submit" >
        </form>
    </section>
{/block}
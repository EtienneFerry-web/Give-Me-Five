{extends file="views/layout_view.tpl"}
{block name="title" prepend}Ajouter un film{/block}
{block name="description"}Ici vous pouvez ajouter un film !{/block}
{block name="content"}
<section id="settingsUser" class="container py-5">
<h1>Gestion de compte</h1>
<div class="py-3"><a href="{$smarty.env.BASE_URL}user/userPage/{$smarty.session.user.user_id}" class="spanMovie"><i class="bi bi-arrow-left fs-1"></i></a></div>
<!--Contenue bio pseudo Photo de profil -->
<div class="py-5">
     <h2>Profil Utilisateur</h2>
     <form method="post" enctype="multipart/form-data" class="row">
        <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
        <div class="form-group py-2">
            <label  class="form-label">Changer le prénom :</label>
            <input  type="text"
                    name="firstname"
                    class="form-control {if (isset($arrError['firstname']))} is-invalid {/if}"  
                    value="{$objUser->getFirstname()}"
                    placeholder="Prenom">
        </div>
        <div class="form-group py-2">
            <label  class="form-label">Changer le nom :</label>
            <input  type="text"
                    name="name"
                    class="form-control {if (isset($arrError['name']))} is-invalid {/if}"  
                    value="{$objUser->getName()}"
                    placeholder="Nom">
        </div>
          <div class="form-group py-2">
             <label for="" class="form-label">Changer de pseudo :</label>
             <input type="text" 
                    name="pseudo"  
                    value="{$objUser->getPseudo()}" 
                    class="form-control {if (isset($arrError['pseudo']))} is-invalid {/if}">
         </div>
          <div class="form-group py-2">
             <label for="" class="form-label">Changer de Bio :</label>
             <textarea  name="bio" 
                        placeholder="Bio Utilisateur"
                        class="form-control {if (isset($arrError['bio']))} is-invalid {/if}">{$objUser->getBio()}</textarea>
         </div>
         <div class="col-12 p-2">
            <label class="form-label">Changer la photo de profil :</label>
            <div class="mb-2">
                <img src="{$smarty.env.BASE_URL}assets/img/users/{$objUser->getPhoto()}" alt="Photo de profil" style="max-width: 150px;">
            </div>
             <input     name="photo"
                        type="file" 
                        class="form-control {if (isset($arrError['photo'])) } is-invalid {/if}" 
                        >
         </div>


     <h2 class="py-2">Sécurité</h2>
        <div class="form-group py-2">
             <label for="" class="form-label">Adresse E-mail :</label>
             <input name="email" id="" placeholder="Email" value="{$objUser->getEmail()}"class="form-control"> 
         </div>
         <div class="form-group py-2">
             <label for="" class="form-label">Mot de Passe :</label>
             <input type="text" name="pwd" value="" class="form-control">
         </div>
         <div class="form-group py-2">
             <label for="" class="form-label">Confirmation du Mot de Passe :</label>
             <input type="text" name="pwdConfirm" value="" class="form-control">
         </div>
         <button type="submit" class="btnCustom py-3">Enregistrer</button>
     </form>
     <div class="row justify-content-center mt-3">
         <div class="col-auto">
             <a href="{$smarty.env.BASE_URL}user/logout" class="nav-link">
                 Se déconnecter
             </a>
         </div>

         <div class="col-auto">
             <form action="{$smarty.env.BASE_URL}user/deleteAccount" method="POST" class="nav-link col-auto"
                onsubmit="return confirm('Êtes-vous sûr ? C’est irréversible !');">
                    <button type="submit" class="border-0 bg-transparent">
                        Supprimer mon compte
                    </button>
                    <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
            </form>
         </div>
     </div>
</div>

</section>
{/block}
<ul class="navbar-nav ms-auto mb-2 mb-lg-0">
    <li class="nav-item my-auto">
        <button id="darkModeToggle" class="nav-link border-0 bg-transparent" title="Mode sombre" style="cursor:pointer;">
            <i class="bi bi-moon-fill" id="darkModeIcon"></i>
        </button>
    </li>
    {if !isset($smarty.session.user)}
        <li class="nav-item my-auto"><a class="nav-link {$strView ==="login" ? "active" : ""}" href="{$smarty.env.BASE_URL}user/login">Connexion</a></li>
        <li class="nav-item my-auto"><a class="nav-link {$strView ==="createAccount" ? "active" : ""}" href="{$smarty.env.BASE_URL}user/createAccount">Inscription</a></li>
    {else}
        <li class="nav-item my-auto"><a class="nav-link {$strView ==="user" ? "active" : ""}" href="{$smarty.env.BASE_URL}user/userPage/{$smarty.session.user.user_id}"><i class="bi bi-person-circle fs-2"></i></a></li>
        <li class="nav-item my-auto"><a class="nav-link {$strView ==="logout" ? "active" : ""}" href="{$smarty.env.BASE_URL}user/logout">Déconnexion</i></a></li>
    {/if}
    <li class="nav-item my-auto"><a class="nav-link {$strView == 'rapidMoviesList' ? 'active' : ''}" href="{$smarty.env.BASE_URL}rapidMovie/search">Nos Films</a></li>
</ul>

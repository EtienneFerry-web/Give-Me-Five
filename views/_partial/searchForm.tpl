
<form action="{$smarty.env.BASE_URL}rapidMovie/search" class="{$formClass}" role="search" method="get" id="formSearch">
    <div class="search-container">
        <input class="form-control me-2" type="search" placeholder="Rechercher..." name="title" value="" id="searchBar" autocomplete="off">
        <div id="suggestions" class="suggestions-list"></div>
    </div>
    <button class="btn" type="submit">
        <img src="{$smarty.env.BASE_URL}assets/img/iconBtnSearch.svg" height="32" width="32">
    </button>
</form>

{extends file="views/layout_view.tpl"}
{if ($objMovie->getId()|is_null)}
{block name="title" prepend}Ajouter un film{/block}
{block name="description"}Ici, vous pouvez ajouter un film !{/block}
{else}
{block name="title" prepend}Modifier un film{/block}
{block name="description"}Ici, vous pouvez modifier un film !{/block}
{/if}
{block name="content"}
<section id="addMovie" class="container py-5 my-auto">
	{if ($objMovie->getId()|is_null)}
	<h1 class="text-center">Demande d'ajout de film</h1>
	<p class="mx-auto text-center py-2">Vous ne trouvez pas votre film préféré dans notre catalogue ? Aidez-nous à
			Enrichir notre base de données ! Remplissez le formulaire ci-dessous avec les informations du film, et notre
			L'équipe l'ajoutera après vérification.</p>
	{else}
	<h1 class="text-center">Modifier un film</h1>
	{/if}
	<form method="post" enctype="multipart/form-data">
		<input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
		<div class="row">
			<div class="col-12 form-group py-2">
				<label class="form-label">Titre du film*</label>
				<input name="title" type="text" class="form-control" id="title" placeholder="Titre"
					value="{$objMovie->getTitle()}">
			</div>
			<div class="col-md-12">
				<label for="categories" class="form-label">Genre</label>
				<select class="form-control" id="categories" name="categoriesId">
					<option value="0">Tous les genres</option>

					{foreach from=$arrCatToDisplay item=arrDetCategory}
					<option class="form-control" value="{$arrDetCategory->getId()}" {if $arrDetCategory->getId() ==
						$objMovie->getCategoriesId()}selected{/if}>
						{$arrDetCategory->getCategories()}
					</option>
					{/foreach}
				</select>
			</div>
			<div class="col-md-12">
				<label for="country" class="form-label">Pays d'origine*</label>
				<select class="form-control" id="country" name="countryId">
					<option value="0">Pays d'origine</option>

					{foreach from=$arrNatToDisplay item=arrDetNat}
					<option class="form-control" value="{$arrDetNat->getId()}" {if $arrDetNat->getId() ==
						$objMovie->getCountryId()}selected{/if}>
						{$arrDetNat->getCountry()}
					</option>
					{/foreach}
				</select>
			</div>
			<div class="form-group py-2">
				<label class="form-label">Date de sortie*</label>
				<input name="release_date" type="date" class="form-control" id="release_date"
					value="{$objMovie->getRelease_date()}" placeholder="Quelle est la date de sortie du film?">
			</div>

			<div class="form-group py-2">
				<label class="form-label">Titre original</label>
				<input name="original_title" type="text" class="form-control" id="original_title"
					value="{$objMovie->getOriginalTitle()}" placeholder="">
			</div>
			<div class="form-group py-2">
				<label class="form-label">Durée*</label>
				<input name="length" type="time" class="form-control" id="length" value="{$objMovie->getLength()}">
			</div>
			<div class="form-group py-2">
				<label class="form-label">Synopsis*</label>
				<textarea name="description" class="form-control textarea" id="description"
					placeholder="Synopsis">{$objMovie->getDescription()}</textarea>
			</div>
			<div class="col-12 form-group py-2">
				<label for="photo" class="form-label">Affiche du film*</label>
				
				{if isset($smarty.get.id)}
				<div class="py-1">
					<img src="{$smarty.env.BASE_URL}assets/img/movie/{$objMovie->getPhoto()}" alt="Affiche du film {$objMovie->getTitle()}">
				</div>
				{/if}
				<input name="photo" id="photo" type="file" class="form-control " value="{$objMovie->getPhoto()}">
			</div>
			<div class="form-group py-2">
				<label class="form-label">Bande-annonce du film</label>
				<input name="trailer_url" type="text" class="form-control" value="{$objMovie->getTrailer()}"
					placeholder="Collez le lien du trailer">
			</div>
			
				<input class="w-100 btnCustom my-2 py-2" type="submit">
			
	</form>
</section>
{/block}
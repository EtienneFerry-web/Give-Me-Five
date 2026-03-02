<div class="row py-3 border-bottom border-dark position-relative">
    {if $review->getSpoiler() == 1}
        <div class="comment-spoiler" id="spoiler">
            <h3 class="border-0">Anti-Spoiler</h3>
            <p>Attention ce commentaire contient un spoiler !</p>
            <h4>Cliquez pour voir le commentaire !</h4>
        </div>
    {/if}

    <div class="col-3 my-auto">
        <a id="movie" data-movie="{$review->getMovieId()}" href="{$smarty.env.BASE_URL}movie/{$review->getMovieId()}">
            <img src="{$smarty.env.BASE_URL}assets/img/movie/{$review->getPhoto()}" alt="couverture de film" class="img-fluid border-0">
        </a>
    </div>

    <div class="col-9 d-flex flex-column text-start py-3">
        <h3>{$review->getTitle()}</h3>

        <div class="editable-content d-flex flex-column h-100" id="comment-container-{$review->getId()}">

            <div class="flex-grow-1 py-3">
                <p class="comment-text">{$review->getComment()}</p>

                <span class="pageMovieNote spanMovie d-block text-start" data-note="{$review->getRating()}">
                    <span class="stars"></span>
                    <span class="note note-display">{$review->getRating()}</span>
                </span>

                <form method="post" class="mt-2">
                    <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                    <input type="hidden"  name="likeReviewBtn" value="{$review->getId()}">

                    <button type="submit" class="border-0 bg-transparent p-0 text-decoration-none" name="">
                        <label class="form-label" style="cursor:pointer;">
                        {if $review->getUser_liked()}
                            <i class="bi bi-heart-fill"></i>
                        {else}
                            <i class="bi bi-heart"></i>
                        {/if}
                            <span class="like-count"> {$review->getLike()}</span>
                        </label>
                    </button>
                </form>
            </div>

            <div class="row align-items-center pt-3">
                <span class="spanMovie d-block col-6">{$review->getDateFormat()}</span>
                {if isset($smarty.session.user) && $smarty.session.user.user_funct_id != 1 && $smarty.session.user.user_id != $smarty.get.id}
                    <form method="post" class="d-block ms-auto col-auto">
                        <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                        <input type="radio" class="btn-check" name="spoiler" value="{$review->getId()}" id="filter-spoiler-{$review->getId()}" onchange="this.form.submit()">
                        <label class="form-label m-0" for="filter-spoiler-{$review->getId()}"><i class="bi bi-eye{if $review->getSpoiler() == 1}-slash{/if} fs-2"></i></label>
                    </form>
                    <form method="post" class="d-block col-auto">
                        <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                        <input type="radio" class="btn-check" name="deleteComment"
                               value="{$review->getId()}"
                               id="filter-delete-{$review->getId()}"
                               onchange="if(confirm('Voulez-vous vraiment supprimer ce commentaire ?')) { this.form.submit(); } else { this.checked = false; }">
                        <label class="form-label m-0" for="filter-delete-{$review->getId()}"><i class="bi bi-trash3 fs-3"></i></label>
                    </form>
                {elseif isset($smarty.session.user) && $smarty.session.user.user_id == $smarty.get.id}
                    <form method="post" class="d-block ms-auto col-auto"
                            onsubmit="return confirm('Voulez-vous vraiment supprimer ce commentaire ?')">
                        <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                        <button type="submit" name="deleteComment" value="{$review->getId()}"
                                class="border-0 bg-transparent p-0">
                            <i class="bi bi-trash3 fs-3"></i>
                        </button>
                    </form>
                    <div class="d-block text-end col-auto">
                        <button type="button" class="spanMovie border-0 edit-comment bg-transparent" onclick="enableEdit('{$review->getId()}')">
                            <i class="bi bi-pencil-square fs-3"></i>
                        </button>
                    </div>
                {else}

                    {if $review->getReported() == 0}
                        <button class="border-0 bg-transparent text-end col-6 pe-3" data-bs-toggle="modal" data-bs-target="#reportModal-review-{$review->getId()}">
                            <i class="bi bi-flag fs-3 ms-auto"></i>
                        </button>
                        <div class="modal fade m-auto" id="reportModal-review-{$review->getId()}" tabindex="-1">
                            <div class="modal-dialog">
                                <form method="POST" class="modal-content">
                                    <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                                    <input type="hidden" name="commentReportId" value="{$review->getId()} ">
                                    <div class="modal-header border-0"">
                                        <h5 class="modal-title">Signaler : {$review->getTitle()} </h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>

                                    <div class="modal-body">
                                        <p>Pour que votre signalement sois prit en charge veuillez renseigner la raison !</p>
                                        <textarea name="commentReport" class="form-control" placeholder="Raison du signalement..."></textarea>
                                    </div>

                                    <div class="modal-footer border-0 mx-auto">
                                        <button type="button" class="btn btn-outline-dark px-3" data-bs-dismiss="modal">Annuler</button>
                                        <button type="submit" class="btn btn-outline-success px-3">Validez</button>
                                    </div>

                                </form>
                            </div>
                        </div>
                    {else}
                        <button class="border-0 bg-transparent text-end col-6 pe-3" data-bs-toggle="modal" data-bs-target="#reportModal-review-{$review->getId()}">
                            <i class="bi bi-flag-fill fs-3 ms-auto"></i>
                        </button>
                        <div class="modal fade" id="reportModal-review-{$review->getId()}" tabindex="-1">
                            <div class="modal-dialog">
                                <form method="POST" class="modal-content">
                                    <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                                    <div class="modal-header border-0"">
                                        <h5 class="modal-title">Signaler : {$review->getTitle()} </h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>

                                    <div class="modal-body">
                                        <p>Voulez vous vraiment supprimer votre signalement ?</p>
                                    </div>

                                    <div class="modal-footer border-0 mx-auto">
                                        <button type="button" class="btn btn-outline-dark px-3" data-bs-dismiss="modal">Annuler</button>
                                        <button type="submit" name="repComDelete" value="{$review->getId()}" class="btn btn-outline-danger px-3">Supprimer</button>
                                    </div>

                                </form>
                            </div>
                        </div>
                    {/if}
                    
                {/if}
            </div>
        </div>
    </div>
</div>

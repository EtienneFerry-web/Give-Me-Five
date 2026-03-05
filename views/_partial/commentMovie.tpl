<div class="comment my-5">
    {if $comment->getSpoiler() == 1}
        <div class="comment-spoiler" id="spoiler">
            <h3 class="border-0">Anti-Spoiler</h3>
            <p>Attention ce commentaire contient un spoiler !</p>
            <h4>Cliquez pour voir le commentaire !</h4>
        </div>
    {/if}

    <div class="row align-items-center g-2"> <div class="col-auto">
        <a href="{$smarty.env.BASE_URL}user/userPage/{$comment->getUser_id()}" class="d-block">
            <img src="{$smarty.env.BASE_URL}assets/img/users/{$comment->getPhoto()}"
                 class="rounded-circle border"
                 style="width: 40px; height: 40px; object-fit: cover;"
                 alt="Avatar">
        </a>
    </div>
    <div class="col-auto p-0">
        <a href="{$smarty.env.BASE_URL}user/userPage/{$comment->getUser_id()}" class="text-decoration-none">
            <span class="spanMovie">{$comment->getPseudo()}</span>
        </a>
    </div>
    <div class="col-auto ms-auto">
        <span class="pageMovieNote spanMovie" data-note="{$comment->getRating()}">
            <span class="stars d-block"></span>
        </span>
    </div>
</div>

    <p>
        {$comment->getComment()}
    </p>
   
    <div class="row align-items-center">
        <span class="spanMovie d-block col-auto">{$comment->getDateFormat()}</span>
        <div class="col-auto">
            {if isset($smarty.session.user)}
            <form method="post" class="js-like-form m-0">
                <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                <input type="hidden" name="likeCommentBtn" value="{$comment->getId()}">
                <button {if isset($smarty.session.user)} type="submit" {/if} class="border-0 bg-transparent p-0 text-decoration-none">
                    <label class="form-label m-0 d-flex align-items-center gap-1" style="cursor:pointer;">
                        {if $comment->getUser_liked()}
                            <i class="bi bi-heart-fill fs-4"></i>
                        {else}
                            <i class="bi bi-heart fs-4"></i>
                        {/if}
                        <span class="like-count"> {$comment->getLike()}</span>
                    </label>
                </button>
            </form>
            {else}
            <label class="form-label m-0 d-flex align-items-center gap-1" style="cursor:pointer;">
                    <i class="bi bi-heart fs-4"></i>
                <span class="like-count"> {$comment->getLike()}</span>
            </label>
            {/if}
        </div>
        <div class="col d-flex justify-content-end align-items-center">
            {if isset($smarty.session.user) && $smarty.session.user.user_funct_id == 1}
                {if $comment->getReported() == 0}
                    <button class="border-0 bg-transparent p-0" data-bs-toggle="modal" data-bs-target="#reportModal-review-{$comment->getId()}">
                        <i class="bi bi-flag fs-3"></i>
                    </button>
                    <div class="modal fade" id="reportModal-review-{$comment->getId()}" tabindex="-1">
                        <div class="modal-dialog">
                            <form method="POST" class="modal-content text-start">
                                <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                                <input type="hidden" name="commentReportId" value="{$comment->getId()} ">
                                <div class="modal-header border-0">
                                    <h5 class="modal-title">Signaler : {$comment->getPseudo()} </h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <p>Pour que votre signalement soit pris en charge veuillez renseigner la raison !</p>
                                    <textarea name="commentReport" class="form-control" placeholder="Raison du signalement..."></textarea>
                                </div>
                                <div class="modal-footer border-0 mx-auto">
                                    <button type="button" class="btn btn-outline-dark px-3" data-bs-dismiss="modal">Annuler</button>
                                    <button type="submit" class="btn btn-outline-success px-3">Valider</button>
                                </div>
                            </form>
                        </div>
                    </div>
                {else}
                    <button class="border-0 bg-transparent p-0" data-bs-toggle="modal" data-bs-target="#reportModal-review-{$comment->getId()}">
                        <i class="bi bi-flag-fill fs-3 text-danger"></i>
                    </button>
                    <div class="modal fade" id="reportModal-review-{$comment->getId()}" tabindex="-1">
                        <div class="modal-dialog">
                            <form method="POST" class="modal-content text-start">
                                <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                                <div class="modal-header border-0">
                                    <h5 class="modal-title">Signaler : {$comment->getPseudo()} </h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <p>Voulez-vous vraiment supprimer votre signalement ?</p>
                                </div>
                                <div class="modal-footer border-0 mx-auto">
                                    <button type="button" class="btn btn-outline-dark px-3" data-bs-dismiss="modal">Annuler</button>
                                    <button type="submit" name="repComDelete" value="{$comment->getId()}" class="btn btn-outline-danger px-3">Supprimer</button>
                                </div>
                            </form>
                        </div>
                    </div>
                {/if}
            {elseif isset($smarty.session.user) && $smarty.session.user.user_funct_id != 1}
                <form method="post" class="d-inline-block m-0 me-2">
                    <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                    <input type="radio" class="btn-check" name="spoiler" value="{$comment->getId()}" id="filter-spoiler-{$comment->getId()}" onchange="this.form.submit()">
                    <label class="form-label m-0" for="filter-spoiler-{$comment->getId()}"><i class="bi bi-eye{if $comment->getSpoiler() == 1}-slash{/if} fs-2"></i></label>
                </form>
                <form method="post" class="d-inline-block m-0">
                    <input type="hidden" name="csrf_token" value="{$smarty.session.csrf_token}">
                    <input type="radio" class="btn-check" name="deleteComment"
                            value="{$comment->getId()}"
                            id="filter-delete-{$comment->getId()}"
                            onchange="if(confirm('Voulez-vous vraiment supprimer ce commentaire ?')) { this.form.submit(); } else { this.checked = false; }">
                    <label class="form-label m-0" for="filter-delete-{$comment->getId()}"><i class="bi bi-trash3 fs-3"></i></label>
                </form>
            {/if}
        </div>
    </div>
</div>
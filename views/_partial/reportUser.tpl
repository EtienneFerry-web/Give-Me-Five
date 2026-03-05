{if !empty($objReport->getTitle())}
    <li class="list-group-item d-flex flex-column flex-md-row justify-content-center align-items-start align-items-md-center gap-2 gap-md-0 p-2">
        <a class="text-decoration-none col-12 col-md-4 text-dark fw-bold" href="{$smarty.env.BASE_URL}movie/moviePage/{$objReport->getReportedMovieId()}">
            {$objReport->getTitle()}
        </a>
        <span class="col-12 col-md-4 text-start text-md-center fw-bold">Raison : {$objReport->getReason()}</span>
        <span class="col-12 col-md-4 text-start text-md-end fw-bold">{$objReport->getDeletedAt()}</span>
    </li>
{elseif !empty($objReport->getPseudo())}
    <li class="list-group-item d-flex flex-column flex-md-row justify-content-center align-items-start align-items-md-center gap-2 gap-md-0 p-2">
        <a class="text-decoration-none col-12 col-md-4 text-dark fw-bold" href="{$smarty.env.BASE_URL}user/userPage/{$objReport->getReportedUserId()}">
            {$objReport->getPseudo()}
        </a>
        <span class="col-12 col-md-4 text-start text-md-center fw-bold">Raison : {$objReport->getReason()}</span>
        <span class="col-12 col-md-4 text-start text-md-end fw-bold">{$objReport->getDeletedAt()}</span>
    </li>
{else}
    <li class="list-group-item d-flex flex-column flex-md-row justify-content-center align-items-start align-items-md-center gap-2 gap-md-0 p-2">
        <a class="text-decoration-none col-12 col-md-4 text-dark fw-bold" href="{$smarty.env.BASE_URL}user/userPage/{$objReport->getReportedUserId()}">
            Commentaire de : {$objReport->getPseudo()}
        </a>
        <span class="col-12 col-md-4 text-start text-md-center fw-bold">{$objReport->getReason()}</span>
        <span class="col-12 col-md-4 text-start text-md-end fw-bold">{$objReport->getDeletedAt()}</span>
    </li>
{/if}
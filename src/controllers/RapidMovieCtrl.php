<?php
namespace App\Controllers;

use App\Models\RapidMovieModel;
use App\Models\MovieModel;
use App\Entities\MovieEntity;

/**
 * Controller for movie search and browsing via the Streaming Availability API.
 */
class RapidMovieCtrl extends MotherCtrl {

    // Genres proposés par l'API (slugs officiels Streaming Availability)
    private const GENRES = [
        ''               => 'Tous les genres',
        'action'         => 'Action',
        'adventure'      => 'Aventure',
        'animation'      => 'Animation',
        'comedy'         => 'Comédie',
        'crime'          => 'Crime',
        'documentary'    => 'Documentaire',
        'drama'          => 'Drame',
        'family'         => 'Famille',
        'fantasy'        => 'Fantasy',
        'horror'         => 'Horreur',
        'music'          => 'Musique',
        'mystery'        => 'Mystère',
        'romance'        => 'Romance',
        'science-fiction'=> 'Science-Fiction',
        'thriller'       => 'Thriller',
        'war'            => 'Guerre',
        'western'        => 'Western',
    ];

    private const COUNTRIES = [
        'fr' => '🇫🇷 France',
        'us' => '🇺🇸 États-Unis',
        'gb' => '🇬🇧 Royaume-Uni',
        'de' => '🇩🇪 Allemagne',
        'es' => '🇪🇸 Espagne',
        'it' => '🇮🇹 Italie',
        'jp' => '🇯🇵 Japon',
        'ca' => '🇨🇦 Canada',
        'au' => '🇦🇺 Australie',
    ];

    private const SORT_OPTIONS = [
        'popularity'    => 'Popularité (tous temps)',
        'popularity_1y' => 'Popularité (1 an)',
        'rating'        => 'Note',
        'year_desc'     => 'Année (récent d\'abord)',
    ];

    /**
     * Search/browse page with filters.
     * URL: rapidMovie/search
     */
    public function search(): void
    {
        $objModel = new RapidMovieModel();

        $strTitle  = trim($_GET['title']    ?? '');
        $strGenre  = trim($_GET['genre']    ?? '');
        $intYearMin = (int)($_GET['year_min'] ?? 0) ?: null;
        $intYearMax = (int)($_GET['year_max'] ?? 0) ?: null;
        $intRating  = isset($_GET['rating_min']) && $_GET['rating_min'] !== '' ? (int)$_GET['rating_min'] : null;
        $strOrder  = $_GET['order_by'] ?? 'popularity';
        $strCountry = $_GET['country'] ?? 'fr';

        $arrMovies = [];
        $arrError  = [];

        $boolHasFilters = $strGenre !== '' || $intYearMin || $intYearMax || $intRating !== null || $strOrder !== 'popularity' || $strCountry !== 'fr';

        if ($strTitle !== '') {
            // Recherche par titre via l'endpoint title
            $raw = $objModel->searchMovieByTitle($strTitle);

            if (isset($raw['error'])) {
                $arrError[] = $raw['error'];
            } else {
                // Filtrage côté client si des filtres supplémentaires sont actifs
                foreach ($raw as $item) {
                    if ($strGenre !== '' && !empty($item['genres'])) {
                        $itemGenres = array_column($item['genres'] ?? [], 'id');
                        if (!in_array($strGenre, $itemGenres, true)) continue;
                    }
                    if ($intYearMin && ($item['mov_release_date'] ?? 0) < $intYearMin) continue;
                    if ($intYearMax && ($item['mov_release_date'] ?? 0) > $intYearMax) continue;
                    if ($intRating !== null && ($item['mov_rating'] ?? 0) * 10 < $intRating) continue;
                    $arrMovies[] = $item;
                }
            }
        } else {
            // Recherche par filtres via l'endpoint filters
            $arrFilters = [
                'country'    => $strCountry,
                'genres'     => $strGenre,
                'year_min'   => $intYearMin,
                'year_max'   => $intYearMax,
                'rating_min' => $intRating,
                'order_by'   => $strOrder,
            ];

            $raw = $objModel->searchByFilters($arrFilters);

            if (isset($raw['error'])) {
                $arrError[] = $raw['error'];
            } else {
                $arrMovies = $raw;
            }
        }

        // Enregistrement en BDD + hydratation en entités
        $arrMovieToDisplay = [];
        $objMovieModel     = new MovieModel();
        foreach ($arrMovies as $arrDetMovie) {
            // Remplace l'ID API par l'ID entier local → les cartes pointent vers moviePage/{int}
            $arrDetMovie['mov_id'] = $objMovieModel->findOrCreateApiMovie($arrDetMovie);
            $objMovie = new MovieEntity('mov_');
            $objMovie->hydrate($arrDetMovie);
            $arrMovieToDisplay[] = $objMovie;
        }

        $this->_arrData['arrMovieToDisplay'] = $arrMovieToDisplay;
        $this->_arrData['arrError']          = $arrError;
        $this->_arrData['searchedTitle']     = $strTitle;
        $this->_arrData['arrGenres']         = self::GENRES;
        $this->_arrData['arrCountries']      = self::COUNTRIES;
        $this->_arrData['arrSortOptions']    = self::SORT_OPTIONS;
        $this->_arrData['activeGenre']       = $strGenre;
        $this->_arrData['activeCountry']     = $strCountry;
        $this->_arrData['activeOrder']       = $strOrder;
        $this->_arrData['activeYearMin']     = $intYearMin;
        $this->_arrData['activeYearMax']     = $intYearMax;
        $this->_arrData['activeRatingMin']   = $intRating;
        $this->_arrData['boolHasFilters']    = $boolHasFilters || $strTitle !== '';

        $this->_display("rapidMoviesList");
    }
}

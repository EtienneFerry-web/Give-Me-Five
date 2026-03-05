<?php
namespace App\Models;

use PDO;

/**
 * @author Marco Schmitt
 * @class SearchModel
 * @brief Logic for cross-entity search using SQL UNIONs.
 */
class SearchModel extends Connect {

    /**
    * @brief Performs a global search and returns an array of DTOs.
    * @param object $objSearch Search criteria object (must have getSearch()).
    * @param int $limite Max results to fetch.
    * @param int $searchBy Category filter (0: all, 4: users, 5: movies, other: job_id).
    * 
    */
    public function searchContent(object $objSearch, int $limite, int $searchBy = 0): array {

        // Base query wrapper to allow ordering and limiting global results
        $strRq = "SELECT sear_id, sear_name, sear_content, sear_photo, sear_rating, sear_like, sear_type
                  FROM (";

        //Search Of Movies table
        if (empty($searchBy) || $searchBy == 5) {
            $strRq .= " SELECT mov_id AS sear_id, mov_title AS sear_name, mov_description AS sear_content, pho_photo AS sear_photo,
                                COALESCE(AVG(ratings.rat_score), 0) AS sear_rating,
                                COALESCE(COUNT(DISTINCT lik_user_id), 0) AS sear_like, 'movie' AS sear_type,
                                CASE
                                    WHEN mov_title LIKE :search THEN 1
                                    WHEN mov_title LIKE :startSearch THEN 2
                                ELSE 3 END AS score
                        FROM movies
                        LEFT JOIN photos ON movies.mov_id = photos.pho_mov_id
                        LEFT JOIN ratings ON movies.mov_id = ratings.rat_mov_id
                        LEFT JOIN liked ON movies.mov_id = liked.lik_mov_id
                        WHERE mov_title LIKE :fullSearch AND lik_com_id IS NULL AND mov_published_at IS NOT NULL
                        GROUP BY mov_id";
        }

        if (empty($searchBy)) {
            $strRq .= " UNION ";
        }

        //Search of Persons table
        if (empty($searchBy) || ($searchBy != 5 && $searchBy != 4)) {
            $strRq .= " SELECT pers_id AS sear_id, CONCAT(pers_name, ' ', pers_firstname) AS sear_name, pers_bio AS sear_content, pers_photo AS sear_photo, NULL AS sear_rating,  NULL AS sear_like, 'person' AS sear_type,
                               CASE
                                 WHEN CONCAT(pers_name, ' ', pers_firstname) LIKE :search THEN 1
                                 WHEN CONCAT(pers_name, ' ', pers_firstname) LIKE :startSearch THEN 2
                                 ELSE 3 END AS score
                        FROM persons
                        WHERE CONCAT(pers_name, ' ', pers_firstname) LIKE :fullSearch";

            // Apply job filter if searchBy represents a specific role ID
            if ($searchBy != 0) {
                $strRq .= " AND pers_id IN ( SELECT part_pers_id
                                             FROM participates
                                             WHERE part_job_id = :job
                                           )";
            }
        }

        if (empty($searchBy)) {
            $strRq .= " UNION ";
        }

        //Search User table
        if (empty($searchBy) || $searchBy == 4) {
            $strRq .= " SELECT user_id AS sear_id, user_pseudo AS sear_name, user_bio AS sear_content, user_photo AS sear_photo, NULL AS sear_rating,  NULL AS sear_like, 'user' AS sear_type,
                                CASE
                                    WHEN user_pseudo LIKE :search THEN 1
                                    WHEN user_pseudo LIKE :startSearch THEN 2
                                    ELSE 3 END AS score
                                FROM users
                                WHERE user_pseudo LIKE :fullSearch AND user_deleted_at IS NULL AND (user_ban_at < NOW() OR user_ban_at IS NULL)";
        }

        // Closing the subquery and applying global ordering
        $strRq .= " ) AS search_results
                    ORDER BY score, sear_name LIMIT :limit";

        // Preparation and parameter binding
        $rqPrep = $this->_db->prepare($strRq);
        $rqPrep->bindValue(":limit", $limite, PDO::PARAM_INT);
        $rqPrep->bindValue(":fullSearch", "%" . $objSearch->getSearch() . "%", PDO::PARAM_STR);
        $rqPrep->bindValue(":startSearch", $objSearch->getSearch() . "%", PDO::PARAM_STR);
        $rqPrep->bindValue(":search", $objSearch->getSearch(), PDO::PARAM_STR);

        // Bind job ID only if the placeholder exists in the generated query
        if (strpos($strRq, ':job') !== false) {
            $rqPrep->bindValue(":job", $searchBy, PDO::PARAM_INT);
        }

        $rqPrep->execute();

        return $rqPrep->fetchAll(PDO::FETCH_ASSOC);
    }
}

<?php
    namespace App\Models;
    use PDO;

    /**
     * @author Marco Schmitt
     * 27/02/2026
     * Version 1
     */
    
    class ReportModel extends connect{

        /**
         * Fetches all active reports targeting user accounts.
         * @return array A list of reported users with their bio, pseudo, and photo.
         */

        public function allUserReport(): array {
            $strRq = "  SELECT rep_id ,rep_bio_user, rep_pseudo_user, rep_reported_user_id, rep_reason, user_photo AS 'rep_photo', user_ban_at AS 'rep_user_ban'
                        FROM reports
                        INNER JOIN users ON reports.rep_reported_user_id = users.user_id
                        WHERE rep_reported_movie_id IS NULL AND rep_reported_com_id IS NULL AND rep_deleted_at IS NULL
                        GROUP BY rep_reported_user_id";

            return $this->_db->query($strRq)->fetchAll();
        }

        /**
         * Fetches all active reports targeting movies.
         * @return array A list of reported movies including their titles and the reason for the report.
         */

        public function allMovieReport(): array {
            $strRq = "  SELECT rep_id , rep_reported_movie_id, rep_reason, mov_title AS 'rep_title'
                        FROM reports
                        INNER JOIN movies ON reports.rep_reported_movie_id = movies.mov_id
                        WHERE rep_reported_user_id IS NULL AND rep_reported_com_id IS NULL AND rep_deleted_at IS NULL
                        GROUP BY rep_reported_movie_id";

            return $this->_db->query($strRq)->fetchAll();
        }

        /**
         * Fetches all reports targeting specific comments.
         * @return array A detailed list including comment content, user pseudo, and spoiler status.
         */

        public function allCommentReport(): array {
            $strRq = "  SELECT rep_id, rep_reported_com_id, rep_com_content, rep_reason, rep_reported_user_id,user_pseudo AS 'rep_pseudo', user_photo AS 'rep_photo', com_spoiler AS 'rep_spoiler', user_ban_at AS 'rep_user_ban'
                        FROM reports
                        INNER JOIN comments ON reports.rep_reported_com_id = comments.com_id
                        INNER JOIN users ON reports.rep_reported_user_id = users.user_id
                        WHERE rep_reported_movie_id IS NULL AND rep_com_content IS NOT NULL AND rep_deleted_at IS NULL
                        GROUP BY rep_reported_com_id";

            return $this->_db->query($strRq)->fetchAll();
        }
        
        public function validateReport(int $intId): bool {
            $strRq = "  UPDATE reports
                            SET rep_deleted_at = NOW()
                        WHERE rep_id = :id";

            $rqPrep = $this->_db->prepare($strRq);
    		$rqPrep->bindValue(':id', $intId, PDO::PARAM_INT);

    		return $rqPrep->execute();
        }
        
        /**
         * Deletes a specific report by its ID.
         * @param int $intId The unique identifier of the report record.
         * @return bool True if the report was successfully removed.
         */

        public function deleteReport(int $intId): bool{
            $strRq = "  DELETE FROM reports
                        WHERE rep_id = :id";

            $rqPrep = $this->_db->prepare($strRq);
    		$rqPrep->bindValue(':id', $intId, PDO::PARAM_INT);

    		return $rqPrep->execute();
        }

        /**
         * Retrieves all reports made by a specific connected user.
         * Lists the reported usernames, movie titles, and reasons for each report 
         * filed by the user identified by their ID.
         * @param int $intId The ID of the reporter (connected user).
         * @return array The list of reports with associated user and movie details.
         */

        public function repOfConnectUser(int $intId): array {

            $strRq = "  SELECT user_pseudo AS 'rep_pseudo', mov_title AS 'rep_title', rep_reason, rep_deleted_at, rep_reported_user_id, rep_reported_movie_id
                        FROM reports
                        LEFT JOIN users ON reports.rep_reported_user_id = users.user_id
                        LEFT JOIN movies ON reports.rep_reported_movie_id = movies.mov_id
                        WHERE rep_reporter_user_id = :id";

            $rqPrep = $this->_db->prepare($strRq);
    		$rqPrep->bindValue(':id', $intId, PDO::PARAM_INT);

    		 $rqPrep->execute();

            return $rqPrep->fetchAll();
        }
    }

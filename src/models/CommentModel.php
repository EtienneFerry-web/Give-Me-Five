<?php
    namespace App\Models;

    use PDO;
	use PDOException;

     /**
     * 27/02/2026
     * Version 1
     */

    class CommentModel extends Connect{

        /**
        * @author Marco Schmitt
        * Retrieving all comments for a specific movie
        * @param int $idMovie the identifier of the movie
        * @param int $idConnectUser the ID of the currently logged-in user (for personalized flags)
        * @return array the list of comments including user info, ratings, like counts, and report status
        */

        public function commentOfMovie(int $idMovie=0, $idConnectUser=0): array{

            $strRq	= " SELECT
                            comments.com_id,
                            comments.com_user_id,
                            comments.com_spoiler,
                            users.user_pseudo AS com_pseudo,
                            users.user_photo AS com_photo,
                            comments.com_comment,
                            ratings.rat_score AS com_rating,
                            comments.com_datetime,
                            COUNT(DISTINCT liked.lik_user_id) AS com_like,

                            EXISTS(
                            SELECT 1 FROM reports
                            WHERE rep_reported_com_id = comments.com_id
                            AND rep_reporter_user_id = :userId
                            AND rep_deleted_at IS NULL
                            ) AS 'com_reported',

                            EXISTS(
                                SELECT 1 FROM liked
                                WHERE lik_user_id = :userId
                                AND lik_mov_id IS NULL
                                AND lik_com_id = comments.com_id
                            ) AS com_user_liked

                        FROM comments
                        INNER JOIN users ON comments.com_user_id = users.user_id
                        INNER JOIN movies ON comments.com_movie_id = movies.mov_id
                        LEFT JOIN liked ON liked.lik_com_id = comments.com_id AND liked.lik_mov_id IS NULL
                        LEFT JOIN ratings ON ratings.rat_mov_id = movies.mov_id AND ratings.rat_user_id = users.user_id
                        WHERE movies.mov_id = :id AND user_deleted_at IS NULL AND (user_ban_at < NOW() OR user_ban_at IS NULL)
                        GROUP BY
                            comments.com_id,
                            comments.com_user_id,
                            users.user_pseudo,
                            comments.com_comment,
                            ratings.rat_score,
                            comments.com_datetime";


            $stmt = $this->_db->prepare($strRq);
            $stmt->bindValue(':id', $idMovie, PDO::PARAM_INT);
            $stmt->bindValue(':userId', $idConnectUser, PDO::PARAM_INT);
            $stmt->execute();

		    return $stmt->fetchAll();

        }

        /**
        * @author Marco Schmitt
        * Retrieving all reviews and ratings posted by a specific user
        * @param int $idUser the identifier of the user whose reviews are being fetched
        * @param int $idConnectUser the ID of the currently logged-in user (to check for interaction flags)
        * @return array a collection of reviews including movie titles, posters, ratings, and social interactions
        */

        public function reviewUser(int $idUser=0, int $idConnectUser=0): array{

            $strRq	="  SELECT
                            com_id,
                            comments.com_spoiler,
                            movies.mov_id AS 'com_movieId',
                            photos.pho_photo AS 'com_photo',
                            movies.mov_title AS 'com_title',
                            comments.com_comment,
                            ratings.rat_score AS 'com_rating',
                            COUNT(DISTINCT liked.lik_user_id) AS 'com_like',
                            com_datetime,

                        EXISTS(
                            SELECT 1 FROM reports
                            WHERE rep_reported_com_id = comments.com_id
                            AND rep_reporter_user_id = :userId
                            AND rep_pseudo_user IS NULL
                        ) AS 'com_reported',

                        EXISTS(
                            SELECT 1 FROM liked
                            WHERE lik_user_id = :userId
                            AND lik_mov_id IS NULL
                            AND lik_com_id = comments.com_id
                        ) AS com_user_liked

                        FROM users
                        INNER JOIN ratings ON users.user_id = ratings.rat_user_id
                        INNER JOIN movies ON ratings.rat_mov_id = movies.mov_id
                        INNER JOIN comments ON (users.user_id = comments.com_user_id AND movies.mov_id = comments.com_movie_id)
                        INNER JOIN photos ON movies.mov_id = photos.pho_mov_id AND pho_type = 'Affiche'
                        LEFT JOIN liked ON liked.lik_com_id = comments.com_id AND liked.lik_mov_id IS NULL
                        WHERE users.user_id = :id AND user_deleted_at IS NULL AND (user_ban_at < NOW() OR user_ban_at IS NULL)

                        GROUP BY
                            comments.com_id,
                            comments.com_user_id,
                            users.user_pseudo,
                            comments.com_comment,
                            ratings.rat_score,
                            comments.com_datetime,
                            photos.pho_photo,
                            movies.mov_id,
                            movies.mov_title";


	        $stmt = $this->_db->prepare($strRq);
            $stmt->bindValue(':id', $idUser, PDO::PARAM_INT);
            $stmt->bindValue(':userId', $idConnectUser, PDO::PARAM_INT);
            $stmt->execute();

		    return $stmt->fetchAll();


        }


        /**
         * @author Etienne
         * Function insert Comment & rating in database
         * @param object $objComment Comment object
         * @todo la note est ajouté instant donc inutile 
         */

        public function commentInsert(object $objComment): array | bool {

            $sql1 = "INSERT IGNORE INTO comments (com_comment, com_user_id, com_movie_id, com_datetime)
                    VALUES (:comment, :userId, :movieId, NOW())";

            $rq1 = $this->_db->prepare($sql1);
            $rq1->bindValue(":comment", $objComment->getComment(), PDO::PARAM_STR);
            $rq1->bindValue(":userId",  $objComment->getUser_id(), PDO::PARAM_INT);
            $rq1->bindValue(":movieId", $objComment->getMovieId(), PDO::PARAM_INT);

            $success1 = $rq1->execute();

            if ($rq1->rowCount() === 0) {
                return [
                    'success' => false,
                    'error' => 'Vous avez déjà commenté ce film, vous pouvez le modifier dans votre profil !'
                ];
            }

            $sql2 = "INSERT INTO ratings (rat_user_id, rat_mov_id, rat_score)
                    VALUES (:userId, :movieId, :rating)
                    ON DUPLICATE KEY UPDATE rat_score = :rating";



            $rq2 = $this->_db->prepare($sql2);
            $rq2->bindValue(":userId",  $objComment->getUser_id(), PDO::PARAM_INT);
            $rq2->bindValue(":movieId", $objComment->getMovieId(), PDO::PARAM_INT);
            $rq2->bindValue(":rating",  $objComment->getRating(),  PDO::PARAM_STR);

            $success2 = $rq2->execute();

            return ($success1 && $success2);
        }

        /**
        * @author Marco Schmitt
        * Modifying an existing comment and its associated rating
        * @param object $objComment the CommentEntity containing the updated data
        * @param int $comId the identifier of the user performing the modification
        * @return bool|array returns true if all updates succeed, or an error array if the row wasn't found
        */

        public function commentModify(object $objComment, int $comId): bool|array{
            
            $sql1 = "   UPDATE comments
                        SET com_comment = :comment,
                        com_updated_at = NOW()
                        WHERE com_id = :id AND com_user_id = :userId";

            $rq1 = $this->_db->prepare($sql1);
            $rq1->bindValue(":comment", $objComment->getComment(), PDO::PARAM_STR);
            $rq1->bindValue(":userId",  $comId, PDO::PARAM_INT);
            $rq1->bindValue(":id", $objComment->getId(), PDO::PARAM_INT);

            $success1 = $rq1->execute();

            if ($rq1->rowCount() === 0) {
                return [
                    'success' => false,
                    'error' => 'Vous avez déjà commenté ce film, vous pouvez le modifier dans votre profil !'
                ];
            }

            $sql2 = "   UPDATE ratings
                        SET rat_score = :rating
                        WHERE rat_user_id = :userId AND rat_mov_id = :movieId";


            $rq2 = $this->_db->prepare($sql2);
            $rq2->bindValue(":userId",  $comId, PDO::PARAM_INT);
            $rq2->bindValue(":movieId", $objComment->getMovieId(), PDO::PARAM_INT);
            $rq2->bindValue(":rating",  $objComment->getRating(),  PDO::PARAM_STR);

            $success2 = $rq2->execute();

            $sql3 = " DELETE FROM liked WHERE lik_com_id = :id AND lik_mov_id IS NULL";


            $rq3 = $this->_db->prepare($sql3);
            $rq3->bindValue(":id", $objComment->getId(), PDO::PARAM_INT);

            $success3 = $rq3->execute();

            return ($success1 && $success2 && $success3);


        }

        /**
        * @author Marco Schmitt
        * Deleting a comment from the database
        * @param object $objComment the CommentEntity containing the ID and the requester's user ID
        * @return bool returns true if the deletion was successful (authorized by ownership or rank)
        */

        public function deleteComment(object $objComment):bool{

            $strRq = "  DELETE FROM comments
                        WHERE com_id = :comId
                        AND (com_user_id = :userId
                        OR :userId IN ( SELECT user_id
                                        FROM users
                                        WHERE user_id = :userId
                                        AND (user_funct_id = 2 OR user_funct_id = 3)))";

            $rq = $this->_db->prepare($strRq);

            $rq->bindValue(":comId",  $objComment->getId(), PDO::PARAM_INT);
            $rq->bindValue(":userId", $objComment->getUser_id(), PDO::PARAM_INT);

            return $rq->execute();

        }

        /**
        * @author Marco Schmitt
        * Toggling the spoiler status of a comment
        * @param int $idComment the identifier of the comment to update
        * @return bool returns true if the toggle was successful
        */

        public function addSpoiler(int $idComment):bool{
            $strRq = "  UPDATE comments
                        SET com_spoiler = NOT com_spoiler
                        WHERE com_id = :id";

            $rq = $this->_db->prepare($strRq);

            $rq->bindValue(':id', $idComment, PDO::PARAM_INT);

            return $rq->execute();
        }

        /**
        * @author Marco Schmitt
        * Reporting a comment for moderation
        * @param object $objReport the ReportEntity containing the comment ID and reason
        * @param int $reporterId the ID of the user filing the report
        * @return bool returns true if the report was successfully created, false if the comment was not found
        */

        public function reportComment(object $objReport, int $reporterId): bool {

            $strRq = "  SELECT com_comment, com_user_id
                        FROM comments
                        WHERE com_id = :comId";

            $rq = $this->_db->prepare($strRq);
            $rq->bindValue(':comId', $objReport->getReportedComId(), PDO::PARAM_INT);
            $rq->execute();

            $arrData = $rq->fetch();

            if ($arrData) {

                $strRq = "  INSERT INTO reports (rep_reported_user_id, rep_com_content, rep_reported_com_id, rep_reason, rep_reporter_user_id, rep_date)
                            VALUES (:reportedId, :content, :comId, :reason, :reporterId, NOW())";

                $rqPrep = $this->_db->prepare($strRq);

                $rqPrep->bindValue(':comId', $objReport->getReportedComId(), PDO::PARAM_INT);
                $rqPrep->bindValue(':reportedId', $arrData['com_user_id'], PDO::PARAM_INT);
                $rqPrep->bindValue(':reporterId', $reporterId, PDO::PARAM_INT);
                $rqPrep->bindValue(':content', $arrData['com_comment'], PDO::PARAM_STR);
                $rqPrep->bindValue(':reason', $objReport->getReason(), PDO::PARAM_STR);

                return $rqPrep->execute();

            }

            return false;
        }

        /**
        * @author Marco Schmitt
        * Removing a specific comment report
        * @param object $objReport the ReportEntity containing the reported comment identifier
        * @param int $intId the identifier of the reporter who filed the report
        * @return bool returns true if the specific comment report was successfully deleted
        */

        public function deleteRepCom(object $objReport, int $intId ):bool{

                  $strRq = "  DELETE FROM reports
                              WHERE  rep_reported_com_id  = :comId AND rep_reporter_user_id = :reporter AND rep_pseudo_user IS NULL AND rep_reported_movie_id IS NULL";

            		$rqPrep = $this->_db->prepare($strRq);

            		$rqPrep->bindValue(':comId', $objReport->getReportedComId(), PDO::PARAM_INT);
            		$rqPrep->bindValue(':reporter', $intId, PDO::PARAM_INT);

            		return $rqPrep->execute();
		}

        /**
        * @author Etienne
        * Toggling a like on a comment
        * @param int $intUserId the identifier of the user liking the comment
        * @param int $intComId the identifier of the comment being liked
        * @return int returns 1 if a like was added, 2 if a like was removed
        */

        public function likeComment($intUserId, $intComId): int{

            $strRq = "INSERT IGNORE INTO liked(lik_user_id, lik_com_id)
                VALUES (:user_id, :com_id)";

			$rqPrep	= $this->_db->prepare($strRq);

				$rqPrep->bindValue(":user_id", $intUserId, PDO::PARAM_INT);
				$rqPrep->bindValue(":com_id", $intComId, PDO::PARAM_INT);

			$rqPrep->execute();

            if($rqPrep->rowCount() > 0){

            return 1;

            } else {

                $deleteRq = "   DELETE FROM liked
                                WHERE lik_com_id   = :com_id
                                AND lik_user_id     = :user_id";

                $prepDelete = $this->_db->prepare($deleteRq);
                $prepDelete->bindValue(':com_id', $intComId, PDO::PARAM_INT);
                $prepDelete->bindValue(':user_id', $intUserId, PDO::PARAM_INT);

                $prepDelete->execute();

                return 2;

            }
		}
        
        /**
        * @author Etienne
        * Getting the total number of comments in the database
        * @return int the total count of all user comments
        */

        public function countAllComments(): int {
            $strRq = "SELECT COUNT(*)
                        FROM comments";
            return $this->_db->query($strRq)->fetchColumn();
        }
    }

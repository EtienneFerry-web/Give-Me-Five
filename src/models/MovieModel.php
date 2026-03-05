<?php
    namespace App\Models;
    use PDO;

    /**
     * 27/02/2026
     * Version 1
     */

    class MovieModel extends Connect{

        public string $producer     = '';
        public string $actor        = '';
        public string $realisator   = '';
        public string $categories   = '';
        public string $country      = '';
        public string $date         = '';
        public string $startdate    = '';
        public string $enddate      = '';
        public string $order        = '';
        public string $job          = 'ASC';

        /**
        * @author Marco
        * Retrieving a list of all movies in the database
        * @return array a collection containing only the ID and title of every movie
        */

        public function findAllMovies(): array {
            $strRq = "SELECT mov_id, mov_title
                        FROM movies";
            return $this->_db->query($strRq)->fetchAll();
        }

        /**
        * @author Marco
        * Retrieving recent movie releases from the last 30 days
        * @return array a list of movies with their official poster, average rating, and like count
        */

        public function newMovie(): array {
          $strRq	= "
                        SELECT mov_id, pho_photo AS 'mov_photo', COALESCE(AVG(ratings.rat_score), 0) AS 'mov_rating', COUNT(DISTINCT lik_user_id) AS 'mov_like'
                        FROM movies
                        LEFT JOIN photos ON movies.mov_id = photos.pho_mov_id
                        LEFT JOIN ratings ON movies.mov_id = ratings.rat_mov_id
                        LEFT JOIN liked ON movies.mov_id = liked.lik_mov_id AND liked.lik_com_id IS NULL
                        WHERE mov_release_date BETWEEN CURDATE() - INTERVAL 30 DAY AND CURDATE() AND photos.pho_type = 'Affiche' AND mov_published_at IS NOT NULL
                        GROUP BY movies.mov_id,  pho_photo
                        ";

            return $this->_db->query($strRq)->fetchAll();
        }

        /**
        * @author Marco 
        * Dynamic filtering and retrieval of all movies
        * @return array a filtered collection of movies with ratings, likes, and posters
        */

        public function allMovie(): array {
           
            $strRq = " SELECT mov_id, mov_title, mov_description, pho_photo AS 'mov_photo',
                            COALESCE(AVG(ratings.rat_score), 0) AS 'mov_rating',
                            COUNT(DISTINCT lik_user_id) AS 'mov_like'
                    FROM movies
                    LEFT JOIN photos ON movies.mov_id = photos.pho_mov_id
                    LEFT JOIN ratings ON movies.mov_id = ratings.rat_mov_id
                    LEFT JOIN liked ON movies.mov_id = liked.lik_mov_id AND liked.lik_com_id IS NULL
                    WHERE mov_published_at IS NOT NULL
                    ";

            $conditions = [];

            if (!empty($this->actor)) {
                $conditions[] = "participates.part_job_id = 3 AND participates.part_pers_id = :actor";
            }

            if (!empty($this->producer)) {
                $conditions[] = "participates.part_job_id = 2 AND participates.part_pers_id = :producer";
            }

            if (!empty($this->realisator)) {
                $conditions[] = "participates.part_job_id = 1 AND participates.part_pers_id = :realisator";
            }

            if (!empty($conditions)) {
                $strRq .= " AND mov_id IN (
                                SELECT part_mov_id
                                FROM participates
                                WHERE " . implode(" OR ", $conditions) . "
                            )";
                
            }

            if (!empty($this->categories)) {
                $strRq .= " AND mov_id IN (
                                SELECT belong_mov_id
                                FROM belongs
                                WHERE belong_cat_id = :category
                            )";
                
            }

            if (!empty($this->country)) {
                $strRq .= " AND mov_nat_id = :country";
                
            }

            if (!empty($this->date)) {
                $strRq .= " AND mov_release_date = :date";
            } elseif (!empty($this->startdate) && !empty($this->enddate)) {
                $strRq .= " AND mov_release_date BETWEEN :startDate AND :endDate";
            } elseif (!empty($this->startdate)) {
                $strRq .= " AND mov_release_date > :startDate";
            } elseif (!empty($this->enddate)) {
                $strRq .= " AND mov_release_date < :endDate";
            }

            $strRq .= " GROUP BY movies.mov_id
                        ORDER BY mov_release_date DESC";


            $stmt = $this->_db->prepare($strRq);


            if (!empty($this->actor)) {
                $stmt->bindValue(':actor', $this->actor, PDO::PARAM_INT);
            }
            if (!empty($this->producer)) {
                $stmt->bindValue(':producer', $this->producer, PDO::PARAM_INT);
            }
            if (!empty($this->realisator)) {
                $stmt->bindValue(':realisator', $this->realisator, PDO::PARAM_INT);
            }
            if (!empty($this->categories)) {
                $stmt->bindValue(':category', $this->categories, PDO::PARAM_INT);
            }
            if (!empty($this->country)) {
                $stmt->bindValue(':country', $this->country, PDO::PARAM_INT);
            }
            if (!empty($this->date)) {
                $stmt->bindValue(':date', $this->date, PDO::PARAM_STR);
            }
            if (!empty($this->startdate)) {
                $stmt->bindValue(':startDate', $this->startdate, PDO::PARAM_STR);
            }
            if (!empty($this->enddate)) {
                $stmt->bindValue(':endDate', $this->enddate, PDO::PARAM_STR);
            }

            $stmt->execute();

            return $stmt->fetchAll();
        }

        /**
         * Retrieves comprehensive details for a specific movie, including user-specific interactions.
         * * This method fetches movie data combined with:
         * - Global statistics: average rating (COALESCE to 0) and total likes count.
         * - User context: checks if the given user ID has liked the movie, reported it, 
         * or already assigned a personal rating.
         * * @author Marco
         * @param int $idMovie The unique identifier of the movie.
         * @param int $intUserId The ID of the current user (defaults to 0 for guests).
         * @return array An associative array containing movie details and user-specific status.
         */

        public function findMovie(int $idMovie, int $intUserId = 0): array | bool {

            $strRq  = " SELECT movies.*,
                            pho_photo AS 'mov_photo',
                            COALESCE(AVG(ratings.rat_score), 0) AS 'mov_rating',

                            COUNT(DISTINCT liked.lik_user_id ) AS 'mov_like',
                            nat_country AS 'mov_country',

                            EXISTS(
                                SELECT 1 FROM liked
                                WHERE lik_user_id = :user_id
                                AND lik_com_id IS NULL
                                AND lik_mov_id = movies.mov_id
                            ) AS mov_user_liked,

                            EXISTS(
                                SELECT 1 FROM reports
                                WHERE rep_reporter_user_id = :user_id
                                AND rep_reported_movie_id = movies.mov_id
                                AND rep_deleted_at IS NULL

                            ) AS mov_reported,

                            (
                                SELECT rat_score FROM ratings
                                WHERE rat_user_id = :user_id
                                AND rat_mov_id = movies.mov_id
                            ) AS mov_note_user

                        FROM movies
                        LEFT JOIN photos ON movies.mov_id = photos.pho_mov_id
                        LEFT JOIN nationalities ON movies.mov_nat_id = nationalities.nat_id
                        LEFT JOIN ratings ON movies.mov_id = ratings.rat_mov_id

                        LEFT JOIN liked ON movies.mov_id = liked.lik_mov_id AND liked.lik_com_id IS NULL
                        WHERE mov_id = :id AND mov_published_at IS NOT NULL
                        GROUP BY movies.mov_id";

            $stmt = $this->_db->prepare($strRq);
            $stmt->bindValue(':id', $idMovie, PDO::PARAM_INT);
            $stmt->bindValue(':user_id', $intUserId, PDO::PARAM_INT);
            $stmt->execute();

            return $stmt->fetch();
        }

        /**
         * Retrieves detailed information for a single movie by its ID.
         * * Joins multiple tables (photos, nationalities, categories) to provide 
         * a complete dataset for the specific movie requested via GET parameters.
         * * @author Audrey
         * @return array An associative array containing the movie's full details.
         */

		public function findOneMovie(): array {
            $strRq	= " SELECT movies.*,
                            mov_original_title AS 'mov_orginalTitle',
                            pho_photo AS 'mov_photo',
                            nat_id AS 'mov_CountryId',
                            nat_country AS 'mov_country',
                            belong_mov_id AS 'mov_belong_id',
                            cat_id AS 'mov_categoriesId',
                            cat_name AS 'mov_categorie',
                            mov_published_at
                        FROM movies
                        INNER JOIN photos ON movies.mov_id = photos.pho_mov_id
                        INNER JOIN nationalities ON movies.mov_nat_id = nationalities.nat_id
                        INNER JOIN belongs ON movies.mov_id = belongs.belong_mov_id
                        INNER JOIN categories ON belongs.belong_cat_id = categories.cat_id
                        WHERE mov_id = :id";


            $prep = $this->_db->prepare($strRq);
            $prep->bindValue(':id', $_GET['id'], PDO::PARAM_INT);
            $prep->execute();

            return $prep->fetch();
        }

        /**
         * Deletes a user's rating for a specific movie if no associated comment exists.
         * * This method first checks the 'comments' table. If no comment is found for the 
         * given user and movie, it proceeds to delete the record from the 'ratings' table.
         * * @author Marco
         * @param int $intUserId The unique identifier of the user.
         * @param int $intMovieId The unique identifier of the movie.
         * @return bool True if the rating was deleted, false if a comment exists or if the query failed.
         */

        public function deleteNoteUser(int $intUserId, int $intMovieId ): bool{

            $strRq = "  SELECT COUNT(*) AS 'nbr'
                        FROM comments
                        WHERE com_user_id = :userId AND com_movie_id = :movieId ";

            $rqPrep = $this->_db->prepare($strRq);

            $rqPrep->bindValue(":userId", $intUserId, PDO::PARAM_INT);
			$rqPrep->bindValue(":movieId", $intMovieId, PDO::PARAM_INT);

			$rqPrep->execute();

			$count =  $rqPrep->fetch();

            if($count['nbr'] == 0){
                $strRq = "  DELETE FROM ratings
                            WHERE rat_user_id = :userId
                            AND rat_mov_id = :movieId";

                $rqPrep = $this->_db->prepare($strRq);

                $rqPrep->bindValue(":userId", $intUserId, PDO::PARAM_INT);
    			$rqPrep->bindValue(":movieId", $intMovieId, PDO::PARAM_INT);

    			return $rqPrep->execute();
            } else{
                return false;
            }

        }

        /**
         * Updates all information related to a movie in the database.
         * * This method updates the main movie details, its associated photo, 
         * and its category assignment within a single flow.
         * * @author Audrey
         * @param object $objNewMovie The movie object containing the updated data.
         * @return bool True on success, false otherwise.
         */

		public function updateMovie(object $objNewMovie){

		// Request construction
			$strRq 	=   "UPDATE movies
                         SET mov_title = :title,
                             mov_original_title = :originalTitle,
                             mov_length = :length,
                             mov_description = :description,
                             mov_release_date = :createDate,
                             mov_nat_id = :idNationality,
                             mov_trailer_url = :trailer,
                             mov_updated_at = NOW()
						 WHERE mov_id= :id";
			// Prepared request
			$rqPrep	= $this->_db->prepare($strRq);
			// Sending information
			$rqPrep->bindValue(":title", $objNewMovie->getTitle(), PDO::PARAM_STR);
			$rqPrep->bindValue(":originalTitle", $objNewMovie->getOriginalTitle(), PDO::PARAM_STR);
			$rqPrep->bindValue(":length", $objNewMovie->getLength(), PDO::PARAM_STR);
			$rqPrep->bindValue(":description", $objNewMovie->getDescription(), PDO::PARAM_STR);
			$rqPrep->bindValue(":createDate", $objNewMovie->getRelease_date(), PDO::PARAM_STR);
			$rqPrep->bindValue(":idNationality", $objNewMovie->getCountryId(), PDO::PARAM_INT);
			$rqPrep->bindValue(":trailer", $objNewMovie->getTrailer(), PDO::PARAM_STR);
			$rqPrep->bindValue(":id", $objNewMovie->getId(), PDO::PARAM_STR);

			// Request execution
			$result = $rqPrep->execute();

            if ($result){

                $strRq2 = "UPDATE photos
                            SET pho_photo = :photo,
                                pho_mov_id = :idMovie,
                                pho_updated_at = NOW()
                            WHERE pho_mov_id = :idMovie";

            $rqPrep2	= $this->_db->prepare($strRq2);
            $rqPrep2->bindValue(":photo", $objNewMovie->getPhoto(), PDO::PARAM_STR);
            $rqPrep2->bindValue(":idMovie", $objNewMovie->getId(), PDO::PARAM_INT);

             $resultPhoto = $rqPrep2->execute();

                if ($resultPhoto){

                    $strRq3 =" UPDATE belongs
                                SET belong_cat_id = :catId,
                                    belong_mov_id = :idMovie
                                WHERE belong_mov_id = :idMovie";
                    $rqPrep3	= $this->_db->prepare($strRq3);
                    $rqPrep3->bindValue(":catId", $objNewMovie->getCategoriesId(), PDO::PARAM_STR);
                    $rqPrep3->bindValue(":idMovie", $objNewMovie->getId(), PDO::PARAM_INT);

                    return $rqPrep3->execute();
                }

            }

		}
        /**
        * @author Marco
        * Retrieving full details for a single movie
        * @param int $idMovie the identifier of the movie to fetch
        * @param int $intUserId the ID of the connected user to retrieve personalized flags (rating, like, report)
        * @return array|bool the movie details and user-specific interactions, or false if not found
        */

		public function movieOfPerson(int $idPerson=0):array{

            $direction = (strtoupper($this->order) === 'ASC') ? 'ASC' : 'DESC';

          	$strRq	= " SELECT
                            movies.mov_id,
                            photos.pho_photo AS 'mov_photo',
                            COALESCE(AVG(ratings.rat_score), 0) AS 'mov_rating',
                            COUNT(DISTINCT lik_user_id) AS 'mov_like'
                        FROM persons
                        LEFT JOIN participates ON persons.pers_id = participates.part_pers_id
                        LEFT JOIN movies ON participates.part_mov_id = movies.mov_id
                        LEFT JOIN photos ON movies.mov_id = photos.pho_mov_id
                        LEFT JOIN ratings ON movies.mov_id = ratings.rat_mov_id
                        LEFT JOIN liked ON movies.mov_id = liked.lik_mov_id AND liked.lik_com_id IS NULL
                        WHERE persons.pers_id = :id";

            if(!empty($this->job)){
                $strRq	.=" AND mov_id IN ( SELECT part_mov_id
                                           	FROM participates
                                           	WHERE part_pers_id = :id AND part_job_id = :job )";
            }



            $strRq	.=" GROUP BY movies.mov_id";

            if(!empty($this->order)){
                $strRq	.=" ORDER BY mov_release_date $direction ";
            }

            $stmt = $this->_db->prepare($strRq);

            if(!empty($this->job)){
                $stmt->bindValue(':job', $this->job, PDO::PARAM_INT);
            }

            $stmt->bindValue(':id', $idPerson, PDO::PARAM_INT);

            $stmt->execute();

            return $stmt->fetchAll();
        }

        /**
        * @author Marco
        * Retrieving the collection of movies liked by a specific user
        * @param int $idUser the identifier of the user whose liked movies are being fetched
        * @return array a list of movies including their IDs and posters, ordered by the date they were liked
        */

        public function userLike(int $idUser=0){

            $strRq  = " SELECT
                            movies.mov_id,
                            photos.pho_photo AS 'mov_photo'
                        FROM users
                        LEFT JOIN liked ON users.user_id = liked.lik_user_id AND liked.lik_mov_id IS NOT NULL
                        INNER JOIN movies ON liked.lik_mov_id = movies.mov_id
                        INNER JOIN photos ON movies.mov_id = photos.pho_mov_id
                        WHERE user_id = $idUser
                        GROUP BY movies.mov_id
                        ORDER BY lik_created_at";

            return $this->_db->query($strRq)->fetchAll();

		}

        /**
        * @author Marco
        * Retrieving a list of all countries/nationalities
        * @return array a collection of countries with their IDs and names
        */

		public function allCountry(){

		    $strRq	= " SELECT nat_id AS 'mov_id', nat_country AS 'mov_country'
						FROM nationalities";

            return $this->_db->query($strRq)->fetchAll();

		}

        /**
        * @author Marco
        * Retrieving a list of all movie categories/genres
        * @return array a collection of categories with their IDs and names
        */

		public function allCategories(){

		    $strRq	= " SELECT cat_id AS 'mov_id', cat_name AS 'mov_categories'
						FROM categories";

            return $this->_db->query($strRq)->fetchAll();

        }

        /**
        * @author Audrey 
        * Adding a new movie and its associated metadata (photo and category)
        * @param object $objNewMovie the MovieEntity containing all details for the new entry
        * @return bool returns true if the movie, poster, and category were all successfully inserted
        */

        public function addMovie(object $objNewMovie){
		
			$strRq 	=   "INSERT INTO movies (mov_title, mov_original_title, mov_length, mov_description, mov_release_date, mov_nat_id, mov_trailer_url)
						        VALUES (:title, :originalTitle, :length, :description, :createDate, :idNationality, :trailer)";
		
			$rqPrep	= $this->_db->prepare($strRq);
			
			$rqPrep->bindValue(":title", $objNewMovie->getTitle(), PDO::PARAM_STR);
			$rqPrep->bindValue(":originalTitle", $objNewMovie->getOriginalTitle(), PDO::PARAM_STR);
			$rqPrep->bindValue(":length", $objNewMovie->getLength(), PDO::PARAM_STR);
			$rqPrep->bindValue(":description", $objNewMovie->getDescription(), PDO::PARAM_STR);
			$rqPrep->bindValue(":createDate", $objNewMovie->getRelease_date(), PDO::PARAM_STR);
			$rqPrep->bindValue(":idNationality", $objNewMovie->getCountryId(), PDO::PARAM_INT);
			$rqPrep->bindValue(":trailer", $objNewMovie->getTrailer(), PDO::PARAM_STR);

			$result = $rqPrep->execute();

            if ($result){
            $lastId = $this->_db->lastInsertId();

                $strRq2 =" INSERT INTO photos(pho_photo, pho_type, pho_mov_id)
                            VALUES (:photo, 'Affiche', :idMovie)";

            $rqPrep2	= $this->_db->prepare($strRq2);
            $rqPrep2->bindValue(":photo", $objNewMovie->getPhoto(), PDO::PARAM_STR);
            $rqPrep2->bindValue(":idMovie", $lastId, PDO::PARAM_INT);

             $resultPhoto = $rqPrep2->execute();

                if ($resultPhoto){

                    $strRq3 =" INSERT INTO belongs (belong_cat_id, belong_mov_id)
                                VALUES (:catId, :idMovie)";
                    $rqPrep3	= $this->_db->prepare($strRq3);
                    $rqPrep3->bindValue(":catId", $objNewMovie->getCategoriesId(), PDO::PARAM_STR);
                    $rqPrep3->bindValue(":idMovie", $lastId, PDO::PARAM_INT);

                    return $rqPrep3->execute();
                }
            }
		}

        /**
        * @author Audrey
        * 
        * Deleting a movie and all its associated data from the database
        * @param int $intId the identifier of the movie to be removed
        * @return bool returns true if the deletion was successful
        */
         
		public function deleteMovie(int $intId){
			$strRq = "DELETE FROM movies
					  WHERE mov_id = :id";

			$rqPrep = $this->_db->prepare($strRq);
			$rqPrep->bindValue(':id', $intId, PDO::PARAM_INT);

			return $rqPrep->execute();
        }

        /**
         * @brief Publishes a movie by setting its publication timestamp.
         * @details Updates the 'mov_published_at' field to the current date and time (NOW()), 
         * making the movie visible on the platform.
         * @author Marco
         * @param int $intId The unique identifier of the movie to be published.
         * @return bool True on success, false on failure.
         */

        public function publishMovie(int $intId){
			$strRq = "UPDATE movies
                        SET mov_published_at = NOW()
					  WHERE mov_id = :id";

			$rqPrep = $this->_db->prepare($strRq);
			$rqPrep->bindValue(':id', $intId, PDO::PARAM_INT);

			return $rqPrep->execute();
        }




        /**
        * @author Etienne
        * Toggling a like (favorite) on a movie
        * @param int $intUserId the identifier of the user liking the movie
        * @param int $intMovId the identifier of the movie being liked
        * @return int returns 1 if the movie was liked, 2 if the like was removed
        */

        public function LikeMovie($intUserId, $intMovId){

            $strRq = "INSERT IGNORE INTO liked(lik_user_id, lik_mov_id)
                VALUES (:user_id, :mov_id)";

			$rqPrep	= $this->_db->prepare($strRq);

				$rqPrep->bindValue(":user_id", $intUserId, PDO::PARAM_INT);
				$rqPrep->bindValue(":mov_id", $intMovId, PDO::PARAM_INT);

			$rqPrep->execute();

            if($rqPrep->rowCount() > 0){

            return 1;

            } else {

                $deleteRq = "   DELETE FROM liked
                                WHERE lik_mov_id  = :mov_id
                                AND lik_user_id     = :user_id";

                $prepDelete = $this->_db->prepare($deleteRq);
                $prepDelete->bindValue(':mov_id', $intMovId, PDO::PARAM_INT);
                $prepDelete->bindValue(':user_id', $intUserId, PDO::PARAM_INT);

                $prepDelete->execute();

                return 2;

            }
		}

        /**
        * @author Marco
        * Adding a community image to a movie's gallery
        * @param string $img the filename or path of the image to be added
        * @param int $intMovId the identifier of the movie the image belongs to
        * @param int $intUserId the identifier of the user uploading the image
        * @return bool|null returns true if successful, or null/false if the 20-image limit is reached
        */

		public function addImageOfMovies(string $img, int $intMovId, int $intUserId){


                $strRqCheck = "SELECT pho_photo,
                            (SELECT COUNT(*) FROM photos WHERE pho_mov_id = :movId AND pho_type = 'Content') as total
                            FROM photos
                            WHERE pho_mov_id = :movId AND pho_user_id = :userId AND pho_type = 'Content'
                            LIMIT 1";

                $rqPrepCheck = $this->_db->prepare($strRqCheck);
                $rqPrepCheck->bindValue(':movId', $intMovId, PDO::PARAM_INT);
                $rqPrepCheck->bindValue(':userId', $intUserId, PDO::PARAM_INT);
                $rqPrepCheck->execute();

                $result = $rqPrepCheck->fetch();
                $oldImg = $result['pho_photo'] ?? null;
                $totalExisting = $result['total'] ?? 0;


                if ($totalExisting < 20 || $oldImg !== null) {

                    $strRq = "INSERT INTO photos (pho_photo, pho_type, pho_mov_id, pho_user_id)
                            VALUES (:img, 'Content', :movId, :userId)
                            ON DUPLICATE KEY UPDATE pho_photo = :img";

                    $rqPrep = $this->_db->prepare($strRq);
                    $rqPrep->bindValue(':img', $img, PDO::PARAM_STR);
                    $rqPrep->bindValue(':movId', $intMovId, PDO::PARAM_INT);
                    $rqPrep->bindValue(':userId', $intUserId, PDO::PARAM_INT);

                    if ($rqPrep->execute()) {

                        return [
                                'success' => true,
                                'oldImg'  => $oldImg
                            ];
                    }
                }

                return [ 'success' => false ] ;
        }




        /**
        * @author Marco
        * Retrieving the gallery of community/content images for a movie
        * @param int $intMovId the identifier of the movie to fetch images for
        * @return array a collection of images (ID and filename) with the 'Content' type
        */

		public function selectImageMovie($intMovId){

		    $strRq = " SELECT pho_id AS 'mov_id', pho_photo AS 'mov_photo'
						FROM photos
						WHERE pho_mov_id = :id AND pho_type = 'Content'";

			$rqPrep = $this->_db->prepare($strRq);
			$rqPrep->bindValue(':id', $intMovId, PDO::PARAM_INT);
			$rqPrep->execute();
			return $rqPrep->fetchAll();
		}

        /**
        * @author Marco
        * Submitting a report for a specific movie
        * @param object $objReport the ReportEntity containing the movie ID, reporter ID, and reason
        * @return bool returns true if the report was successfully saved in the database
        */

		public function reportMovie(object $objReport){
		    $strRq = "  INSERT INTO reports (rep_reported_movie_id, rep_reporter_user_id, rep_reason ,rep_date)
					VALUES (:movieId, :reporter, :reason ,NOW())";

      		$rqPrep = $this->_db->prepare($strRq);


      		$rqPrep->bindValue(':movieId', $objReport->getReportedMovieId(), PDO::PARAM_INT);
      		$rqPrep->bindValue(':reporter', $objReport->getReporterUserId(), PDO::PARAM_INT);
            $rqPrep->bindValue(':reason', $objReport->getReason(), PDO::PARAM_STR);

      		return $rqPrep->execute();

		}

        /**
        * @author Audrey
        * Deleting a specific movie report
        * @param object $objReport the ReportEntity containing the movie ID and reporter ID
        * @return bool returns true if the report was successfully removed
        */

		public function deleteRepMovie(object $objReport){

            $strRq = "  DELETE FROM reports
                        WHERE rep_reported_movie_id = :movieId AND rep_reporter_user_id = :reporter";

      		$rqPrep = $this->_db->prepare($strRq);

      		$rqPrep->bindValue(':movieId', $objReport->getReportedMovieId(), PDO::PARAM_INT);
      		$rqPrep->bindValue(':reporter', $objReport->getReporterUserId(), PDO::PARAM_INT);

      		return $rqPrep->execute();
		}

        /**
        * @author Marco Schmitt
        * Creating or updating a user rating and retrieving the new global average
        * @param int $intIdUser the identifier of the user giving the rating
        * @param int $movId the identifier of the movie being rated
        * @param string $intNote the score value assigned by the user
        * @return array|bool the new average rating for the movie, or false if the operation failed
        */

		public function insertUpdateNote(int $intIdUser, int $movId, string $intNote){

            $strRq = "  INSERT INTO ratings (rat_user_id, rat_mov_id, rat_score)
                        VALUES (:userId, :movieId, :rating)
                        ON DUPLICATE KEY UPDATE rat_score = :rating";

            $rqPrep = $this->_db->prepare($strRq);
            $rqPrep->bindValue(":userId",  $intIdUser, PDO::PARAM_INT);
            $rqPrep->bindValue(":movieId", $movId, PDO::PARAM_INT);
            $rqPrep->bindValue(":rating",  $intNote,  PDO::PARAM_STR);

            $bool = $rqPrep->execute();

            if($bool){
                $strRq = "  SELECT AVG(rat_score) AS 'average'
                            FROM ratings
                            WHERE rat_mov_id = :movieId
                            GROUP BY rat_mov_id";

                $rqPrep2 = $this->_db->prepare($strRq);

                $rqPrep2->bindValue(":movieId", $movId, PDO::PARAM_INT);

                $rqPrep2->execute();

                return $rqPrep2->fetch();

            } else{

                return false;
            }

		}

        /**
         * Retrieves a list of movies based on search criteria, category filters, and sorting.
         * * @author Audrey
         * @param string|null $strSearch The search term for the movie title (optional).
         * @param string $strFilter The category ID to filter by (ignored if empty or '0').
         * @param string $strSort The sorting direction ('desc' for descending, defaults to ascending).
         * @return array An array of movies matching the criteria.
         */
        public function findMovieWithFilters(?string $strSearch, string $strFilter,string $strSort): array {

			$strRq = "SELECT mov_id, mov_title, cat_name AS mov_category
						FROM movies
                        INNER JOIN belongs ON belongs.belong_mov_id = movies.mov_id
                        INNER JOIN categories ON categories.cat_id = belongs.belong_cat_id
                        WHERE 1 = 1 AND mov_published_at IS NOT NULL";


			$params = [];

			if (!empty($strSearch)) {

				$strRq .= " AND mov_title LIKE :search";

				$params[':search'] = "%" . $strSearch . "%";
			}

			if (!empty($strFilter) && $strFilter !== '0'){

                 $strRq .= " AND belongs.belong_cat_id = :idCat";
                 $params[':idCat'] = $strFilter;
            }

            if ($strSort === 'desc') {
                    $strRq .= " ORDER BY mov_title DESC";
                } else {
                    $strRq .= " ORDER BY mov_title ASC";
            }

			$prep = $this->_db->prepare($strRq);

			$prep->execute($params);

			return $prep->fetchAll();
		}


        /**
        * @author Etienne
        * Getting the total number of likes across the entire platform
        * @return int the total count of all likes (movies and comments combined)
        */

        public function countAllLikes() {
			$strRq = "SELECT COUNT(*)
						FROM liked";

			return $this->_db->query($strRq)->fetchColumn();
		}

        /**
        * @author Etienne
        * Getting the total number of movies across the entire platform
        * @return int the total count of all movies 
        */

        public function countAllMovies() {
			$strRq = "SELECT COUNT(*)
						FROM movies";

			return $this->_db->query($strRq)->fetchColumn();
		}

        /**
        * @author Etienne
        * Retrieving the 10 most recently added movies
        * @return array a list of the latest movies with their like and comment counts
        */

        public function findLastMovies() {
            $strRq = "SELECT movies.mov_id, movies.mov_title, movies.mov_release_date,
                            COUNT(DISTINCT liked.lik_user_id)  AS 'mov_like',
                            COUNT(DISTINCT comments.com_id)    AS 'mov_nb_comments'
                        FROM movies
                        LEFT JOIN liked ON movies.mov_id    = liked.lik_mov_id AND liked.lik_com_id IS NULL
                        LEFT JOIN comments ON movies.mov_id = comments.com_movie_id
                        GROUP BY movies.mov_id
                        ORDER BY movies.mov_id DESC
                        LIMIT 10";
            return $this->_db->query($strRq)->fetchAll();
        }

        /**
        * @author Etienne
        * Retrieving the top 5 movies with the most likes
        * @return array the most popular movies based on user "likes"
        */

        public function findMostLikedMovies() {
            $strRq = "SELECT movies.mov_id, movies.mov_title, movies.mov_release_date,
                            COUNT(DISTINCT liked.lik_user_id)   AS 'mov_like',
                            COUNT(DISTINCT comments.com_id)      AS 'mov_nb_comments'
                        FROM movies
                        LEFT JOIN liked ON movies.mov_id = liked.lik_mov_id AND liked.lik_com_id IS NULL
                        LEFT JOIN comments ON movies.mov_id = comments.com_movie_id
                        GROUP BY movies.mov_id
                        ORDER BY mov_like DESC
                        LIMIT 5";

            return $this->_db->query($strRq)->fetchAll();
        }

        /**
        * @author Etienne
        * Retrieving the top 5 movies with the most comments
        * @return array the most discussed movies on the platform
        */

        public function findMostCommentedMovies() {
            $strRq = "SELECT movies.mov_id, movies.mov_title, movies.mov_release_date,
                            COUNT(DISTINCT liked.lik_user_id) AS 'mov_like',
                            COUNT(DISTINCT comments.com_id) AS 'mov_nb_comments'
                        FROM movies
                        LEFT JOIN liked ON movies.mov_id = liked.lik_mov_id AND liked.lik_com_id IS NULL
                        LEFT JOIN comments ON movies.mov_id = comments.com_movie_id
                        GROUP BY movies.mov_id
                        ORDER BY mov_nb_comments DESC
                        LIMIT 5";
            return $this->_db->query($strRq)->fetchAll();
        }

        /**
         * @author Marco Schmitt
         * Retrieving movies that are not yet published
         * @return array the list of movies with no publication date
         */

        public function movieNotPublished(){
            $strRq = "  SELECT mov_title, mov_id
                        FROM movies
                        WHERE mov_published_at IS NULL";
            return $this->_db->query($strRq)->fetchAll();
        }
    }

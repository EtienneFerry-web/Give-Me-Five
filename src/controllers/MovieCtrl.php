<?php
    namespace App\Controllers;

    // Modèles
    use App\Models\MovieModel;
    use App\Models\RapidMovieModel;
    use App\Models\CommentModel;
    use App\Models\PersonModel;
    // Entités
    use App\Entities\MovieEntity;
    use App\Entities\ReportEntity;
    use App\Entities\CommentEntity;
    use App\Entities\PersonEntity;

	use DateTime;
	use Exception;
    /**
     * 27/02/2026
     * Version 1
     */

    class MovieCtrl extends MotherCtrl{

		/**
		* @author Marco
        * Main home page of the application
        * @return void retrieves the latest movies and displays the homepage view
        */

        public function home(){

            $objContentModel = new RapidMovieModel;
            $objMovieModel   = new MovieModel;

            // Nouveautés : API
            $fnHydrateApi = function(array $arrMovies) use ($objMovieModel): array {
                $arr = [];
                foreach ($arrMovies as $arrDetMovie) {
                    $arrDetMovie['mov_id'] = $objMovieModel->findOrCreateApiMovie($arrDetMovie);
                    $objContent = new MovieEntity('mov_');
                    $objContent->hydrate($arrDetMovie);
                    $arr[] = $objContent;
                }
                return $arr;
            };

            // Mieux notés / Plus aimés : BDD locale
            $fnHydrateDb = function(array $arrRows): array {
                $arr = [];
                foreach ($arrRows as $arrRow) {
                    $objContent = new MovieEntity('mov_');
                    $objContent->hydrate($arrRow);
                    $arr[] = $objContent;
                }
                return $arr;
            };

            $this->_arrData['arrMovieToDisplay']       = $fnHydrateApi($objContentModel->newMovie());
            $this->_arrData['arrMostPopularToDisplay'] = $fnHydrateDb($objMovieModel->mostLikedMovie());

            // Mieux notés : fusion API + BDD triée par note décroissante
            $arrTopRatedApi = $fnHydrateApi($objContentModel->topRatedMovie());
            $arrTopRatedDb  = $fnHydrateDb($objMovieModel->topRatedMovie());
            $arrTopRated    = array_merge($arrTopRatedApi, $arrTopRatedDb);
            usort($arrTopRated, fn($a, $b) => $b->getRating() <=> $a->getRating());
            $this->_arrData['arrTopRatedToDisplay'] = $arrTopRated;

            $this->_display("home");
        }

		/**
		* @author Marco
        * Filtering and displaying the movie list
        * @return void handles search filters and hydrates entities for actors, directors, producers, and movies
        */

        public function list(){

            // -------------------------------------------------------
            // Migration BDD → API : on n'utilise PLUS MovieModel ici.
            // Toutes les données viennent exclusivement de RapidMovieModel.
            // -------------------------------------------------------
            $objRapidModel = new RapidMovieModel;
            $arrError      = [];

            // Recherche par titre si le paramètre GET 'search' est fourni
            $strSearch = trim($_GET['search'] ?? '');

            if (!empty($strSearch)) {
                $arrRawMovies = $objRapidModel->searchMovieByTitle($strSearch);
            } else {
                $arrRawMovies = $objRapidModel->newMovie();
            }


            // Vérification d'une erreur retournée par le modèle
            if (isset($arrRawMovies['error'])) {
                $arrError[]   = "L'API est temporairement indisponible : " . $arrRawMovies['error'];
                $arrRawMovies = [];
            }

            // Hydratation dans des MovieEntity (les getters sont utilisés par la vue)
            $arrMovieToDisplay = [];
            $objMovieModel     = new MovieModel;

            foreach ($arrRawMovies as $arrDetMovie) {
                $arrDetMovie['mov_id'] = $objMovieModel->findOrCreateApiMovie($arrDetMovie);
                $objContent = new MovieEntity('mov_');
                $objContent->hydrate($arrDetMovie);
                $arrMovieToDisplay[] = $objContent;
            }

            $this->_arrData['strSearch']        = $strSearch;
            $this->_arrData['arrError']          = $arrError;
            $this->_arrData['arrMovieToDisplay'] = $arrMovieToDisplay;

            $this->_display("list");
        }

		/**
		* @author Marco
		* Updates the movie rating and returns the new average.
		* * Receives the movie ID via GET and the user's rating via a JSON POST.
		* Inserts or updates the value in the database and returns the 
		* updated average rating of the movie in JSON format.
		* * @return void Outputs JSON and exits.
		*/
		
        public function note(){

            $objMovieModel = new MovieModel;

            header('Content-Type: application/json');
            $intNoteJson = file_get_contents("php://input");
			$data = json_decode($intNoteJson, true);

		    $insetResult = $objMovieModel->insertUpdateNote($_SESSION['user']['user_id'], $_GET['id'], $data['intNote']);


			if($insetResult){
			    echo json_encode($insetResult);
				exit;
			}   else{
  		        echo json_encode("ca marche pas");
                exit;
			}
        }


		/**
		* @author Marco & Etienne
		* Marco(Note, Insert Image, Report, Content display) & Etienne(Insert Comment, Insert / Remove Like)
        * Single movie details page
        * @return void manages ratings, likes, comments, reports, and image uploads for a specific movie
        */

        public function moviePage(){
			$arrError = [];

			$objCommentModel	= new CommentModel;
			$objMovieModel = new MovieModel;

			if (isset($_POST['deleteComment']) && isset($_SESSION['user'])) {
			    $objCommentDelete = new CommentEntity('com_');
                $objCommentDelete->setId((int)$_POST['deleteComment']);
                $objCommentDelete->setUser_id($_SESSION['user']['user_id']);

                $result = $objCommentModel->deleteComment($objCommentDelete);

                if ($result) {
                    $_SESSION['success'] = "Le commentaire à bien était supprimer !";
					$this->_selfRedirect();
                } else {
                    $arrError[] = "erreur lors de la suppression veulliez réssayer !";
                }
            }

            if(isset($_POST['deleteNoteUser'])){
                $repResult = $objMovieModel->deleteNoteUser($_SESSION['user']['user_id'], $_GET['id']);

                if ($repResult) {
                    $_SESSION['success'] = "La note à bien était supprimer !";
					$this->_selfRedirect();
                } else {
                    $arrError[] = "Erreur lors de la suppression, si vous avez un review vous devez la supprimer pour pouvoir supprimer la note !";
                }
            }



			if (isset($_POST['deleteComment']) && isset($_SESSION['user'])) {
			    $objCommentDelete = new CommentEntity('com_');
                $objCommentDelete->setId((int)$_POST['deleteComment']);
                $objCommentDelete->setUser_id($_SESSION['user']['user_id']);

                $result = $objCommentModel->deleteComment($objCommentDelete);

                if ($result) {
                    $_SESSION['success'] = "Le commentaire à bien était supprimer !";
					$this->_selfRedirect();
                } else {
                    $arrError[] = "erreur lors de la suppression veulliez réssayer !";
                }
            }

			if(isset($_POST['likeMovieBtn']) && (isset($_SESSION['user']))){

				$repResult = $objMovieModel->likeMovie($_SESSION['user']['user_id'], $_GET['id']);

				if ($repResult === 1) {
					$_SESSION['success'] = "Votre like a bien été pris en compte !";
					$this->_selfRedirect();
				} else if($repResult === 2) {
					$_SESSION['success'] = "Votre like a bien été était supprimer !";
					$this->_selfRedirect();
				}

			}

			if(isset($_POST['likeCommentBtn'])&&(isset($_SESSION['user']))){

				$repResult = $objCommentModel->LikeComment($_SESSION['user']['user_id'], $_POST['likeCommentBtn']);

				if ($repResult === 1) {
					$_SESSION['success'] = "Votre like a bien été pris en compte !";
					$this->_selfRedirect();
				} else if($repResult === 2) {
					$_SESSION['success'] = "Votre like a bien été était supprimer !";
					$this->_selfRedirect();
				}

    		}

    		if (isset($_POST['repMovie']) && isset($_SESSION['user']['user_id'])) {

				$arrData = array_merge([
                    'reported_movie_id' => $_GET['id'],
                    'reporter_user_id'  => $_SESSION['user']['user_id'],
                    'rep_reason' => $_POST['repMovie']
                ]);

				$objReport = new ReportEntity;
				$objReport->hydrate($arrData);

				if(trim($_POST['repMovie'])== ""){
					$arrError[] ="Veulliez écrire la raison de report !";
				}

				if(count($arrError) == 0){
					$repResult = $objMovieModel->reportMovie($objReport);

					if ($repResult) {
						$_SESSION['success'] = "Le signalement a bien été envoyé !";
						$this->_selfRedirect();
					}  else {
						$arrError[] = "erreur";
					}
				}

            } elseif(isset($_POST['repDelete']) && $_POST['repDelete'] == 'delete'){

                $arrData = array_merge([
                    'reported_movie_id' => $_GET['id'],
                    'reporter_user_id'  => $_SESSION['user']['user_id'],
                ]);
                $objReport = new ReportEntity;
				$objReport->hydrate($arrData);

				$repResult = $objMovieModel->deleteRepMovie($objReport);

                if ($repResult) {
                    $_SESSION['success'] = "Votre signalement a bien était supprimer ! !";
					$this->_selfRedirect();
                }  else {
                    $arrError[] = "erreur";
                }
            }

			if(isset($_FILES['images'])){
                $arrTypeAllowed	= array('image/jpeg', 'image/png', 'image/webp');
				if ($_FILES['images']['error'] != 4){
					if (!in_array($_FILES['images']['type'], $arrTypeAllowed)){
						$arrError['images'] = "Le type de fichier n'est pas autorisé";
					}else{

						switch ($_FILES['images']['error']){
							case 0 :

								$strImageName	= uniqid();

								switch ($_FILES['images']['type']){
									case 'image/jpeg' :
										$strImageName .= '.jpg';
										break;
									case 'image/png' :
										$strImageName .= '.png';
										break;
									case 'image/webp' :
										$strImageName .= '.webp';
										break;
								}

								break;
							case 1 :
								$arrError['img'] = "Le fichier est trop volumineux";
								break;
							case 2 :
								$arrError['img'] = "Le fichier est trop volumineux";
								break;
							case 3 :
								$arrError['img'] = "Le fichier a été partiellement téléchargé";
								break;
							case 6 :
								$arrError['img'] = "Le répertoire temporaire est manquant";
								break;
							default :
								$arrError['img'] = "Erreur sur l'image";
								break;
						}
					}

				}else{
					$arrError['img'] = "L'image est obligatoire";
				}

				if(count($arrError) == 0){

                    $resultInsert = $objMovieModel->addImageOfMovies($strImageName, $_GET['id'], $_SESSION['user']['user_id']);

                    if($resultInsert['success']){

                        if(!empty($resultInsert['oldImg']) && file_exists('assets/img/movie/'. $resultInsert['oldImg'])){
                            unlink('assets/img/movie/' . $resultInsert['oldImg']);
                        }

                        $strDest = 'assets/img/movie/' . $strImageName;

                        if(move_uploaded_file($_FILES['images']['tmp_name'], $strDest)){
                            $this->_resize($strDest, 400, 400, true);

                            $_SESSION['success'] = "ajoute de l'image";
							$this->_selfRedirect();
                        } else {
                            $arrError['photo'] = "Erreur lors du téléchargement";
                        }
                    }
                }
			}

			if(!empty($_POST) && isset($_POST['com_comment']) ) {

				if(isset($_SESSION['user'])) {

					if ((trim($_POST['com_comment'])== "")){
							$arrError['com_comment'] = "Vous devez remplir le champ commentaire pour laisser un avis";
					}
				
					if (empty($_POST['rating'])){
						$arrError['noteRating'] = "Vous devez notez le film pour laisser un avis";
					}	

					$arrData = [
						'comment' => $_POST['com_comment'],
						'user_id' => $_SESSION['user']['user_id'],
						'rating' => $_POST['rating'],
						'movieId' => $_GET['id']
					];

					$objComment = new CommentEntity;
					$objComment->hydrate($arrData);

					if(count($arrError)===0) {

						$comment = $objCommentModel->commentInsert($objComment);

						if(!$comment){
							$arrError[] 	= "Echec de l'ajout du commentaire !";
						} elseif(isset($comment['error'])){
							$arrError[] 	= $comment['error'];
						}else{
							$_SESSION['success'] 	= "Votre commentaire à bien etait publié";
							$this->_selfRedirect();
						}
					}
					$this->_arrData['strComment'] = $objComment->getComment();

				} else{
					$arrError[] ="Vous devez être connecté pour pouvoir commenter !";
				}
			}

			if(isset($_POST['spoiler']) && $_SESSION['user']['user_funct_id'] != 1){

			    if($objCommentModel->addSpoiler($_POST['spoiler'])){
					$_SESSION['success'] = "Spoiler mis à jour !";
					$this->_selfRedirect();
				}
				
			}

			if (isset($_POST['commentReport']) && $_POST['commentReport'] != '' && isset($_SESSION['user']['user_id'])) {
                $objReport = new ReportEntity;
                $objReport->setReason($_POST['commentReport']);
                $objReport->setReported_com_id($_POST['commentReportId']);

                $repResult = $objCommentModel->reportComment($objReport, $_SESSION['user']['user_id']);

                if ($repResult) {
                    $_SESSION['success'] = "Le signalement a bien été envoyé !";
					$this->_selfRedirect();
                }  else {
                    $arrError[] = "erreur";
                }
            }   elseif(isset($_POST['repComDelete']) && $_POST['repComDelete'] != ''){

                    $objReport = new ReportEntity;
    				$objReport->setReported_com_id($_POST['repComDelete']);

    				$repResult = $objCommentModel->deleteRepCom($objReport, $_SESSION['user']['user_id']);

                    if ($repResult) {
                        $_SESSION['success'] = "Votre signalement a bien était supprimer ! !";
						$this->_selfRedirect();
                    }  else {
                        $arrError[] = "erreur";
                    }
            }

            $objMovieModel 	= new MovieModel;
            $objRapidModel 	= new RapidMovieModel;

            // Filet de sécurité : ID non-numérique = identifiant API externe
            // (normalement les cartes pointent déjà vers l'ID local entier)
            if (!is_numeric($_GET['id'] ?? '')) {
                // Cherche si déjà enregistré localement
                $existing = $objMovieModel->findMovieByApiId($_GET['id']);
                if ($existing) {
                    $this->_redirect("movie/moviePage/" . $existing['mov_id']);
                    return;
                }
                // Sinon tente de récupérer via API et enregistre
                $arrApiData = $objRapidModel->getMovieById($_GET['id']);
                if ($arrApiData) {
                    $intLocalId = $objMovieModel->findOrCreateApiMovie($arrApiData);
                    $this->_redirect("movie/moviePage/" . $intLocalId);
                } else {
                    $this->_redirect("error/err404");
                }
                return;
            }

			$arrMovie = $objMovieModel->findMovie((int)$_GET['id'], $_SESSION['user']['user_id']??0);
            $arrMovieImages = $arrMovie ? $objMovieModel->selectImageMovie($_GET['id']) : [];

			if(!$arrMovie){
				$this->_redirect("error/err404");
			}

			$arrImagesToDisplay = array();

			foreach($arrMovieImages as $arrDetImage){
				$objMovie = new MovieEntity('mov_');
				$objMovie->hydrate($arrDetImage);

				$arrImagesToDisplay[]	= $objMovie;
			}

			$objMovie  = new MovieEntity('mov_');
			$objMovie->hydrate($arrMovie);


			$objPersonModel = new PersonModel;
			$arrPerson      = $objPersonModel->findAllPerson($_GET['id']);


			$arrPersToDisplay = array();

			foreach($arrPerson as $arrDetPerson){
				$objPerson = new PersonEntity('pers_');
				$objPerson->hydrate($arrDetPerson);

				$arrPersToDisplay[]	= $objPerson;
			}

			$arrComment = $objCommentModel->commentOfMovie($_GET['id'],$_SESSION['user']['user_id']??0);

			$arrCommentToDisplay = array();

			foreach($arrComment as $arrDetComment){
				$objComment = new CommentEntity('com_');
				$objComment->hydrate($arrDetComment);

				$arrCommentToDisplay[]	= $objComment;
			}

			

			// Données riches de l'API (genres, streaming, cast, réalisateurs…)
			$arrApiData      = null;
			$strDirectors    = '';
			$strCast         = '';
			if (!empty($arrMovie['mov_api_data'])) {
				$arrApiData   = json_decode($arrMovie['mov_api_data'], true);
				$strDirectors = join(', ', $arrApiData['directors'] ?? []);
				$strCast      = join(', ', array_slice($arrApiData['cast'] ?? [], 0, 8));

				// La colonne pho_photo (VARCHAR 255) tronque les URLs CDN signées.
				// On écrase la photo directement depuis le JSON, qui lui est stocké en MEDIUMTEXT.
				$strApiPhoto = $arrApiData['imageSet']['verticalPoster']['w480']
							?? $arrApiData['imageSet']['verticalPoster']['w240']
							?? '';
				if ($strApiPhoto !== '') {
					$objMovie->setPhoto($strApiPhoto);
				}
			}

			$this->_arrData['arrError'] = $arrError;
			$this->_arrData['arrCommentToDisplay'] = $arrCommentToDisplay;
			$this->_arrData['arrPersToDisplay'] = $arrPersToDisplay;
			$this->_arrData['arrImagesToDisplay'] = $arrImagesToDisplay;
			$this->_arrData['objMovie'] = $objMovie;
			$this->_arrData['arrApiData'] = $arrApiData;
			$this->_arrData['strDirectors'] = $strDirectors;
			$this->_arrData['strCast'] = $strCast;

            $this->_display("movie");
        }

		/**
		* @author Audrey
        * Adding a new movie to the catalog
        * @return void handles form validation, file upload, and database insertion
        */

        public function addEditMovie(){
			
			// 1. Object and variable initialization
			$objMovie = new MovieEntity('mov_');
			$objMovieModel = new MovieModel();

			if (isset($_GET['id'])){
				$this->_checkAccess(2);
				$arrMovie= [];
				$arrMovie = $objMovieModel->findOneMovie($_GET['id']);
				$objMovie->hydrate($arrMovie);
			}

			$arrError = [];
			// 2. Data validation
			if (count($_POST)>0){
				$objMovie->hydrate($_POST);

				if (empty($objMovie->getTitle())) {
					$arrError['title'] = "Le titre est obligatoire.";
				}
				if (strlen($objMovie->getTitle()) >  100) {
					$arrError['title'] = "Le titre ne doit pas dépasser 100 caractères.";
				}
				if (strlen($objMovie->getOriginalTitle()) > 100) {
					$arrError['original_title'] = "Le titre original ne doit pas dépasser 100 caractères.";
				}
				if ($objMovie->getCategoriesId() == 0) {
					$arrError['categoriesId'] = "Le genre est obligatoire.";
				}
				if ($objMovie->getCountryId() == 0) {
					$arrError['countryId'] = "Le pays d'origine est obligatoire.";
				}
				if ($objMovie->getRelease_date() == '') {
					$arrError['release_date'] = "La date de sortie est obligatoire.";
				}
				if (empty($objMovie->getLength())) {
					$arrError['length'] = "La durée est obligatoire.";
				}
				if (empty($objMovie->getDescription())) {
					$arrError['description'] = "Le synopsis est obligatoire.";
				}
				if (empty($objMovie->getTrailer())) {
					$arrError['trailer_url'] = "Le lien de la bande-annonce est obligatoire.";
				}

				$arrTypeAllowed	= array('image/jpeg', 'image/png', 'image/webp');
				if ($_FILES['photo']['error'] != 4){

					if (!in_array($_FILES['photo']['type'], $arrTypeAllowed)){
					$arrError['photo'] = "Le type de fichier n'est pas autorisé";
					}else{
						switch ($_FILES['photo']['error']){
							case 0 :
								$strImageName	= uniqid().".webp";
							//Getting the original image name
								$strOldImg	= $objMovie->getPhoto();

								$objMovie->setPhoto($strImageName);
								break;

							case 1 :
								$arrError['photo'] = "Le fichier est trop volumineux";
								break;
							case 2 :
								$arrError['photo'] = "Le fichier est trop volumineux";
								break;
							case 3 :
								$arrError['photo'] = "Le fichier a été partiellement téléchargé";
								break;
							case 6 :
								$arrError['photo'] = "Le répertoire temporaire est manquant";
								break;
							default :
								$arrError['photo'] = "Erreur sur l'image";
								break;
						}
				}
			}elseif(!isset($_GET['id'])){

				// Check if the file exists
				if (is_null($objMovie->getPhoto())){
					$arrError['img'] = "L'image est obligatoire";
				}
			}
			
			// If the form is correctly completed
			if (count($arrError) == 0){

				if (!isset($_GET['id'])){
					$boolResultMovie = $objMovieModel->addMovie($objMovie);
				}else{
					$boolResultMovie = $objMovieModel->updateMovie($objMovie);
				}
				// If no errors, attempting the insertion
				if ($boolResultMovie === true) {
					if (isset($strImageName)){
						
						$strDest = 'assets/img/movie/' . $strImageName;
						
						
						if (move_uploaded_file($_FILES['photo']['tmp_name'], $strDest)) {
							if (!empty($strOldImg)) {
								$strOldFile = 'assets/img/movie/'.$strOldImg;
								if (file_exists($strOldFile)) {
								 	unlink($strOldFile);
								}
								
							}
							$this->_resize($strDest,280, 400);
						}
					}

						if (is_null($objMovie->getId())){
							$_SESSION['success'] 	= "La demande du film a été enregistrer";
							$this->_selfRedirect();
						}else{
							$_SESSION['success'] 	= "Le film a bien été modifié";
							$this->_redirect("movie/allMovie");
						}
					}else{
						$arrError['img'] = "Erreur dans le traitement de l'image";
					}
					
				}
			}
			
			$arrCategory = $objMovieModel->allCategories();
				$arrCatToDisplay	= array();

			$arrCatToDisplay = array();
			foreach($arrCategory as $arrDetCat){
				$objContent = new MovieEntity('mov_');
				$objContent->hydrate($arrDetCat);

				$arrCatToDisplay[]	= $objContent;
			}
			
			$arrNationality = $objMovieModel->allCountry();
			$arrNatToDisplay	= array();

			$arrNatToDisplay = array();
			foreach($arrNationality as $arrDetNat){
				$objNat = new MovieEntity('mov_');
				$objNat->hydrate($arrDetNat);

				$arrNatToDisplay[]	= $objNat;
			}

			$this->_arrData['objMovie']		   = $objMovie;
			$this->_arrData['arrError']		   = $arrError;
			$this->_arrData['arrCatToDisplay'] = $arrCatToDisplay;
			$this->_arrData['arrNatToDisplay'] = $arrNatToDisplay;

            $this->_display("addEditMovie");
        }

		/**
		* @author Audrey
        * Deleting a movie from the database
        * @return void redirects to the dashboard with a success message upon deletion
        */

		public function deleteMovie() {
			//Permission control
			$this->_checkAccess(2);

            $objMovieModel = new MovieModel();
            $success = $objMovieModel->deleteMovie($_GET['id']);

            if($success){

                $_SESSION['success'] = "Le film a bien été supprimé";
                $this->_redirect("movie/allMovie");

            }

		}

		/**
		* @author Marco
        * Updating a movie from the database
        * @return void redirects to the dashboard with a success message upon deletion
        */

		public function publishMovie(){
			$this->_checkAccess(2);
							
			$objMovieModel = new MovieModel();
            $success = $objMovieModel->publishMovie($_GET['id']);

            if($success){

                $_SESSION['success'] = "Le film a bien été publié";
                $this->_redirect("movie/allMovie");

            }
		}

		/**
		* @author Marco
        * Management page for all movies
        * @return void retrieves all movies from the database and displays the administration list
        */

		public function allMovie(){
			
			$search = $_GET['search'] ?? NULL;
            $filter = $_GET['filter'] ?? '0';
			$sort   = $_GET['sort'] ?? 'ASC';
			
			// Check if user is authenticated and has correct permission
			$this->_checkAccess(2);
			
			// Initialize model and fetch movies based on filters
			$objMovieModel 	= new MovieModel;
			$arrMovie   	= $objMovieModel->findMovieWithFilters($search, $filter,$sort);
			$arrNotPublished  	= $objMovieModel->movieNotPublished();

			
			$arrMovieToDisplay	= array();

			// Converting the multidimensional array into an object array for the list of Movie
			foreach($arrMovie as $arrDetMovie){
				$objMovie = new MovieEntity("mov_");
				$objMovie->hydrate($arrDetMovie);

				$arrMovieToDisplay[]= $objMovie;
			}

			$arrMovieNotPublishedToDisplay	= array();

			// Converting the multidimensional array into an object array for the list of Movie
			foreach($arrNotPublished as $arrDetMovie){
				$objMovieToPublish = new MovieEntity("mov_");
				$objMovieToPublish->hydrate($arrDetMovie);

				$arrMovieNotPublishedToDisplay[]= $objMovieToPublish;
			}

			// Loading categories for the select input
			$arrCategory 		= $objMovieModel->allCategories();
			$arrCatToDisplay	= array();

			foreach($arrCategory as $arrDetCat){
				$objContent = new MovieEntity('mov_');
				$objContent->hydrate($arrDetCat);

				$arrCatToDisplay[]	= $objContent;
			}

			$this->_arrData['arrMovieNotPublishedToDisplay']	= $arrMovieNotPublishedToDisplay;
			$this->_arrData['arrMovieToDisplay']	= $arrMovieToDisplay;
			$this->_arrData['arrCatToDisplay']	    = $arrCatToDisplay;
            $this->_arrData['search']               = $search;
            $this->_arrData['filter']               = $filter;
			$this->_arrData['sort']                 = $sort;

			$this->_display("allMovie");
		}

		/** @brief Generates and forces the download of an ICS calendar event for a movie release.
		 * * @details This method constructs a file in iCalendar (.ics) format to allow 
		 * the user to add a movie's release date to their personal calendar.
		 * * The process follows these steps:
		 * -# Clears the output buffer to prevent file corruption.
		 * -# Retrieves the movie ID and user context.
		 * -# Fetches movie details from the database with a redirect on failure.
		 * -# Configures event timing (defaults to 20:00, 2-hour duration).
		 * -# Sanitizes and formats text data according to the iCalendar standard.
		 * -# Constructs the VEVENT structure with a unique UID.
		 * -# Sends HTTP headers to force file download.
		 * * @author Etienne
		 * @param int $id Movie identifier (retrieved via request context).
		 * @return void Streams the file directly to the browser and terminates the script.
		 */
		
		public function addToCalendar() {
			if (ob_get_level()) ob_end_clean();

			$intId      = (int)($_GET['id'] ?? 0);
			$intUser    = $_SESSION['user']['user_id'] ?? 0;

			$objMovieModel  = new MovieModel();
			$arrMovie       = $objMovieModel->findMovie($intId, $intUser); 

			if($arrMovie === false){

				$this->_redirect(); 
				exit;
			}

			$strDateDb = $arrMovie['mov_release_date'] ?? date('Y-m-d');

			try {
	
				$dateStart = new DateTime($strDateDb .' 20:00:00');
			} catch (Exception $e) {
				$dateStart = new DateTime('now');
			}

			$dateEnd = clone $dateStart;
			$dateEnd->modify('+2 hours');

			$title          = $this->_escapeIcs($arrMovie['mov_title']);
			$descText       = $arrMovie['mov_synopsis'] ?? "Sortie du film " . $title;
			

			$description    = $this->_escapeIcs(substr($descText, 0, 200). "..."); 

			$icsContent  = "BEGIN:VCALENDAR\r\n";
			$icsContent .= "VERSION:2.0\r\n";
			$icsContent .= "PRODID:-//GiveMeFive//Movie Release//FR\r\n";
			$icsContent .= "BEGIN:VEVENT\r\n";
			$icsContent .= "UID:" . md5($intId . "movie") . "@givemefive.fr\r\n";
			$icsContent .= "DTSTAMP:" . date('Ymd\THis') . "\r\n"; 
			$icsContent .= "DTSTART:" . $dateStart->format('Ymd\THis') . "\r\n";
			$icsContent .= "DTEND:" . $dateEnd->format('Ymd\THis') . "\r\n";
			$icsContent .= "SUMMARY:" . $title . "\r\n";
			$icsContent .= "DESCRIPTION:" . $description . "\r\n";
			$icsContent .= "END:VEVENT\r\n";
			$icsContent .= "END:VCALENDAR\r\n";

			$filename = "sortie_" . preg_replace('/[^a-z0-9]/i', '_', $title) . ".ics";
			
			header('Content-Type: text/calendar; charset=utf-8');
			header('Content-Disposition: attachment; filename="' . $filename . '"');
			
			echo $icsContent;
			exit;
		}

		/* * @brief Escapes special characters according to the iCalendar (RFC 5545) format.
		* * @details This helper method ensures that the input string is compliant with ICS 
		* requirements by sanitizing delimiters and line breaks that could otherwise 
		* corrupt the calendar file structure.
		* * The sanitization process involves:
		* -# Replacing various newline characters (LF, CR, CRLF) with the literal string "\\n".
		* -# Escaping reserved characters: commas (,), semicolons (;), and backslashes (\\).
		* -# Returning the sanitized string safe for VEVENT properties.
		* * @author Etienne
		* @param string $str The raw string to be escaped.
		* @return string The sanitized string safe for ICS files.
		*/


		private function _escapeIcs($string) {
			$string = str_replace(["\r\n", "\r", "\n"], "\\n", $string);
			return addcslashes($string, ",;\\");
		}
    }

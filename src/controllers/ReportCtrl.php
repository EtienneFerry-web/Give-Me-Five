<?php
    namespace App\Controllers;

    //Entities
    use App\Entities\ReportEntity;
    use App\Entities\CommentEntity;
    //models
    use App\Models\ReportModel;
    use App\Models\CommentModel;
    use App\Models\UserModel;

    /**
     * @author Marco Schmitt
     * 27/02/2026
     * Version 1
     */

    class ReportCtrl extends MotherCtrl{

        /**
         * Management page for all user, comment, and movie reports
         * @return void handles moderation actions like spoilers, deletions, and bans, then displays all active reports
         */

        public function allReport(){
            
            $this->_checkAccess(2);

            $objCommentModel = new CommentModel;
            $objReportModel = new ReportModel;
            $objUserModel = new UserModel;
            $objComment = new CommentEntity;
            $objReport = new ReportEntity;

			//Add spoiler on comment
			if(isset($_POST['addRemoveSpoiler'])){

			    if($objCommentModel->addSpoiler($_POST['addRemoveSpoiler'])){
					$_SESSION['success'] = "Spoiler à était mis a jours !";
                    $this->_selfRedirect();
				}
			}

			if(isset($_POST['id']) && isset($_POST['reason']) && $_SESSION['user']['user_funct_id'] == 3){
			    $objReport->hydrate($_POST);
			    $boolResult = $objUserModel->banUser($objReport);

				if($boolResult){
				    $_SESSION['success'] = "L'utilisateur à était Bannie !";
                    $this->_selfRedirect();
				} else{
				    $arrError[] = "Erreur lors du banissement";
				}
			}

			if (isset($_POST['deleteComment'])) {

                $objComment->setId((int)$_POST['deleteComment']);
                $objComment->setUser_id($_SESSION['user']['user_id']);

                $result = $objCommentModel->deleteComment($objComment);

                if ($result) {
                    $_SESSION['success'] = "Le commentaire à bien était supprimer !";
                    $this->_selfRedirect();
                } else {
                    $arrError[] = "erreur lors de la suppression veulliez réssayer !";
                }
            }

            if(isset($_POST['unBanUser']) && $_SESSION['user']['user_funct_id'] == 3){
                $boolResult = $objUserModel->unBanUser($_POST['unBanUser']);

                if($boolResult){
                    $_SESSION['success'] = "L'utilisateur a était banni !";
                    $this->_selfRedirect();
                } else{
                    $arrError[] = "erreur lors de la tentative de suppression !";
                }
            }

            if (isset($_POST['deleteRep'])){

                $boolResult = $objReportModel->validateReport($_POST['deleteRep']);

                if($boolResult){
                    $_SESSION['success'] = "Le reports à bien était supprimer !";
                    $this->_selfRedirect();
                } else{
                    $arrError[] = "erreur lors de la tentative de suppression !";
                }
            }

            $objReportModel = new ReportModel;

            $arrUserRep     = $objReportModel->allUserReport();
            $arrComRep      = $objReportModel->allCommentReport();
            $arrMovieRep    = $objReportModel->allMovieReport();

            $arrRepUserToDisplay	= array();

 			foreach($arrUserRep as $arrDeReport){
				$objContent = new ReportEntity;
				$objContent->hydrate($arrDeReport);

				$arrRepUserToDisplay[]	= $objContent;
 			}

            $arrRepComToDisplay	= array();

 			foreach($arrComRep as $arrDeReport){
				$objContent = new ReportEntity;
				$objContent->hydrate($arrDeReport);

				$arrRepComToDisplay[]	= $objContent;
      		}

            $arrRepMovieToDisplay	= array();

 			foreach($arrMovieRep as $arrDeReport){
				$objContent = new ReportEntity;
				$objContent->hydrate($arrDeReport);

				$arrRepMovieToDisplay[]	= $objContent;
       	    }

            $this->_arrData['arrRepMovieToDisplay'] = $arrRepMovieToDisplay;
            $this->_arrData['arrRepComToDisplay'] = $arrRepComToDisplay;
            $this->_arrData['arrRepUserToDisplay'] = $arrRepUserToDisplay;

            $this->_display("allReport");
        }

    }

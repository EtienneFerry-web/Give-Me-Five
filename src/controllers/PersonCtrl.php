<?php
    namespace App\Controllers;

    //Entities
    use App\Entities\MovieEntity;
    use App\Entities\PersonEntity;
    //Models
    use App\Models\MovieModel;
    use App\Models\PersonModel;



    /**
     * @author Marco Schmitt
     * 27/02/2026
     * Version 1
     */

    class PersonCtrl extends MotherCtrl{

        /**
        * @author Marco
        * Single person details page
        * @return void retrieves personal info, associated jobs, and the movie filmography for a specific person
        */

        public function personPage(){

            $objMovieModel 	    = new MovieModel;

            $objMovieModel->order = $_POST['order']??"";
            $objMovieModel->job   = $_POST['job']??"";

            $objPersonModel = new PersonModel;
			$arrPerson 		= $objPersonModel->findPerson($_GET['id']);
			$arrJobs        = $objPersonModel->findJobsOfPerson($_GET['id']);


			$arrJobToDisplay	= array();

			foreach($arrJobs as $arrDetJob){
                $objContent = new PersonEntity;
                $objContent->hydrate($arrDetJob);

                $arrJobToDisplay[]	= $objContent;
            }

			$objPerson = new PersonEntity('pers_');
			$objPerson->hydrate($arrPerson);
            
            $arrMovie		    = $objMovieModel->movieOfPerson($_GET['id']);

            $arrMovieToDisplay	= array();

            foreach($arrMovie as $arrDetMovie){
            $objContent = new MovieEntity('mov_');
            $objContent->hydrate($arrDetMovie);

            $arrMovieToDisplay[]	= $objContent;
            }

            $this->_arrData['arrMovieToDisplay']    = $arrMovieToDisplay;
            $this->_arrData['arrJobToDisplay']      = $arrJobToDisplay;
            $this->_arrData['objPerson']            = $objPerson;

            $this->_arrData['order'] = $objMovieModel->order;
            $this->_arrData['job']   = $objMovieModel->job;


            $this->_display("person");
        }

        /**
        * @author Audrey Sonntag
        * 06/02/2026
        * Version 0.1
        * Deleting a person from the database
        * @return void redirects to the admin dashboard with a success message upon deletion
        */

        public function deletePerson() {

            $this->_checkAccess(2);

            $objPersonModel = new PersonModel();
            $success = $objPersonModel->deletePerson($_GET['id']);

            
            if($success){
                $_SESSION['success'] = "La célébrité a bien été supprimée";
                $this->_redirect("admin/dashboard");
            }
		}


        /**
        * @author Audrey Sonntag
        * 06/02/2026
        * Version 0.1
        * Updating person details and profile picture
        * @return void validates form data, handles image upload, and updates the person in the database
        */

        public function settingsPerson() {
            $this->_checkAccess(2);

            $objPersonModel = new PersonModel();
            
            $objPerson = new PersonEntity();
            

            $arrPerson      = $objPersonModel->findPerson($_GET['id']);
            $arrCountry     = $objPersonModel->allCountry();


            $arrCountryToDisplay    = array();

            foreach($arrCountry as $arrDetCountry){
                $objPerson = new PersonEntity('pers_');
                $objPerson->hydrate($arrDetCountry);

                $arrCountryToDisplay[]  = $objPerson;
            }
            
			$objPerson->hydrate($arrPerson);

            $arrError = [];
            if (count($_POST) > 0) {
                $objPerson->hydrate($_POST);
                
                if ($objPerson->getName() == ""){
                    $arrError['name'] = "Le nom est obligatoire";
                }
                if (strlen($objPerson->getName()) > 50){
                    $arrError['name'] = "Le nom ne doit pas dépasser 255 caractères";
                }
                if ($objPerson->getFirstname() == ""){
                    $arrError['firstname'] = "Le prénom est obligatoire";
                }
                if (strlen($objPerson->getFirstname()) > 50){
                    $arrError['firstname'] = "Le prénom ne doit pas dépasser 50 caractères";
                }
                if ($objPerson->getBirthdate() == ""){
                    $arrError['birthdate'] = "La date de naissance est obligatoire";
                }
                if ($objPerson->getCountry() == ""){
                    $arrError['country'] = "La nationalité est obligatoire";
                }
                if ($objPerson->getBio() == ""){
                    $arrError['bio'] = "La biographie est obligatoire";
                }
                if (strlen($objPerson->getBio()) > 255){
                    $arrError['bio'] = "La biographie ne doit pas dépasser 255 caractères";
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
							$strOldImg	= $objPerson->getPhoto();

							$objPerson->setPhoto($strImageName);
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
				
				

			// 3. Data insertion logic

			}elseif(!isset($_GET['id'])){

				// Check if the file exists
				if (is_null($objPerson->getPhoto())){
					$arrError['img'] = "L'image est obligatoire";
				}
			}

                if (count($arrError) == 0){
                    $objPerson->setId($_GET['id']);

                    if(isset($strImageName)){
                        $strDest = 'assets/img/person/' . $strImageName;
    
                        if(move_uploaded_file($_FILES['photo']['tmp_name'], $strDest)){
                            $objPerson->setPhoto($strImageName);
                            $this->_resize($strDest,280, 350);
                            $strOldFile = 'assets/img/person/'.$strOldImg;
                            if (file_exists($strOldFile)) {
                                unlink($strOldFile);
                            }
                        } else {
                            $arrError['photo'] = "Erreur lors du téléchargement";
                        }
                    }
					$boolUpdate 	= $objPersonModel->updatePerson($objPerson);

                    if($boolUpdate){
                        $_SESSION['success'] = "Vos modification on bien était enregistré";
                        $this->_redirect("person/allPerson");
                    } else{
                        $arrError[] = "Erreur Lors de la modification veuillez réassayer";
                    }
                }

            }

            

            $this->_arrData['objPerson']            = $objPerson;
            $this->_arrData['arrCountryToDisplay']  = $arrCountryToDisplay;
            $this->_arrData['arrError']             = $arrError;
            $this->_display("settingsPerson");


        }

        /**
        * @author Audrey Sonntag 
        * Management page for all celebrities
        * @return void retrieves a list of all persons from the database and displays the admin list
        */

        public function allPerson(){

            $search = $_GET['search'] ?? NULL;
            $filter = $_GET['filter'] ?? 'all';
            $sort   = $_GET['sort'] ?? 'ASC';

			$objPersonModel 	= new PersonModel;
			$arrPerson   	= $objPersonModel->findPersonWithFilters($search, $filter, $sort);


			$arrPersonToDisplay	= array();

			foreach($arrPerson as $arrDetPerson){

				$objPerson = new PersonEntity();
				$objPerson->hydrate($arrDetPerson);

				$arrPersonToDisplay[]	= $objPerson;
			}

			$this->_arrData['arrPersonToDisplay']	= $arrPersonToDisplay;
            $this->_arrData['search']               = $search;
            $this->_arrData['filter']               = $filter;
            $this->_arrData['sort']                 = $sort;

			$this->_display("allPerson");
		}
    }

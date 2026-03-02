<?php
    namespace App\Controllers;
    //Entities
    use App\Entities\MovieEntity;
    use App\Entities\CommentEntity;
    use App\Entities\ReportEntity;
    use App\Entities\UserEntity;
    //models
    use App\Models\ReportModel;
    use App\Models\MovieModel;
    use App\Models\CommentModel;
    use App\Models\UserModel;

    use DateTime;

    class UserCtrl extends MotherCtrl{

        /**
         * @brief Monitors and manages user session expiration based on activity.
         * * @details This security method implements a sliding session window:
         * 1. **Time Comparison:** Initializes the current timestamp to compare against the stored session expiration.
         * 2. **Session Extension:** If the current time is before the 'last_activity' deadline, the session 
         * is considered active, and the expiration is extended by an additional 30 minutes.
         * 3. **Expiration Handling:** If the deadline has passed:
         * - Sets 'last_activity' to a flag value (0).
         * - Outputs a 'logout' signal (typically for AJAX/Frontend handling).
         * - Terminates execution immediately to prevent unauthorized data access.
         * * @author Marco
         * @return void
         */

        public function userActivity(){


            $time = new DateTime;

            if($_SESSION['last_activity'] > $time){
                $_SESSION['last_activity']    = new DateTime('+30 minutes');
            } else{
                $_SESSION['last_activity'] = 0;
                echo('logout');
                exit;
            }

        }

        /**
         * @brief Handles user authentication and login security.
         * * @details This method manages the secure login process, including brute-force protection:
         * 1. **Data Acquisition:** Retrieves the email, password, and client IP address.
         * 2. **Brute-Force Mitigation:** Checks the database for failed attempts from the current IP. 
         * Blocks access for 15 minutes if the threshold (5 attempts) is reached.
         * 3. **Input Validation:** Ensures both email and password fields are populated.
         * 4. **Credential Verification:** Checks credentials against the database.
         * - **If invalid:** Increments failure counters, logs the attempt, and enforces a 5-minute 
         * session restriction after 3 consecutive failures.
         * - **If valid:** Clears existing failure records, initializes the user session, 
         * sets a 30-minute activity timeout, and logs a successful 'LOGIN' event.
         * 5. **View Preparation:** Passes errors and user data back to the login template if redirection doesn't occur.
         * * @author Etienne
         * @return void
         */

        public function login(){

            $strEmail       = $_POST['email']??"";
            $strPwd         = $_POST['pwd']??"";
            $ipAddress      = $_SERVER['REMOTE_ADDR'];


            $objUser            = new UserEntity;
            $objUserModel       = new UserModel;
            $objUser->hydrate($_POST);

            $arrError = [];

            $failedAttempts = $objUserModel->getFailedAttempts($ipAddress);


            if($failedAttempts >= 5) {
                $arrError[] = "Trop de tentatives de connexion échoues. Par sécurité votre accès est bloqué pour 15 minutes";
            } else {
                if (count($_POST) > 0) {

                    if ($strEmail == ""){
                        $arrError['email'] = "Le mail est obligatoire";
                    }
                    if ($strPwd == ""){
                        $arrError['pwd'] = "Le mot de passe est obligatoire";
                    }

                    if (count($arrError) == 0 ){
                        $arrResult = $objUserModel->verifUser($strEmail, $strPwd);
                        if ($arrResult === false){
                                $arrError[] = "Mail ou mot de passe invalide";

                                $objUserModel->addFailedAttempts($ipAddress);

                                $_SESSION['pwdError']['nbr'] += 1;

                                if($_SESSION['pwdError']['nbr'] > 3){    
                                $_SESSION['pwdError']['restrict'] = new DateTime('+5 minutes');
                                }
                            }else{

                                $objUserModel->clearLoginAttempts($ipAddress);

                                $_SESSION['user']       = $arrResult;
                                $_SESSION['success']    = "Bienvenue, vous êtes bien connecté";
                                $_SESSION['last_activity']    = new DateTime('+30 minutes');

                                $arrData = array (
                                    'userId'  => $_SESSION['user']['user_id'],
                                    'event'   => 'LOGIN',
                                    'ip'      => $_SERVER['REMOTE_ADDR'],
                                    'agent'   => $_SERVER['HTTP_USER_AGENT'] ?? 'Inconnu'
                                );

                                $objUserModel->addLogs($arrData);
                                $this->_redirect();
                        }
                    }
                }
            }
            $this->_arrData['objUser'] = $objUser;
            $this->_arrData['arrError'] = $arrError;
            $this->_arrData['strEmail'] = $strEmail;

            $this->_display("login");
        }

        /**
         * @brief Terminates the current user session and logs the event.
         * * @details This method performs the following security and session cleanup steps:
         * 1. **Audit Logging:** Records the logout event in the database, including user ID, IP address, and User Agent.
         * 2. **Inactivity Check:** Determines if the logout was triggered by session timeout (last_activity == 0).
         * 3. **Session Cleanup:** Removes user-specific data and activity timestamps from the $_SESSION superglobal.
         * 4. **Feedback & Redirection:** * - If timed out: Sets an inactivity message and redirects to the login page.
         * - If manual: Sets a success message and redirects to the homepage.
         * * @author Marco & Etienne
         * @return void
         */

        public function logout(){

            $objUserModel       = new UserModel;

            $arrData = array (
                'userId'  => $_SESSION['user']['user_id'],
                'event'   => 'LOGOUT',
                'ip'      => $_SERVER['REMOTE_ADDR'],
                'agent'   => $_SERVER['HTTP_USER_AGENT'] ?? 'Inconnu'
            );

            $objUserModel->addLogs($arrData);

            if($_SESSION['last_activity'] == 0){
                $_SESSION['success']  = "Vous avez êtes déconnecté pour inactivité !";
                unset($_SESSION['user']);
                unset($_SESSION['last_activity']);
                $this->_redirect("user/login");
               
            } else {
                $_SESSION['success']  = "Vous êtes bien déconnecté";
                unset($_SESSION['user']);
                unset($_SESSION['last_activity']);
                $this->_redirect();
            }

        }

        /**
         * @brief Handles the user registration process.
         * * @details This method manages the end-to-end account creation flow:
         * 1. **Data Collection:** Collects raw input from the registration form and hydrates a UserEntity.
         * 2. **Field Validation:** Performs mandatory checks on name, firstname, pseudo, and email format.
         * 3. **Age Verification:** Validates the birthdate to ensure the user meets the minimum age requirement (8 years old).
         * 4. **Security Validation:** Delegates password strength and confirmation checks to the internal _verifPwd method.
         * 5. **Persistence & Conflict Check:** Attempts to insert the new user into the database. If the insertion fails due to 
         * duplicate unique keys (email or pseudo), it adds specific error messages.
         * 6. **Finalization:** Redirects to the login page on success or re-renders the form with error feedback.
         * * @author Etienne
         * @return void
         */

        public function createAccount(){

            $strName        = $_POST['name']??"";
            $strFirstname   = $_POST['firstname']??"";
            $strPseudo      = $_POST['pseudo']??"";
            $strBirthdate   = $_POST['birthdate']??"";
            $strEmail       = $_POST['email']??"";
            $strPwd         = $_POST['pwd']??"";
            $strPwdConfirm  = $_POST['pwd_confirm']??"";
     
            $objUser    = new UserEntity;
            $objUser->hydrate($_POST);

            $arrError = [];
            var_dump($_SESSION);
            if (count($_POST) > 0) {
                
                $birthdate = $objUser->getBirthdate();
                var_dump($birthdate);

                if ($objUser->getName() == ""){
                    $arrError['name'] = "Le nom est obligatoire";
                }
                if ($objUser->getFirstname() == ""){
                    $arrError['firstname'] = "Le prénom est obligatoire";
                }
                if ($objUser->getPseudo() == ""){
                    $arrError['pseudo'] = "Le pseudo est obligatoire";
                }
                if ($birthdate == ""){
                    $arrError['birthdate'] = "La date de naissance est obligatoire.";
                } else {

                    $limitDate = date("Y-m-d", strtotime("-8 years"));
                    
                    if ($objUser->getBirthdate() > $limitDate) {
                        $arrError['birthdate'] = "Vous devez avoir plus de 8 ans.";
                    }

                }
                if ($objUser->getEmail() == ""){
                    $arrError['email'] = "Le mail est obligatoire";
                }else if (!filter_var($objUser->getEmail(), FILTER_VALIDATE_EMAIL)){
                    $arrError['email'] = "Le format du mail n'est pas correct";
                }
                //use verifypwd for regex
                $pwdErrors = $this->_verifPwd($objUser, $strPwdConfirm);
                $arrError = array_merge($arrError, $pwdErrors);
                
                if (count($arrError) == 0){
            
                    $objUserModel   = new UserModel;
                    $boolInsert     = $objUserModel->insert($objUser);

                    if($boolInsert != true && $boolInsert['user_email'] == $objUser->getEmail()){
                        $arrError[] = "Adresse mail ou Mots de passe Invalide !";
                    }
                    if($boolInsert != true  && $boolInsert['user_pseudo'] == $objUser->getPseudo()){
                       $arrError[] = "Ce pseudonyme est déja utilisé !";
                    }

                    if ($boolInsert != false && count($arrError) == 0){

                            $_SESSION['success']    = "Le compte compte a bien été crée";
                            $this->_redirect("user/login");

                    }else{
                        $arrError[] = '';
                    }
                }
            }
            
            $this->_arrData['name']         = $strName;
            $this->_arrData['firstname']    = $strFirstname;
            $this->_arrData['pseudo']       = $strPseudo;
            $this->_arrData['birthdate']    = $strBirthdate;
            $this->_arrData['strEmail']     = $strEmail;
            $this->_arrData['arrError']     = $arrError;
            $this->_arrData['objUser']      = $objUser;

            $this->_display("createAccount");
        }

        /**
         * @brief Validates the basic user profile information.
         * * @details This internal validation method checks for the presence and format of mandatory fields:
         * 1. **Initialization:** Prepares an empty array to collect validation errors.
         * 2. **Required Fields:** Verifies that 'name', 'firstname', and 'pseudo' are not empty.
         * 3. **Email Validation:** Checks if the email is provided and ensures it follows a valid standard format.
         * 4. **Output:** Returns an associative array containing all identified errors.
         * * @author Etienne
         * @param object $objUser The user entity or object containing the data to be validated.
         * @return array An associative array of error messages, where keys match the field names.
         */

        private function verifInfos(object $objUser):array {
            $arrError =[];

            if($objUser->getName()==""){
                $arrError["name"] = "Le nom est obligatoire.";
            }
            if($objUser->getFirstname()==""){
                $arrError["firstname"] = "Le prénom est obligatoire.";
            }
            if($objUser->getPseudo()==""){
                $arrError["pseudo"] = "Le pseudo est obligatoire.";
            }
            if($objUser->getEmail()==""){
                $arrError["email"] = "Le pseudo est obligatoire.";
            }elseif (!filter_var($objUser->getEmail(), FILTER_VALIDATE_EMAIL)) {
                $arrError['email'] = "Le format de l'email n'est pas valide.";
            }

            return $arrError;
        }

        /**
         * @brief Updates the authenticated user's profile settings.
         * * @details This method manages the self-service profile update flow:
         * 1. **Authentication:** Verifies the user is logged in (redirects to 403 otherwise).
         * 2. **Data Hydration:** Retrieves existing user data from the database and populates the UserEntity.
         * 3. **Input Processing:** If a POST request is detected, it hydrates the entity with new data and validates text fields.
         * 4. **Media Management:** Handles profile picture uploads, enforcing JPEG/PNG formats and generating unique filenames.
         * 5. **Security Validation:** If a new password is provided, it enforces strict complexity rules:
         * - Minimum 16 characters.
         * - Must contain uppercase, lowercase, numbers, and special characters.
         * - Must match the password confirmation string.
         * 6. **Persistence:** If no validation errors occur, updates the database and synchronizes the session data.
         * * @author Etienne
         * @return void Handles redirects or renders the settings view.
         */

        public function settingsUser() {
            $this->_checkAccess();


            $objUserModel	= new UserModel;
            $arrUser		= $objUserModel->userPage($_GET['id']??$_SESSION['user']['user_id']);

            $objUser	= new UserEntity;
            $objUser->hydrate($arrUser);

            $arrError = [];

            if (count($_POST) > 0) {
                $objUser->hydrate($_POST);
                $arrError	= $this->verifInfos($objUser);

                if($_FILES['photo']['error'] != 4) {

                    $arrTypeFile = array('image/jpeg', 'image/png');

                    if(!in_array($_FILES['photo']['type'], $arrTypeFile)){
                        $arrError['photo'] = "Le type de fichier n'est pas autorisé (veuillez utiliser un fichier JPEG ou PNG).";
                    }

                    if(!isset($arrError['photo'])){
                        $strImageName = uniqid();

                        switch($_FILES['photo']['type']){
                            case 'image/jpeg' : $strImageName .= '.jpg'; break;
                            case 'image/png' : $strImageName .= '.png'; break;
                        }

                        $strDest = 'assets/img/users/' . $strImageName;

                        if(move_uploaded_file($_FILES['photo']['tmp_name'], $strDest)){
                            $objUser->setPhoto($strImageName);
                        } else {
                            $arrError['photo'] = "Erreur lors du téléchargement";
                        }
                    }
                }

                $password = $objUser->getPwd();
                $strPwdConfirm = $objUser->getPwdConfirm();

                if ($password != "") {

                    if(strlen($password) < 16) {
                        $arrError['pwd'] = "Le mot de passe doit au moins avoir 16 caractères";
                    }

                    if (!preg_match('/[A-Z]/', $password)) {
                        $arrError['pwd'] = "Il manque une majuscule";
                    }

                    if (!preg_match('/[a-z]/', $password)) {
                        $arrError['pwd'] = "Il manque une minuscule";
                    }

                    if (!preg_match('/[0-9]/', $password)) {
                        $arrError['pwd'] = "Il manque au moins un chiffre";
                    }

                    if (!preg_match('/[#?!@$%^&*-]/', $password)) {
                        $arrError['pwd'] = "Il manque un caractère spécial (#?!@$%^&*-)";
                    }

                    if ($password != $strPwdConfirm){
                        $arrError['pwd_confirm'] = "Le mot de passe et sa confirmation ne sont pas identiques";
                    }
                }

                if(count($arrError) == 0){
                    $boolUpdate = $objUserModel->settingsUser($objUser);

                    if($boolUpdate){
                        $_SESSION['user']['user_pseudo'] = $objUser->getPseudo();

                        $_SESSION['success'] = "Le profil à bien été mis à jour";
                        $this->_selfRedirect();
                    }else{
                        $arrError[] = "Erreur lors de la mise a jours, veuilez reessayer";
                    }
                }

            }

            $this->_arrData['arrError'] = $arrError;
            $this->_arrData['objUser']  = $objUser;
            $this->_display("settingsUser");

        }

        /**
         * @brief Displays and manages all user profile interactions and social data.
         * * @details This comprehensive controller method handles the profile lifecycle:
         * 1. **Data Acquisition:** Retrieves the profile owner's data and redirects to a 404 if the user is not found.
         * 2. **Comment Management:** Handles deletion, modification, and reporting of user reviews/comments.
         * 3. **Social Interactions:** Manages "Likes" on reviews, spoiler flagging, and image deletion from the user's movie gallery.
         * 4. **Safety & Moderation:** Processes user-to-user reports and allows users to manage or delete their existing reports.
         * 5. **Collection Rendering:** Fetches and hydrates several object collections for the view:
         * - The user's list of liked movies.
         * - The user's uploaded movie photos.
         * - All reviews/comments written by the user.
         * - User-specific statistics (counts of likes, comments, etc.).
         * * @author Marco & Etienne
         * @return void Renders the "user" view or handles redirects for POST actions.
         */

        public function userPage() {

            $intId = $_GET['id'];
            $objUserModel = new UserModel;
			$arrUser		= $objUserModel->userPage($intId, $_SESSION['user']['user_id']??0);

            if (!$arrUser) {
                $this->_redirect("error/err404");
            }

			$objUser       = new UserEntity('mov_');
			$objUser->hydrate($arrUser);

            

            $objCommentModel = new CommentModel;
            $objComment = new CommentEntity;
            $arrError = [];

            if (isset($_POST['deleteImage']) && isset($_SESSION['user'])) {
                $result = $objUserModel->deletePhotoMovieOfUser($_POST['deleteImage'], $_SESSION['user']['user_id']);

                if ($result) {
                    $_SESSION['success'] = "L'image à bien était supprimer !";
                    $this->_selfRedirect();
                } else {
                    $arrError[] = "erreur lors de la suppression veulliez réssayer !";
                    
                }
            }

            if (isset($_POST['deleteComment']) && isset($_SESSION['user'])) {
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

            elseif (isset($_POST['comment']) && isset($_POST['rating'])) {
                $objComment->hydrate($_POST);
                $result = $objCommentModel->commentModify($objComment, $_SESSION['user']['user_id']);

                if ($result) {
                    $_SESSION['success'] = "Le commentaire à bien était modifier !";
                  
                } else {
                    $arrError[] = "erreur lors de la modification";
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
            }
            elseif(isset($_POST['repComDelete']) && $_POST['repComDelete'] != ''){

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

        	if(isset($_POST['likeReviewBtn'])&&(isset($_SESSION['user']))){

					$repResult = $objCommentModel->LikeComment($_SESSION['user']['user_id'], $_POST['likeReviewBtn']);

					if ($repResult === 1) {
						$_SESSION['success'] = "Votre like a bien été pris en compte !";
                        $this->_selfRedirect();
					} else if($repResult === 2) {
						$_SESSION['success'] = "Votre like a bien été était supprimer !";
                        $this->_selfRedirect();
					}
    			}

            if (isset($_POST['spoiler']) && $_SESSION['user']['user_funct_id'] != 1) {
                if ($objCommentModel->addSpoiler($_POST['spoiler'])) {
                    $_SESSION['success'] = "Spoiler Update !";
                    $this->_selfRedirect();
                }
            }



            $objUser = new UserEntity;
            $objUser->hydrate($arrUser);

            if (isset($_POST['repUser']) && $_POST['repUser'] != '' && isset($_SESSION['user']['user_id'])) {

                $objReport = new ReportEntity;
                $objReport->setReason($_POST['repUser']);

                $repResult = $objUserModel->reportUser($objUser, $objReport,$_SESSION['user']['user_id']);

                if ($repResult) {
                    $_SESSION['success'] = "Le signalement a bien été envoyé !";
                    $this->_selfRedirect();
                }  else {
                    $arrError[] = "erreur";
                }

            } elseif(isset($_POST['repDelete']) && $_POST['repDelete'] == 'delete'){

				$repResult = $objUserModel->deleteRepUser($objUser, $_SESSION['user']['user_id']);

                if ($repResult) {
                    $_SESSION['success'] = "Votre signalement a bien était supprimer ! !";
                    $this->_selfRedirect();
                }  else {
                    $arrError[] = "erreur";
                }

            }

            if(isset($_SESSION['user']) && $_GET['id'] == $_SESSION['user']['user_id']){


                $objReportModel = new ReportModel;

                $arrReport = $objReportModel->repOfConnectUser($_SESSION['user']['user_id']);

                $arrReportToDisplay = array();

                foreach ($arrReport as $arrDetReport) {
                    $objReport = new ReportEntity;
                    $objReport->hydrate($arrDetReport);
                    $arrReportToDisplay[] = $objReport;
                }

                $this->_arrData['arrReportToDisplay'] = $arrReportToDisplay;
            }



            $objLikeModel = new MovieModel;
            $arrImage = $objUserModel->photoMovieOfUser($intId);
            $arrLike = $objLikeModel->userLike($intId);
            $arrMovieToDisplay = array();

            foreach ($arrLike as $arrDetMovie) {
                $objMovie = new MovieEntity('mov_');
                $objMovie->hydrate($arrDetMovie);
                $arrMovieToDisplay[] = $objMovie;
            }

            $arrImageToDisplay = array();

            foreach ($arrImage as $arrDetImage) {
                $objMovieImg = new MovieEntity('pho_');
                $objMovieImg->hydrate($arrDetImage);
                $arrImageToDisplay[] = $objMovieImg;
            }

            $arrComment = $objCommentModel->reviewUser($intId, $_SESSION['user']['user_id'] ?? 0);
            $arrCommentToDisplay = array();

            foreach ($arrComment as $arrDetComment) {
                $objComment = new CommentEntity('com_');
                $objComment->hydrate($arrDetComment);
                $arrCommentToDisplay[] = $objComment;
            }

          
            
            $arrStat = $objUserModel->countStatUser($_GET['id']);   
            $objStat = new UserEntity;
            $objStat->hydrate($arrStat); 
            
            $this->_arrData['arrError'] = $arrError;
            $this->_arrData['objUser'] = $objUser;
            $this->_arrData['objStat'] = $objStat;
            $this->_arrData['arrImageToDisplay'] = $arrImageToDisplay;
            $this->_arrData['arrMovieToDisplay'] = $arrMovieToDisplay;
            $this->_arrData['arrCommentToDisplay'] = $arrCommentToDisplay;
            

            $this->_display("user");
        }

        /**
         * @brief Deletes a user account (Self-service or Administrative).
         * * @details This method handles two distinct deletion flows:
         * * **1. Administrative Deletion (Target ID provided via GET):**
         * - Verifies that the current user is a Moderator or Admin (Rank 2 or 3).
         * - Prevents admins from deleting themselves via this tool (redirects to self-deletion).
         * - Validates target existence and checks role hierarchy (cannot delete higher or equal ranks).
         * - Protects top-level Administrators (Rank 3) from being deleted.
         * * **2. Self-Deletion (No ID provided):**
         * - Allows any logged-in user to delete their own account.
         * - Clears session data, destroys the session, and prepares a farewell message.
         * * @author Etienne
         * @return void Handles redirects to "allUser", "error/err403", or home page.
         */

        public function deleteAccount(){

            $this->_checkAccess();

            $objUserModel = new UserModel();
            $myId         = (int)$_SESSION['user']['user_id'];
            $myRank       = (int)$_SESSION['user']['user_funct_id'];


            if (isset($_GET['id']) && !empty($_GET['id'])) {

                $intTargetId = (int)$_GET['id'];

                if ($myRank != 2 && $myRank != 3){
                    $this->_redirect('user/allUser');
                }


                if ($intTargetId == $myId){
                    $_SESSION['success'] = "Pour supprimer votre propre compte, ne passez pas par la gestion admin.";
                    $this->_redirect('user/allUser');
                }


                $arrTargetData = $objUserModel->findUser($intTargetId);

                if(!$arrTargetData) {
                    $_SESSION['success'] = "Cet utilisateur n'existe pas.";
                    $this->_redirect('user/allUser');
                }


                $objTargetUser = new UserEntity();
                $objTargetUser->hydrate($arrTargetData);
                $targetRank = (int)$objTargetUser->getUser_funct_id();


                if($targetRank == 3) {
                    $_SESSION['success'] = "ACTION REFUSÉE : Impossible de supprimer un Administrateur.";
                    $this->_redirect("error/err403");
                }


                if($myRank <= $targetRank) {
                    $_SESSION['error'] = "Vous n'avez pas le grade suffisant pour supprimer cet utilisateur.";
                    $this->_redirect("error/err403");
                }

                if($objUserModel->deleteUser($intTargetId)) {
                    $_SESSION['success'] = "L'utilisateur a bien été supprimé.";
                    $this->_redirect('user/allUser');
                } else {
                    $_SESSION['success'] = "Erreur technique lors de la suppression.";
                }

               $this->_selfRedirect();

            }

            else {

                if($objUserModel->deleteUser($myId)){

                    unset($_SESSION['user']);
                    session_destroy();
                    session_start();
                    $_SESSION['success'] = "Votre compte a bien été supprimé. Au revoir !";
                    $this->_selfRedirect();
                } else {
                    $_SESSION['error'] = "Erreur lors de la suppression de votre compte.";
                    $this->_selfRedirect();
                }
            }
        }

        /**
         * @brief Displays the user management list with search and filtering capabilities.
         * * @details This controller method manages the administrative user overview:
         * 1. Access Control: Restricts access to users with administrative privileges (level 3).
         * 2. Parameter Retrieval: Extracts search terms and filter criteria from the URL (GET).
         * 3. Data Acquisition: Fetches filtered user data from the database via UserModel.
         * 4. Object Mapping: Transforms raw database arrays into a collection of UserEntity objects using hydration.
         * 5. View Preparation: Passes the object list, search terms, and active filters to the display engine.
         * * @author Etienne
         * @return void
         */

        public function allUser(){
            $this->_checkAccess(3);

            $search = $_GET['search'] ?? NULL;
            $filter = $_GET['filter'] ?? 'all';




			$objUserModel 	= new UserModel;
			$arrUsers 		= $objUserModel->findAllUsers();
            $arrUsers       = $objUserModel->findAllUsersWithFilters($search, $filter);

			// Initialisation d'un tableau => objets
			$arrUserToDisplay	= array();

			// Boucle de transformation du tableau de tableau en tableau d'objets
			foreach($arrUsers as $arrDetUser){
				$objUser = new UserEntity;
				$objUser->hydrate($arrDetUser);
				$arrUserToDisplay[]	= $objUser;
			}

			$this->_arrData['arrUserToDisplay']	    = $arrUserToDisplay;
            $this->_arrData['searchTerm']           = $search;
            $this->_arrData['filter']               = $filter;

			$this->_display("allUser");
		}

        /**
         * @brief Manages administrative user profile settings and updates.
         * * @details This method handles the comprehensive profile editing logic:
         * 1. Access Control: Verifies administrative privileges (level 3).
         * 2. Data Retrieval: Fetches target user data via GET ID or defaults to the current session user.
         * 3. Hydration: Populates the User entity with existing data and handles POST form submissions.
         * 4. File Management: Validates and processes profile picture uploads (JPEG/PNG), 
         * generating unique filenames and moving them to the permanent storage directory.
         * 5. Persistence: Updates the database via UserModel and provides session feedback.
         * 6. View Rendering: Passes error messages and the User object to the settings view.
         * * @author Etienne
         * @return void
         */

        public function settingsAllUser() {

            $this->_checkAccess(3);

            $objUserModel	= new UserModel;
            $arrUser		= $objUserModel->userPage($_GET['id']??$_SESSION['user']['user_id']);

            $objUser	= new UserEntity;
            $objUser->hydrate($arrUser);

            $arrError = [];


            if (count($_POST) > 0) {
                $objUser->hydrate($_POST);
                $arrError	= $this->verifInfos($objUser);

                if($_FILES['photo']['error'] != 4) {

                    $arrTypeFile = array('image/jpeg', 'image/png');

                    if(!in_array($_FILES['photo']['type'], $arrTypeFile)){
                        $arrError['photo'] = "Le type de fichier n'est pas autorisé (veuillez utiliser un fichier JPEG ou PNG).";
                    }

                    if(!isset($arrError['photo'])){
                        $strImageName = uniqid();

                        switch($_FILES['photo']['type']){
                            case 'image/jpeg' : $strImageName .= '.jpg'; break;
                            case 'image/png' : $strImageName .= '.png'; break;
                        }

                        $strDest = 'assets/img/users/' . $strImageName;

                        if(move_uploaded_file($_FILES['photo']['tmp_name'], $strDest)){
                            $objUser->setPhoto($strImageName);
                        } else {
                            $arrError['photo'] = "Erreur lors du téléchargement";
                        }
                    }
                }

                if(count($arrError) == 0){
                    $boolUpdate = $objUserModel->settingsAllUser($objUser);

                    if($boolUpdate){
                        if($objUser->getPseudo() == $_SESSION['user']['user_pseudo']){

                        $_SESSION['success'] = "Le profil à bien été mis à jour";
                        $this->_redirect("user/allUser");
                        }
                    }else{
                        $arrError[] = "Erreur lors de la mise a jours, veuillez reessayer";
                    }
                }

            }

            $this->_arrData['arrError'] = $arrError;
            $this->_arrData['objUser']  = $objUser;
            $this->_display("settingsAllUser");

        }

        /**
         * @brief Updates a user's permission level (rank).
         * * @details Administrative update process:
         * 1. Verifies administrative privileges (Moderator/Admin) before allowing the operation.
         * 2. Captures the target user ID from the URL and the new rank ID from the POST data.
         * 3. Updates the user's role within the database via the UserModel.
         * 4. Provides session feedback (success or error message) based on the operation result.
         * 5. Redirects the administrator back to the user management list.
         * * @author Etienne
         * @return void
         */

        public function updateGrade() {
            
            $this->_checkAccess(3);

            $intIdUser      = $_GET['id']?? null;
            $intNewGrade = $_POST['user_funct_id'] ?? null;

            if($intIdUser && $intNewGrade) {
                $objUserModel = new UserModel();
                $success = $objUserModel->updateGrade((int)$intIdUser, (int)$intNewGrade);

                if($success){
                    $_SESSION['success'] = "Le grade a bien été mis à jour.";
                    $this->_redirect('user/allUser');
                } else {
                    $_SESSION['error'] = "Erreur lors de la mise à jour";
                }
            }

            $this->_redirect("user/allUser");
        }

        /**
         * @brief Controls access to the permissions management page.
         * * @details Access control flow:
         * 1. Verifies if the user is logged in and holds a specific authorized role (ID 2 or 3).
         * 2. If authentication or authorization fails, redirects to a 403 error page and terminates.
         * 3. If authorized, loads and displays the permissions view.
         * * @author Audrey
         * @return void
         */

        public function permissions() {
            $this->_checkAccess();
            $this->_display("permissions");
        }

        /**
         * @brief Handles password recovery requests and sends reset emails.
         * * @details This method manages the initial stage of the "forgot password" flow:
         * 1. Initializes the User entity and checks for incoming POST data.
         * 2. Retrieves the submitted email and searches for a matching user in the database.
         * 3. Sets a generic success message (Security best practice to prevent user enumeration).
         * 4. If the user exists, generates a secure 64-character token and stores it.
         * 5. Constructs a recovery link and prepares the email body using a template.
         * 6. Sends the recovery email and redirects upon success, or renders the default view.
         * * @author Etienne
         * @return void This method handles view rendering and redirects directly.
         */

        public function forgotPwd(){
			$objUser 	= new UserEntity();
            $arrError = [];

            $this->_arrData['objUser'] = $objUser;

			
			if (count($_POST) >0) {
				
				$strMail 	= $_POST['email'];
				$objUser->setEmail($strMail);
				
				$objModel	= new UserModel();
				$arrUser 	= $objModel->findUserByMail($objUser->getEmail());

                $_SESSION['success'] = "Si vous êtes inscrit sur notre site, vous allez recevoir un mail contenant un lien pour redéfinir votre mot de passe.";
				
				if ($arrUser !== false){
					$strToken 	= bin2hex(random_bytes(64));
					$boolOk		= $objModel->updateForgotInfos($strToken, $arrUser['user_id']);
					if ($boolOk){
                        $link = $_ENV['BASE_URL']."user/recoverPwd?token=" . $strToken;

				
						$this->_objMail->addAddress($arrUser['user_email'], $arrUser['user_name'].' '.$arrUser['user_firstname']);
						$this->_objMail->Subject    = "Mot de passe oublié";
				
						
						$this->_arrData['link']  = $link;
						$this->_arrData['user_name']  = $arrUser['user_name'];

						$this->_objMail->Body      	= $this->_display("mailForgotPwd", false);

                        if($this->_sendMail()){
                            $_SESSION['success'] = "Cliquez sur le lien que nous venons de vous envoyer par e-mail pour continuer.";
                            $this->_selfRedirect();
                        }
                    }
				}
			}
			
			$this->_display("forgotPwd");
        }

        /**
         * @brief Handles the password recovery process.
         * * This controller method manages the token-based password reset flow:
         * 1. Retrieves and validates the recovery token from the URL (redirects if missing).
         * 2. Verifies the token against the database to identify the associated user.
         * 3. Redirects to the forgot password page if the token is invalid or expired.
         * 4. Upon form submission, validates the new password's complexity and confirmation.
         * 5. If valid, updates the password in the database and redirects to the login page.
         * 6. Renders the recovery view, passing any error messages if the process fails.
         * * @author Etienne
         * @return void This method handles redirects or view rendering directly.
         */
	
		public function recoverPwd(){
            var_dump($_POST);
            $strToken = $_GET['token'] ?? '';
            $arrError = [];
            if(empty($strToken)){
                $_SESSION['error'] = "Token manquant.";
                $this->_redirect("user/login");
            }

			$objModel	= new UserModel();
			$arrUser 	= $objModel->findUserByToken($_GET['token']);

            if($arrUser === false) {
                $_SESSION['error'] = "Ce lien de réinitialisation est invalide ou expiré.";
                $this->_selfRedirect("user/forgotPwd");
            }
			
			if (count($_POST) > 0){
				$objUser 	= new UserEntity();
				$objUser->setId($arrUser['user_id']);
				$objUser->setPwd($_POST['pwd'] ?? '');

                $arrError 	= $this->_verifPwd($objUser, $_POST['pwdConfirm']);

				if (count($arrError) == 0){
					$boolOk	= $objModel->updatePwd($objUser);
					if ($boolOk){
						$_SESSION['success'] = "Votre mot de passe a bien été changé";
						$this->_redirect("user/login");
					}else{
						$arrError[]	= "Erreur lors du changement de mot de passe.";
					}
				}
			}			
			
			$this->_arrData['arrError']	= $arrError;
			
			$this->_display("recoverPwd");
		}

        /**
         * @brief Validates password complexity and confirmation.
         * * This method performs the following validation steps:
         * 1. Retrieves the password from the User entity.
         * 2. Checks complexity rules (length, uppercase, lowercase, numbers, special characters).
         * 3. Compares the password with the confirmation string.
         * 4. Collects and returns any validation errors found.
         * * @author Etienne
         * @param UserEntity $objUser The user entity containing the password to validate.
         * @param string $strPwdConfirm The confirmation string provided by the user.
         * @return array An associative array of error messages. Empty if validation passes.
         */
        
        private function _verifPwd(UserEntity $objUser, string $strPwdConfirm): array {
            $arrError = [];
            $password = $objUser->getPwd();

            if ($password == "") {
                $arrError['pwd'] = "Le mot de passe est obligatoire";
            } else {
                if (strlen($password) < 16) {
                    $arrError['pwd'] = "Le mot de passe doit au moins avoir 16 caractères";
                }

                if (!preg_match('/[A-Z]/', $password)) {
                    $arrError['pwd'] = "Il manque une majuscule";
                }

                if (!preg_match('/[a-z]/', $password)) {
                    $arrError['pwd'] = "Il manque une minuscule";
                }

                if (!preg_match('/[0-9]/', $password)) {
                    $arrError['pwd'] = "Il manque au moins un chiffre";
                }

                if (!preg_match('/[#?!@$%^&*-]/', $password)) {
                    $arrError['pwd'] = "Il manque un caractère spécial (#?!@$%^&*-)";
                }

                if ($password != $strPwdConfirm) {
                    $arrError['pwd_confirm'] = "Le mot de passe et sa confirmation ne sont pas identiques";
                }
            }

            return $arrError;
        }
}

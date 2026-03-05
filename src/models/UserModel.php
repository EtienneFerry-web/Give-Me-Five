<?php
    namespace App\Models;
    use PDO;

	/**
	 * UserModel Class.
	 * Manage all interactions with 'users' and 'reports' table.
	 */

    class UserModel extends Connect{

		/**
         * @brief Retrieves a specific active user by their unique ID.
         * @details Selects all columns from the 'users' table where the ID matches and the account has not been soft-deleted.
         * @author Etienne
         * @param int $id The unique identifier of the user.
         * @return array|bool The user data as an associative array, or false if not found.
         */

		public function findUser(int $id) {
			$strRq = "SELECT *
						FROM users
						WHERE user_id = :id
						AND user_deleted_at IS NULL";

			$prep = $this->_db->prepare($strRq);
			$prep->bindValue(':id', $id, PDO::PARAM_INT);
			$prep->execute();

			return $prep->fetch();
		}

		/**
         * @brief Fetches a list of all non-deleted users in the system.
         * @details Returns basic identification fields (ID, Name, Pseudo, Email, Role) for all active accounts.
         * @author Etienne
         * @return array A collection of user records.
         */

        public function findAllUsers():array{
			$strRq	= "SELECT user_id, user_firstname, user_name, user_pseudo, user_email, user_funct_id
						FROM users
						WHERE user_deleted_at IS NULL";

			return $this->_db->query($strRq)->fetchAll();
		}

		/**
         * @brief Performs an advanced search for users with dynamic filtering and sorting.
         * @details Filters by pseudo (LIKE) and user role (Admin, Moderator, User). 
         * Supports alphabetical or chronological sorting based on the provided filter string.
         * @author Etienne
         * @param string|null $strSearch The partial or full pseudo to search for.
         * @param string $strFilter The specific filter or sort order to apply.
         * @return array An array of matching user records.
         */

		public function findAllUsersWithFilters(?string $strSearch, string $strFilter): array {


			$strRq = "SELECT user_id, user_firstname, user_name, user_pseudo, user_email, user_funct_id, user_ban_at
						FROM users
						WHERE user_deleted_at IS NULL";

			$params = [];
			if (!empty($strSearch)) {

				$strRq .= " AND user_pseudo LIKE :search";

				$params[':search'] = "%" . $strSearch . "%";
			}

			$orderBy = " ORDER BY user_id DESC";

			switch($strFilter) {

				case 'admin':
					$strRq .= " AND user_funct_id = 3";
					break;
				case 'modo':
					$strRq .= " AND user_funct_id = 2";
					break;
				case 'user':
					$strRq .= " AND user_funct_id = 1";
					break;
				case 'asc':
					$orderBy = " ORDER BY user_pseudo ASC";
					break;
				case 'desc':
					$orderBy = " ORDER BY user_pseudo DESC";
					break;
				default:
					break;
			}
			

			$strRq .= $orderBy;

			$prep = $this->_db->prepare($strRq);

			foreach($params as $key => $val) {
				$prep->bindValue($key, $val, PDO::PARAM_STR);
			}

			$prep->execute();

			return $prep->fetchAll();
		}

		/**
         * @brief Authenticates a user by checking their email and password.
         * @details Retrieves the user by email and uses password_verify() to check the hash. 
         * The password hash is unset from the result array before returning for security.
         * @author Etienne
         * @param string $strEmail The user's email address.
         * @param string $strPwd The plain-text password provided by the user.
         * @return array|bool User details on success, false on failure or if user is not found.
         */

		public function verifUser(string $strEmail, string $strPwd):array|bool{
		    //Basic query to find a user
			$strRq	= "	SELECT user_id, user_name, user_firstname, user_pseudo ,user_pwd, user_funct_id, user_email, user_ban_at, user_reason_ban
						FROM users
						WHERE user_email = '".$strEmail."'";
			$arrUser 	= $this->_db->query($strRq)->fetch();


			// Verify password hash
			if(!empty($arrUser)){
				if (password_verify($strPwd, $arrUser['user_pwd'])){
					unset($arrUser['user_pwd']);
					return $arrUser;
				}else{
					return false;
				}
			} else{
				return false;
			}
		}

		/**
         * @brief Handles new user registration with duplicate checking.
         * @details Verifies if the email or pseudo already exists. If unique, inserts a new record with a hashed password and the current timestamp.
         * @author Etienne
         * @param object $objUser Hydrated UserEntity containing registration data.
         * @return mixed Existing user data if conflict found, boolean result of the insertion otherwise.
         */

		public function insert(object $objUser){
	
		    $strRq1 = " SELECT user_email, user_pseudo
                        FROM users
                        WHERE user_email = :email OR user_pseudo = :pseudo ";

            $rqPrep1	= $this->_db->prepare($strRq1);
            $rqPrep1->bindValue(":pseudo", $objUser->getPseudo(), PDO::PARAM_STR);
			$rqPrep1->bindValue(":email", $objUser->getEmail(), PDO::PARAM_STR);
			$rqPrep1->execute();

			$arrInsertRequest = $rqPrep1->fetch();

			
			if(isset($arrInsertRequest['user_email']) && !empty($arrInsertRequest['user_email'])){
			   return $arrInsertRequest;
				exit;
			} else{
    			$strRq2 	=   "INSERT INTO users (user_name, user_firstname, user_pseudo, user_email, user_birthdate, user_pwd, user_creadate)
    						            VALUES (:name, :firstname, :pseudo, :email, :birthdate,:pwd, NOW())";

    			$rqPrep2	= $this->_db->prepare($strRq2);
    			$rqPrep2->bindValue(":name", $objUser->getName(), PDO::PARAM_STR);
    			$rqPrep2->bindValue(":firstname", $objUser->getFirstname(), PDO::PARAM_STR);
    			$rqPrep2->bindValue(":pseudo", $objUser->getPseudo(), PDO::PARAM_STR);
    			$rqPrep2->bindValue(":birthdate", $objUser->getBirthdate(), PDO::PARAM_STR);
    			$rqPrep2->bindValue(":email", $objUser->getEmail(), PDO::PARAM_STR);
    			$rqPrep2->bindValue(":pwd", $objUser->getPwdHash(), PDO::PARAM_STR);

    			return $rqPrep2->execute();
			}
		}
		
		/**
         * @brief Locates an active user based on their email address.
         * @details Used typically for password recovery or duplicate checks, excluding soft-deleted accounts.
         * @author Etienne
         * @param string $strMail The email address to search for.
         * @return array|bool User identification data or false if no match.
         */

		public function findUserByMail(string $strMail):array|bool{
			$strRq 		= "SELECT user_id, user_email, user_name, user_firstname
							FROM users
							WHERE user_email = :email
								AND user_deleted_at IS NULL";
			$rqPrepare 	= $this->_db->prepare($strRq);
			$rqPrepare->bindValue(":email", $strMail, PDO::PARAM_STR);
			$rqPrepare->execute();
			$arrUser	= $rqPrepare->fetch();
			return $arrUser;
		}
			
		/**
         * @brief Validates a password reset token.
         * @details Checks if the token exists, is not expired (reset_expires > NOW), and belongs to an active user.
         * @author Etienne
         * @param string $strToken The unique security token from the reset link.
         * @return array|bool The user ID if valid, false otherwise.
         */

		public function findUserByToken(string $strToken):array|bool{
			$strRq 		= "SELECT user_id
							FROM users
							WHERE user_reset_token = :token
								AND user_reset_expires > NOW()
								AND user_deleted_at IS NULL";
			$rqPrepare 	= $this->_db->prepare($strRq);
			$rqPrepare->bindValue(":token", $strToken, PDO::PARAM_STR);
			$rqPrepare->execute();
			$arrUser	= $rqPrepare->fetch();
			return $arrUser;
		}
		
		/**
         * @brief Updates the security token and expiration for password recovery.
         * @details Sets a 30-minute window for the user to reset their password.
         * @author Etienne
         * @param string $strToken The generated reset token.
         * @param int $intId The ID of the user requesting the reset.
         * @return bool True on successful update.
         */

		public function updateForgotInfos(string $strToken, int $intId):bool {
			$strRq = "UPDATE users
						SET user_reset_token 	= :token,
							user_reset_expires 	= DATE_ADD(NOW(), INTERVAL 30 MINUTE)
						WHERE user_id = :id";
			$prep = $this->_db->prepare($strRq);
			$prep->bindValue(":token", $strToken, PDO::PARAM_STR);
			$prep->bindValue(":id", $intId, PDO::PARAM_INT);
			return $prep->execute();
		}

		/**
         * @brief Retrieves data for a public profile, including social status.
         * @details Joins the 'functions' table for the rank name and checks if the visitor has already reported this specific user.
         * @author Marco
         * @param int $idUser The ID of the profile being viewed.
         * @param int $idConnectUser The ID of the currently logged-in visitor.
         * @return array|bool Detailed user profile data or false.
         */

        public function userPage(int $idUser=0, $idConnectUser=0){

            $strRq	= " SELECT users.*, functions.funct_name AS 'user_function',
						EXISTS(
                            SELECT 1 FROM reports
                            WHERE rep_reported_user_id = user_id
                            AND rep_reporter_user_id = $idConnectUser
                            AND rep_pseudo_user IS NOT NULL
							AND rep_deleted_at IS NULL
                            ) AS 'user_reported'
                        FROM users
                        INNER JOIN functions ON users.user_funct_id = functions.funct_id
                        WHERE user_id = $idUser AND user_deleted_at IS NULL AND (user_ban_at IS NULL OR user_ban_at < NOW())";

            return $this->_db->query($strRq)->fetch();
        }

		/**
         * @brief Performs a soft delete on a user account.
         * @details Updates the 'user_deleted_at' column with the current timestamp instead of removing the row.
         * @author Etienne
         * @param int $intId The unique ID of the user to deactivate.
         * @return bool Success status of the update.
         */

        public function deleteUser(int $intId){
			$strRq = "UPDATE users SET user_deleted_at = NOW(), user_email = NULL
					  WHERE user_id = :id";

			$rqPrep = $this->_db->prepare($strRq);
			$rqPrep->bindValue(':id', $intId, PDO::PARAM_INT);

			return $rqPrep->execute();
        }

		/**
         * @brief Executes a formal ban via a database stored procedure.
         * @details Calls 'auto_ban_users' to handle the banning logic and reason storage.
         * @author Marco
         * @param object $objReport Report entity containing the user ID and ban reason.
         * @return bool Success status of the procedure call.
         */

        public function banUser(object $objReport):bool{
			$strRq = "CALL auto_ban_users(:id, :reason)";

			$rqPrep = $this->_db->prepare($strRq);
			$rqPrep->bindValue(':id', $objReport->getId(), PDO::PARAM_INT);
			$rqPrep->bindValue(':reason', $objReport->getReason(), PDO::PARAM_STR);

			return $rqPrep->execute();
        }

		/**
         * @brief Updates the profile settings for the authenticated user.
         * @details Synchronizes the database with the UserEntity data. Dynamically includes the password in the update only if provided.
         * @author Etienne
         * @param object $objUser Hydrated UserEntity with updated information.
         * @return bool Success status of the update.
         */

		public function settingsUser(object $objUser):bool{

			$strRq = "	UPDATE users
						SET user_name 			= :name,
							user_firstname		= :firstname,
							user_pseudo 		= :pseudo,
							user_birthdate		= :birthdate,
							user_photo			= :photo,
							user_email			= :email,
							user_bio			= :bio,
							user_updated_at		= NOW()";

					if(!empty($objUser->getPwd())){

			$strRq .=",		user_pwd			=:pwd";
						}
			$strRq .="		WHERE user_id			= :id";

			$rqPrep	= $this->_db->prepare($strRq);
				$rqPrep->bindValue(":name", $objUser->getName(), PDO::PARAM_STR);
				$rqPrep->bindValue(":firstname", $objUser->getFirstname(), PDO::PARAM_STR);
				$rqPrep->bindValue(":pseudo", $objUser->getPseudo(), PDO::PARAM_STR);
				$rqPrep->bindValue(":email", $objUser->getEmail(), PDO::PARAM_STR);
				$rqPrep->bindValue(":birthdate", $objUser->getBirthdate(), PDO::PARAM_STR);
				$rqPrep->bindValue(":photo", $objUser->getPhoto(), PDO::PARAM_STR);
				$rqPrep->bindValue(":bio", $objUser->getBio(), PDO::PARAM_STR);
				$rqPrep->bindValue(":id", $objUser->getId(), PDO::PARAM_INT);

			if(!empty($objUser->getPwd())){
					$rqPrep->bindValue(":pwd", $objUser->getPwdHash(), PDO::PARAM_STR);
			}
				
			return $rqPrep->execute();
		}

		/**
         * @brief Allows administrative modification of any user profile.
         * @details Updates core profile data (bio, photo, email, etc.) without affecting security credentials.
         * @author Etienne
         * @param object $objUser UserEntity containing the changes.
         * @return bool Success status of the update.
         */

		public function settingsAllUser(object $objUser):bool{

			$strRq = " 	UPDATE users
						SET user_name 			= :name,
							user_firstname		= :firstname,
							user_pseudo 		= :pseudo,
							user_birthdate		= :birthdate,
							user_photo			= :photo,
							user_email			= :email,
							user_bio			= :bio,
							user_updated_at		= NOW()
						WHERE user_id 			= :id";

			$rqPrep	= $this->_db->prepare($strRq);

			$rqPrep->bindValue(":name", $objUser->getName(), PDO::PARAM_STR);
			$rqPrep->bindValue(":firstname", $objUser->getFirstname(), PDO::PARAM_STR);
			$rqPrep->bindValue(":pseudo", $objUser->getPseudo(), PDO::PARAM_STR);
			$rqPrep->bindValue(":email", $objUser->getEmail(), PDO::PARAM_STR);
			$rqPrep->bindValue(":birthdate", $objUser->getBirthdate(), PDO::PARAM_STR);
			$rqPrep->bindValue(":photo", $objUser->getPhoto(), PDO::PARAM_STR);
			$rqPrep->bindValue(":bio", $objUser->getBio(), PDO::PARAM_STR);
			$rqPrep->bindValue(":id", $objUser->getId(), PDO::PARAM_INT);

			return $rqPrep->execute();
		}
		
		/**
		 *@author Marco
		 *
		 * Reports a user.
		 * * @param object $objUser The reported user.
		 * @param object $objReport The object containing the reason for the report.
		 * @param int $intId The ID of the person reporting.
		 * @return bool
		 */

		public function reportUser(object $objUser, object $objReport, int $intId){
		    $strRq = "  INSERT INTO reports (rep_reported_user_id, rep_reporter_user_id, rep_reason, rep_pseudo_user, rep_bio_user ,rep_date)
						VALUES 				(:userId, :reporter, :reason, :pseudo, :bio, NOW())";

      		$rqPrep = $this->_db->prepare($strRq);

      		$rqPrep->bindValue(':userId', $objUser->getId(), PDO::PARAM_INT);
      		$rqPrep->bindValue(':reporter', $intId, PDO::PARAM_INT);
            $rqPrep->bindValue(':reason', $objReport->getReason(), PDO::PARAM_STR);
            $rqPrep->bindValue(':pseudo', $objUser->getPseudo(), PDO::PARAM_STR);
            $rqPrep->bindValue(':bio', $objUser->getBio(), PDO::PARAM_STR);

      		return $rqPrep->execute();

		}

		/**
		 * @author Marco
		 * Removes a user report (Cancellation).
		 * @param object $objUser The user concerned.
		 * @param int $intId The ID of the person canceling their report.
		 * @return bool
		 */

		public function deleteRepUser(object $objUser, int $intId ){

            $strRq = "  DELETE FROM reports
                        WHERE rep_reported_user_id = :userId AND rep_reporter_user_id = :reporter AND rep_pseudo_user IS NOT NULL";

      		$rqPrep = $this->_db->prepare($strRq);

      		$rqPrep->bindValue(':userId', $objUser->getId(), PDO::PARAM_INT);
      		$rqPrep->bindValue(':reporter', $intId, PDO::PARAM_INT);

      		return $rqPrep->execute();
		}

		/**
		 * @author Etienne
		 * Updates a user's rank (role).
		 * @param int $intId The user ID.
		 * @param int $intFunctId The new role ID (1 = User, 2 = Moderator, 3 = Admin).
		 * @return bool
		 */

		public function updateGrade(int $intId, int $intFunctId):bool {
			$strRq = "UPDATE users
						SET user_funct_id 	= :functId,
							user_updated_at	= NOW()
						WHERE user_id 		= :id";

			$rqPrep = $this->_db->prepare($strRq);

			$rqPrep->bindValue(':functId', $intFunctId, PDO::PARAM_INT);
			$rqPrep->bindValue(":id", $intId, PDO::PARAM_INT);

			return $rqPrep->execute();
		}

		/**
         * @brief Reinstates a banned user via a stored procedure.
         * @details Calls 'unban_user' to clear ban timestamps and restrictions.
         * @author Marco
         * @param int $intId The ID of the user to unban.
         * @return void
         */
		
		public function unBanUser(int $intId){
            $strRq = "  CALL unban_user(:id)";

            $rqPrep = $this->_db->prepare($strRq);

    		$rqPrep->bindValue(":id", $intId, PDO::PARAM_INT);

    		return $rqPrep->execute();
		}

		/**
         * @brief Logs user-related events for security and auditing.
         * @details Records the event type, IP address, and browser agent in the 'logs_users' table.
         * @author Marco
         * @param array $arrData Associative array containing userId, event, ip, and agent.
         * @return bool Success status.
         */

		public function addLogs(array $arrData){
            $strRq = "  INSERT INTO logs_users (log_user_id, log_event, log_ip, log_agent)
                        VALUES (:userId, :event, :ip, :agent)";

            $rqPrep = $this->_db->prepare($strRq);
            $rqPrep->bindValue(":userId", $arrData['userId'], PDO::PARAM_INT);
            $rqPrep->bindValue(":event", $arrData['event'], PDO::PARAM_STR);
            $rqPrep->bindValue(":ip", $arrData['ip'], PDO::PARAM_STR);
            $rqPrep->bindValue(":agent", $arrData['agent'], PDO::PARAM_STR);


            return $rqPrep->execute();
		}

		/**
         * @brief Retrieves all "Content" type photos uploaded by a specific user.
         * @author Marco
         * @param int $intId The user's unique ID.
         * @return array A list of photos (IDs and paths).
         */

		public function photoMovieOfUser(int $intId){
            $strRq = "  SELECT pho_id, pho_photo
           	            FROM photos
               	        WHERE pho_user_id = :id AND pho_type = 'Content'";

            $rqPrep = $this->_db->prepare($strRq);
    		$rqPrep->bindValue(":id", $intId, PDO::PARAM_INT);
            $rqPrep->execute();

            return $rqPrep->fetchAll();
		}

		/**
         * @brief Deletes a photo with a security ownership check.
         * @details Ensures the deletion is performed by the owner or an administrator (Rank 2 or 3).
         * @author Marco
         * @param int $intPhotoId The ID of the photo.
         * @param int $intUserId The ID of the user attempting the deletion.
         * @return bool Success status.
         */

		public function deletePhotoMovieOfUser(int $intPhotoId, int $intUserId){
			$strRq = "  DELETE FROM photos
                        WHERE pho_id = :phoId
                        AND (pho_user_id = :userId
                        OR :userId IN ( SELECT user_id
                                        FROM users
                                        WHERE user_id = :userId
                                        AND (user_funct_id = 2 OR user_funct_id = 3)))";

            $rq = $this->_db->prepare($strRq);

            $rq->bindValue(":phoId",  $intPhotoId, PDO::PARAM_INT);
            $rq->bindValue(":userId", $intUserId, PDO::PARAM_INT);

            return $rq->execute();
		}

		/**
         * @brief Compiles engagement statistics (Total comments and likes).
         * @details Uses subqueries to count active comments and likes for a specific user ID.
         * @author Audrey
         * @param int $intUserId The user's unique ID.
         * @return array Statistics array ['user_nb_comments', 'user_nb_liked'].
         */

		public function countStatUser(int $intUserId):array {
		    $strRq = "SELECT
                        (
                            SELECT count(*)  
    						FROM comments
                            WHERE com_user_id = :userId 
                        ) AS user_nb_comments,
                        (
                            SELECT count(*) 
    						FROM liked
                            WHERE lik_user_id = :userId AND lik_com_id IS NULL
                        )AS user_nb_liked";

            $rqPrep = $this->_db->prepare($strRq);

			$rqPrep->bindValue(':userId', $intUserId, PDO::PARAM_INT);

			$rqPrep->execute();
			return $rqPrep->fetch();

		}

		/**
         * @brief Updates a user's password with a new hash.
         * @author Etienne
         * @param object $objUser UserEntity containing the new password.
         * @return bool Success status.
         */

		public function updatePwd(object $objUser):bool{

			$strRq 	= "UPDATE users 
						SET user_pwd = :pwd
						WHERE user_id = :id";
			$rqPrep	= $this->_db->prepare($strRq);

			$rqPrep->bindValue(":pwd", $objUser->getPwdHash(), PDO::PARAM_STR);
			$rqPrep->bindValue(":id", $objUser->getId(), PDO::PARAM_INT);

			return $rqPrep->execute();
		}

		/**
         * @brief Retrieves the number of failed login attempts for a specific IP.
         * @details Counts entries in the 'login_attempts' table recorded within the last 15 minutes.
         * Used to determine if a brute-force threshold has been reached.
         * @author Etienne
         * @param string $ip The client's IP address.
         * @return int Total number of failures in the current 15-minute window.
         */

		public function getFailedAttempts(string $ip): int {
			$strRq = "SELECT COUNT(*) as total
						FROM login_attempts
						WHERE attempt_ip = :ip
						AND attempt_datetime >(NOW() - INTERVAL 15 MINUTE)";
			$prep = $this->_db->prepare($strRq);
			$prep->bindValue(':ip', $ip, PDO::PARAM_STR);
			$prep->execute();

			$data = $prep->fetch();


			return (int)$data['total'];
		}

		/**
         * @brief Records a new failed login attempt in the database.
         * @details Inserts a timestamped record linked to the user's IP address. 
         * This method is triggered every time a login verification fails.
         * @author Etienne
         * @param string $ip The client's IP address.
         * @return void
         */

        public function addFailedAttempts(string $ip): void{
            $strRq = "INSERT INTO login_attempts (attempt_ip) VALUES (:ip)";
            $rqPrep = $this->_db->prepare($strRq);
            $rqPrep->execute([':ip' => $ip]);
        }

		/**
         * @brief Resets the failure counter for a specific IP.
         * @details Deletes all recorded attempts for the given IP. This is called 
         * after a successful login to "unblock" the user or clean up the table.
         * @author Etienne
         * @param string $ip The client's IP address.
         * @return void
         */
		
        public function clearLoginAttempts(string $ip): void{
            $strRq = "DELETE FROM login_attempts WHERE attempt_ip = :ip";
            $rqPrep = $this->_db->prepare($strRq);
            $rqPrep->execute([':ip' => $ip]);
        }
    }

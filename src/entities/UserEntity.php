<?php
    namespace App\Entities;

    /**
	 * UserEntity Class.
	 * Represents an application user.
	 * Maps the columns of the 'users' table.
	 */

    class UserEntity extends Entity{

        /**
		 * User Attributes
		 */

        private string 	$_name = '';
		private string 	$_firstname = '';
		private string 	$_pseudo = '';
        private string 	$_birthdate = '';
		private string 	$_email = '';
		private ?string $_bio = '';
		private ?string $_photo = '';

		/**
		 * Security and role-related attributes
		 */

		private string 	$_function;
		private string 	$_pwd;
		private string 	$_pwdConfirm;
		private ?string $_ban_at;
		private int 	$_reported = 0;
		private int 	$_funct_id = 1;
		private int 	$_nb_comments = 0;
		private int 	$_nb_likes = 0;


		/**
        * @brief Initializes the entity with an optional database prefix.
		* @param string $prefixe The prefix string used in the database table schema.
        */

		public function __construct(){
			// Table prefix for hydratation
			$this->_prefixe = 'user_';
		}

		/**
		 * Getters & Setters
		 */
		
		/**
		 * Getting the Lastname
		 * @return string from the objectUser
		 */

		public function getNbComment():int{
			return $this->_nb_comments;
		}

		/**
		 * Updating the Lastname
		 * @param string from the new name
		 */

		public function setNb_comments(int $intNbComment){
			$this->_nb_comments = $intNbComment;
		}
		
		/**
        * Sets the ban date.
        *
        * @param string|null $strban The ban date string or null to unban.
        * @return void
        */
		
		public function setBan_at(?string $strban){
			$this->_ban_at = $strban;
		}
		
		/**
        * Checks if the entity is currently banned.
        *
        * @return bool True if a ban date is set, false otherwise.
        */
		
		public function getBanAt(){
			if(is_null($this->_ban_at)){
				return false;
			} else{
				return true;
			}
		}


		/**
		 * Getting the Lastname
		 * @return string from the objectUser
		 */

		public function getNbLike():int{
			return $this->_nb_likes;
		}

		/**
		 * Updating the Lastname
		 * @param string from the new name
		 */

		public function setNb_liked(int $intNbLike){
			$this->_nb_likes = $intNbLike;
		}

		/**
		 * Getting the Lastname
		 * @return string from the objectUser
		 */

		public function getName():string{
			return $this->_name;
		}

		/**
		 * Updating the Lastname
		 * @param string from the new name
		 */

		public function setName(string $strNewName){
			$this->_name = $this->_clean($strNewName);
		}

		/**
		 * Getting the Firstname
		 * @return string from the objectUser
		 */

		public function getFirstname():string{
			return $this->_firstname;
		}

		/**
		 * Updating the Lastname
		 * @param string from the new Firstname
		 */

		public function setFirstname(string $strFirstname){
			$this->_firstname = $this->_clean($strFirstname);
		}

		/**
		 * Getting the Pseudo
		 * @return string from the objectUser
		 */

		public function getPseudo():string{
			return $this->_pseudo;
		}

		/**
		 * Updating the Pseudo
		 * @param string from the new Firstname
		 */

		public function setPseudo(string $strPseudo){
			$this->_pseudo = $this->_clean($strPseudo);
		}

		/**
		 * Getting the Birthdate
		 * @return string from the objectUser
		 */

        public function getBirthdate():string{
            return $this->_birthdate;
        }

		/**
		 * Updating the Birthdate
		 * @param string from the new Birthdate
		 */

        public function setBirthdate(string $strBirthdate){
            $this->_birthdate = $strBirthdate;
        }

		/**
		 * Getting the Email
		 * @return string from the objectUser
		 */		

		public function getEmail():string{
			return $this->_email;
		}

		/**
		 * Updating the Email
		 * @param string from the new Email
		 */

		public function setEmail(string $strEmail){
			$this->_email = strtolower($this->_clean($strEmail));
		}

		/**
		 * Getting the Email
		 * @return string from the objectUser
		 */		

		public function getBio():string{
			return $this->_bio;
		}

		/**
		 * Updating the Email
		 * @param string from the new Email
		 */

		public function setBio(?string $strBio){
			$this->_bio = $this->_clean($strBio??'')??"";
		}

		/**
		 * Getting the Email
		 * @return string from the objectUser
		 */		
		public function getPhoto():string{
			return $this->_photo;
		}
		/**
		 * Updating the Email
		 * @param string from the new Email
		 */
		public function setPhoto(?string $strPhoto){
			$this->_photo = $strPhoto??"defaultImgUser.jpg" ;
		}



		/**
		 * Getting the Email
		 * @return string from the objectUser
		 */		
		public function getPwd():string{
			return $this->_pwd;
		}
		/**
		 * Updating the Email
		 * @param string from the new Email
		 */
		public function setPwd(string $strPwd){
			$this->_pwd = $strPwd;
		}

		/**
		 * Getting the Email
		 * @return string from the objectUser
		 */		
		public function getPwdConfirm():string{
			return $this->_pwdConfirm;
		}
		/**
		 * Updating the Email
		 * @param string from the new Email
		 */
		public function setPwdConfirm(string $strPwdConfirm){
			$this->_pwdConfirm = $strPwdConfirm;
		}


		/**
		 * Getting the Email
		 * @return string from the objectUser
		 */	
		public function getFunction():string{
			return $this->_function;
		}
		/**
		 * Updating the Email
		 * @param string from the new Email
		 */

		public function setFunction(string $strFunction){
			$this->_function = $strFunction;
		}
		/**
		 * Getting the Report
		 * @return string from the objectUser
		 */	
		public function getReported():int{
			return $this->_reported;
		}
		/**
		 * Updating the Report
		 * @param string from the new Report
		 */
		public function setReported(int $intRep){
			$this->_reported = $intRep;
		}

		/**
		 * Getting the PassWord Hash
		 * @return string from the objectUser
		 */	

		public function getPwdHash():string{
			return password_hash($this->_pwd, PASSWORD_DEFAULT);
		}

		/**
		 * Getting the Function
		 * @return string from the objectUser
		 */	

		public function getUser_funct_id(): int {
			return $this->_funct_id;
		}

		/**
		 * Updating the Function 
		 * @param string from the new Function
		 */

		public function setFunct_id(int $intId): void {
			$this->_funct_id = $intId;
		}

    }

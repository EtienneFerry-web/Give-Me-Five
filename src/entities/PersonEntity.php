<?php
    namespace App\Entities;
    use DateTime;
    use IntlDateFormatter;

	/**
	* Classe d'un objet Article
	* @author Marco
	*/
	class PersonEntity extends Entity{
		// Attributs
		private string 	$_name = '';
		private string 	$_firstname = '';
		private string 	$_birthdate;
		private ?string $_deathdate= NULL;
		private ?string $_bio = "";
		private string 	$_country;
		private string 	$_photo;
		private string 	$_NameJob = '';


		/**
        * @brief Initializes the entity with an optional database prefix.
		* @param string $prefixe The prefix string used in the database table schema.
        */

		public function __construct(string $prefixe = ""){
			$this->_prefixe = "pers_";
		}

		/**
		* Getters & Setters
		*/

		/**
        * Getting the birth date
        * @return string the raw birth date
        */

		public function getBirthDate(){
		    return $this->_birthdate;
		}

		/**
        * Getting the death date
        * @return string|null the raw death date
        */

		public function getDeathDate(){
		    return $this->_deathdate;
		}

		/**
        * Calculating the age
        * @return string the age followed by 'ans'
        */

		public function getAge(){
            $dateNaissance = new DateTime($this->_birthdate);
            $age = $dateNaissance->diff(new DateTime())->y;

            return $age .' ans';
		}

		/**
        * Getting the formatted death date
        * @param string $strFormat the locale format (default fr_FR)
        * @return string the formatted death date or empty string
        */

		public function getDeathDateFormat(string $strFormat = "fr_FR"){
      		if (empty($this->_deathdate)) {
                return '';
            }
			$objDate	= new DateTime($this->_deathdate);


	
			$objDateFormatter	= new IntlDateFormatter(
                $strFormat, 
                IntlDateFormatter::LONG,  
                IntlDateFormatter::NONE, 
            );
			$strDate	= $objDateFormatter->format($objDate);
			return 'Mort : '.$strDate;
		}

		/**
        * Getting the formatted birth date
        * @param string $strFormat the locale format (default fr_FR)
        * @return string the formatted birth date or empty string
        */

		public function getBirthdateFormat(string $strFormat = "fr_FR"){
      		if (empty($this->_birthdate)) {
                return '';
            }
			$objDate	= new DateTime($this->_birthdate);

			$objDateFormatter	= new IntlDateFormatter(
                $strFormat, 
                IntlDateFormatter::LONG,  
                IntlDateFormatter::NONE, 
            );
			$strDate	= $objDateFormatter->format($objDate);
			return 'Née : '.$strDate;
		}

		/**
        * Updating the death date
        * @param string|null $strDeathDate the new death date
        */

		public function setDeathDate(?string $strDeathDate){
		    $this->_deathdate = $strDeathDate;
		}

		/**
        * Updating the birth date
        * @param string $strBirthDate the new birth date
        */

		public function setBirthdate(string $strBirthDate){
			$this->_birthdate = $strBirthDate;
		}

		/**
        * Getting the full name
        * @return string the concatenated name and firstname
        */

		public function getFullName():string{
			return $this->_firstname ." ".$this->_name ;
		}

		/**
        * Getting the name
        * @return string the person's last name
        */

		public function getName():string{
			return $this->_name;
		}

		/**
        * Updating the name
        * @param string $strName the new last name
        */

		public function setName(string $strName){
			$this->_name = $strName;
		}

		/**
        * Getting the firstname
        * @return string the person's first name
        */

		public function getFirstname():string{
			return $this->_firstname;
		}

		/**
        * Updating the firstname
        * @param string $strFirstname the new first name
        */

		public function setFirstname(string $strFirstname){
			$this->_firstname = $strFirstname;
		}

		/**
        * Getting the country
        * @return string the person's country
        */

		public function getCountry():string{
			return $this->_country;
		}

		/**
        * Updating the country
        * @param string $strCountry the new country
        */

		public function setCountry(string $strCountry){
			$this->_country = $strCountry;
		}

		/**
        * Getting the biography
        * @return string the person's bio
        */

		public function getBio():string{
			return $this->_bio;
		}

		/**
        * Updating the biography
        * @param string|null $strBio the new bio
        */

		public function setBio(?string $strBio){
			$this->_bio = $strBio;
		}

		/**
        * Getting the photo
        * @return string the photo filename
        */

		public function getPhoto():string{
			return $this->_photo;
		}

		/**
        * Updating the photo
        * @param string $strPhoto the new photo filename
        */

		public function setPhoto(string $strPhoto){
			$this->_photo = $strPhoto;
		}

		/**
        * Getting the job name
        * @return string the name of the job
        */

		public function getNameJob():string{
			return $this->_NameJob;
		}

		/**
        * Updating the job name
        * @param string $strJob the new job name
        */

		public function setNameJob(string $strJob){
			$this->_NameJob = $strJob;
		}



	}

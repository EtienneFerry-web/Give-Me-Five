<?php
    namespace App\Entities;

    use DateTime;
    use IntlDateFormatter;

	class MovieEntity extends Entity{
		// Attributs
		private string  $_title ='';
		private string  $_original_title='';
		private string  $_photo ='';
		private string  $_description = '';
		private string  $_release_date = '';
		private string  $_trailer_url ='';
		private int     $_countryId = 0;
		private string  $_country;
		private int     $_categoriesId = 0;
		private string  $_categories;
		private string  $_length='';
		//private string  $_func;
		private int     $_like;
		private float   $_rating;
		//private string  $_nationality;
		private int	    $_user_liked;
		private ?float	$_note_user;
		private int     $_reported;
		private int 	$_nb_comments = 0;
		private ?string $_published_at = NULL;


		/**
        * @brief Initializes the entity with an optional database prefix.
		* @param string $prefixe The prefix string used in the database table schema.
        */

		public function __construct(string $prefixe = ""){

			$this->_prefixe = $prefixe;
		}

		/**
		* Getters & Setters
		*/

		/**
        * Getting the title
        * @return string the movie title
        */

		public function getTitle():string{
			return $this->_title;
		}

		/**
        * Updating the title
        * @param string $strTitle the new title
        */

		public function setTitle(string $strTitle){
			$this->_title = $this->_clean($strTitle);
		}

		/**
        * Getting the user's personal rating
        * @return float the rating value
        */

		public function getNoteUser():float{
			return $this->_note_user;
		}

		/**
        * Updating the user's personal rating
        * @param float|null $strNote the new rating or null
        */

		public function setNote_user(?float $strNote){
			$this->_note_user = $strNote??'0';
		}

		/**
        * Getting the report status
        * @return int the number of reports
        */

		public function getReported():int{
			return $this->_reported;
		}

		/**
        * Updating the report status
        * @param int $intRep the new report count
        */

		public function setReported(int $intRep){
			$this->_reported = $intRep;
		}

		/**
        * Getting the original title
        * @return string the original movie title
        */

		public function getOriginalTitle():string{
			return $this->_original_title;
		}

		/**
		* Mise à jour du titre
		* @param string le nouveau titre
		*/
		public function setOriginal_title(string $strOriginalTitle){
			$this->_original_title = $this->_clean($strOriginalTitle);
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
        * @param string $strImg the new photo filename
        */

		public function setPhoto(string $strImg){
			$this->_photo = $strImg;
		}

		/**
        * Getting the description
        * @return string the full description
        */

		public function getDescription():string{
			return $this->_description;
		}

		/**
		 * @brief Returns a summary of the description.
		 * @param int $intNbCar Max characters (default 120).
		 * @return string The truncated string with "...".
		 */

		public function getSummary(int $intNbCar = 120):string{
			return mb_strimwidth($this->_description, 0, $intNbCar, "...");
		}

		/**
        * Updating the description
        * @param string $strContent the new description
        */

		public function setDescription(string $strContent){
			$this->_description = $this->_clean($strContent);
		}

		/**
        * Getting a shortened summary of the description
        * @param int $intNbCar maximum number of characters (default 70)
        * @return string the truncated description
        */


		/**
        * Getting the raw release date
        * @return string the release date
        */

		public function getRelease_date():string{
			return $this->_release_date;
		}

		/**
        * Updating the release date
        * @param string $strCreatedate the new release date
        */

		public function setRelease_date(string $strCreatedate){
			$this->_release_date = $strCreatedate;
		}

		/**
        * Getting the formatted release date
        * @param string $strFormat the locale format (default fr_FR)
        * @return string the formatted date
        */

		public function getDateFormat(string $strFormat = "fr_FR"){

			$objDate	= new DateTime($this->_release_date);

			$objDateFormatter	= new IntlDateFormatter(
                $strFormat, 
                IntlDateFormatter::LONG,  
                IntlDateFormatter::NONE, 
            );
			$strDate	= $objDateFormatter->format($objDate);
			return $strDate;
		}

		/**
        * Getting the average rating
        * @return float the formatted rating (1 decimal)
        */

		public function getRating():float{
			return round($this->_rating, 2);
		}

		/**
        * Updating the average rating
        * @param float $floatRating the new rating
        */

		public function setRating(float $floatRating){
			$this->_rating = $floatRating;
		}

		/**
        * Getting the like count
        * @return int the total likes
        */

		public function getLike():int{
			return $this->_like;
		}

		/**
        * Updating the like count
        * @param int $intLike the new like total
        */

		public function setLike(int $intLike){
			$this->_like = $intLike;
		}

		/**
        * Getting the trailer URL
        * @return string the trailer URL
        */

		public function getTrailer():string{
			return $this->_trailer_url;
		}

		/**
        * Updating the trailer URL
        * @param string $strTrailer the new trailer URL
        */
		
		public function setTrailer_url(string $strTrailer){
			$this->_trailer_url = $strTrailer;
		}

		/**
        * Getting the country label
        * @return string the country name
        */

		public function getCountry():string{
			return $this->_country;
		}

		/**
        * Updating the country label
        * @param string $strCountry the new country name
        */
		
		public function setCountry(string $strCountry){
			$this->_country = $strCountry;
		}

		/**
        * Getting the category label
        * @return string the category name
        */

		public function getCategories():string{
			return $this->_categories;
		}

		/**
        * Updating the category label
        * @param string $strCategories the new category name
        */

		public function setCategories(string $strCategories){
			$this->_categories = $strCategories;
		}

		/**
        * Getting the movie length
        * @return string the runtime
        */

		public function getLength():string{
		return str_replace(':00', '', $this->_length);
		}

		/**
        * Updating the movie length
        * @param string $strLength the new runtime
        */
		
		public function setLength(string $strLength){
			$this->_length = $strLength;
		}

		/**
        * Getting the country ID
        * @return int the identifier for the country
        */

		public function getCountryId():int{
			return $this->_countryId;
		}

		/**
        * Updating the country ID
        * @param string $intCountryId the new identifier
        */

		public function setCountryId(int $intCountryId){
			$this->_countryId = (int)$intCountryId;
		}

		/**
        * Getting the category ID
        * @return string the identifier for the category
        */

		public function getCategoriesId():string{
			return $this->_categoriesId;
		}

		/**
        * Updating the category ID
        * @param string $strCategoriesId the new identifier
        */

		public function setCategoriesId(string $strCategoriesId){
			$this->_categoriesId = $strCategoriesId;
		}

		/**
        * Updating the user liked status
        * @param int $bool the new status
        */

		public function setUser_liked($bool){
			$this->_user_liked = $bool;
		}

		/**
        * Getting the user liked status
        * @return int the status value
        */

		public function getUser_liked(){
			return $this->_user_liked;
		}

		/**
        * Getting the total comments count
        * @return int the comment total
        */

		public function getNbComments(): int {
			return $this->_nb_comments;
		}

		/**
        * Updating the total comments count
        * @param int $IntNb the new comment total
        */

		public function setNb_comments(int $IntNb) {
			$this->_nb_comments = $IntNb;
		}

		/**
         * @brief Retrieves the publication date of the movie.
         * @details Returns the date as a string if the movie is public. 
         * If the value is null, it indicates the movie has not been published yet.
         * @return string|null The publication date or null if unpublished.
         */

		public function getPublished(): ?string {
			return $this->_published_at;
		}

		/**
        * Updating the total comments count
        * @param int $IntNb the new comment total
        */

		public function setPublished_at(?string $IntNb) {
			$this->_published_at = $IntNb;
		}
	}

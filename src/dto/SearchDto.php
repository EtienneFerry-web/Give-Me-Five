<?php
    namespace App\Dto;

    /**
	* @author Marco Schmitt 
    * 27/02/2026
    * Version 1
    */

    class SearchDto extends Dto{


		private string  $_name;
		private ?float  $_rating = 0;
		private ?string $_content;
		private ?string $_photo;
		private ?int    $_like;
		private string  $_type;
		private string  $_search;
		private string  $_searchBy;


		/**
		* Constructeur
		*/
		public function __construct(string $prefixe = ""){
			$this->_prefixe = $prefixe;
		}


		/**
        * Returns the result name.
        * @return string The entity name.
        */
		public function getName():string{
		    return $this->_name;
		}

		/**
        * Sets the result name.
        * @param string $strName The name of the entity.
        */
		public function setName(string $strName=""){
		   $this->_name = $strName;
		}

		/**
        * Returns the content description.
        * @return string The bio or description text.
        */
		public function getContent():string{
		    return $this->_content;
		}

		/**
        * Sets the content or biography.
        * @param string|null $strContent The description text.
        */
		public function setContent(?string $strContent=""){
		   $this->_content = $strContent??' ';
		}

		/**
        * Returns the photo path.
        * @return string Path to the image file.
        */
		public function getPhoto():string{
		    return $this->_photo;
		}

		/**
        * Sets the profile or entity photo.
        * @param string|null $strPhoto Path to the image file.
        */
		public function setPhoto(?string $strPhoto=""){
		   $this->_photo = $strPhoto??'assets/img/defaultImgUser.jpg';
		}

		/**
        * Returns the entity type.
        * @return string The category (movie, person, user).
        */
		public function getType():string{
		    return $this->_type;
		}

		/**
        * Sets the entity type (movie, person, user).
        * @param string $strType The category string.
        */
		public function setType(string $strType=""){
		   $this->_type = $strType;
		}
		/**
        * Returns the search query string.
        * @return string The sanitized search term.
        */
		public function getSearch():string{
		    return $this->_search;
		}

		/**
        * Sets and sanitizes the search query.
        * @param string $strSearch The raw search string.
        */
		public function setSearch(string $strSearch=""){
		   $this->_search = $this->clean($strSearch);
		}

		/**
        * Returns the filter category.
        * @return string The filter identifier.
        */
		public function getSearchBy():string{
		    return $this->_searchBy;
		}

		/**
        * Sets the filter category.
        * @param string $strSearchBy The filter identifier.
        */
		public function setSearchBy(string $strSearchBy=""){
		   $this->_searchBy = $this->clean($strSearchBy);
		}

		/**
        * Returns the number of likes.
        * @return int The total like count.
        */
		public function getLike():int{
		    return $this->_like;
		}

		/**
        * Sets the number of likes.
        * @param int|null $intLike Total likes count.
        */
		public function setLike(?int $intLike=0){
		   $this->_like = $intLike??0;
		}


		/**
        * Returns the formatted average rating.
        * @return float The score with one decimal place.
        */
		public function getRating():float{
		    return number_format($this->_rating, 1, '.', '');
		}

		/**
        * Sets the average rating.
        * @param float|null $floatRating The score value.
        */
		public function setRating(?float $floatRating=0){
		   $this->_rating = $floatRating??0;
		}
    }

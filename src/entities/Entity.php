<?php
    namespace App\Entities;
	class Entity {

		protected $_id = null;
		protected string $_prefixe = '';

		/**
        * Hydrating the object with data from an array
        * @param array $arrData the raw data (usually from the database)
        * @return void dynamically calls setters based on array keys
        */

		public function hydrate(array $arrData){
			foreach($arrData as $key=>$value){
				
				$strMethodName = "set".ucfirst(str_replace($this->_prefixe, '', $key));
				if (method_exists($this, $strMethodName)){
					$this->$strMethodName($value);
				}
			}
		}

		/**
        * Getting the identifier
        * @return mixed the entity ID
        */

		public function getId(){
			return $this->_id;
		}

		/**
        * Updating the identifier
        * @param mixed $intId the new ID
        */
	
		public function setId($intId){
			$this->_id = $intId;
		}

		/**
        * Sanitizing string input
        * @param string $strText the raw text to clean
        * @return string the trimmed and filtered text
        */

		protected function _clean(string $strText){
			$strText	= trim($strText);
			$strText = strip_tags($strText);
			return $strText;
		}

	}

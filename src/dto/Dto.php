<?php
    namespace App\Dto;

    /**
	* @author Marco Schmitt 
    * 27/02/2026
    * Version 1
    */


	class Dto {

		protected int $_id;
		protected string $_prefixe = '';

		/**
        * Hydrates the object properties using matching setters.
        * @param array $arrData Associative array of data to map.
        */
		public function hydrate(array $arrData){
			foreach($arrData as $key=>$value){
				// nom de la méthode
				$strMethodName = "set".ucfirst(str_replace($this->_prefixe, '', $key));
				if (method_exists($this, $strMethodName)){
					$this->$strMethodName($value);
				}
			}
		}

		/**
        * Returns the unique identifier.
        * @return int The object ID.
        */
		public function getId():int{
			return $this->_id;
		}

		/**
        * Sets the unique identifier.
        * @param int $intId The new ID value.
        */
		public function setId(int $intId){
			$this->_id = $intId;
		}

		/**
        * Sanitizes strings by trimming and removing script tags.
        * @param string $strText The raw input string.
        * @return string The cleaned string.
        */
		protected function clean(string $strText){
			$strText	= trim($strText);
			$clean = htmlspecialchars($strText);
			return $clean;
		}
	}

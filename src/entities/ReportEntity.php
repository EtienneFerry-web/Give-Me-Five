<?php
    namespace App\Entities;

    use DateTime;

    /**
    * ReportEntity Class
    * Handles data mapping for reports on movies, comments, and users
    * @author Marco
    */

    class ReportEntity extends Entity{
        // Attributs
        private ?int    $_reported_user_id;
        private ?int    $_reported_movie_id;
        private ?int    $_reported_com_id;
        private ?string $_com_content;
        private ?string $_pseudo_user;
        private ?string $_bio_user;
        private string  $_date;
        private int     $_reporter_user_id;
        private string  $_reason;
        private ?string $_pseudo;
        private ?string $_photo;
        private ?string  $_title = NULL;
        private ?string  $_delete_at = NULL;
        private int     $_spoiler;
        private ?bool   $_user_ban = NULL;


        /**
        * @brief Initializes the entity with an optional database prefix.
		* @param string $prefixe The prefix string used in the database table schema.
        */

        public function __construct(string $prefixe = ""){
            $this->_prefixe = "rep_";
        }

        /**
		* Getters & Setters
		*/

        /**
         * @return int|null The ID of the user being reported
         */

        public function getDeletedAt():string{
            if(is_null($this->_delete_at)){
                return 'En cours de traitement';
            } else{
                return 'Traiter';
            }
        }

        public function setDeleted_at(?string $strDate){
            $this->_delete_at = $strDate;
        }

        public function getReportedUserId():?int{
            return $this->_reported_user_id;
        }

        public function setReported_user_id(?int $reported_user_id){
            $this->_reported_user_id = $reported_user_id;
        }


        /**
         * @return int|null The ID of the movie being reported
         */

        public function getReportedMovieId():?int{
            return $this->_reported_movie_id;
        }

        /**
         * @param int|null $reported_movie_id The ID of the reported movie
         */

        public function setReported_movie_id(?int $reported_movie_id){
            $this->_reported_movie_id = $reported_movie_id;
        }

        /**
         * @return int|null The ID of the comment being reported
         */
        public function getReportedComId():?int{
            return $this->_reported_com_id;
        }

        /**
         * @param int|null $reported_com_id The ID of the reported comment
         */

        public function setReported_com_id(?int $reported_com_id){
            $this->_reported_com_id = $reported_com_id;
        }
        
        /**
         * @return string|null The spoiler status (0 or 1 as string)
         */
        
        public function getSpoiler():?string{
            return $this->_spoiler;
        }

        /**
         * @param string|null $strSpoiler The spoiler status (0 or 1)
         */

        public function setSpoiler(?string $strSpoiler){
             $this->_spoiler = $strSpoiler;
        }

        /**
         * @return string|null The pseudo associated with the report
         */

        public function getPseudo():?string{
            return $this->_pseudo;
        }

        /**
         * @param string|null $pseudo The pseudo to assign
         */

        public function setPseudo(?string $pseudo){
             $this->_pseudo = $pseudo;
        }

        /**
         * @return string The title of the reported content
         */

        public function getTitle():?string{
            return $this->_title;
        }

        /**
         * @param string $strTitle The title to assign
         */

        public function setTitle(?string $strTitle){
            $this->_title = $strTitle;
        }

        /**
         * @return string|null The filename of the associated image
         */

        public function getPhoto():?string{
            return $this->_photo;
        }  

        /**
         * @param string|null $photo The image filename (defaults to defaultImgUser.jpg)
         */
        
        public function setPhoto(?string $photo){
             $this->_photo = $photo??'defaultImgUser.jpg';
        }

        /**
         * @return string|null The text content of the reported comment
         */

        public function getComContent():?string{
            return $this->_com_content;
        }

        /**
         * @param string|null $com_content The comment text to assign
         */

        public function setCom_content(?string $com_content){
            $this->_com_content = $com_content;
        }

        /**
         * @return string|null The pseudo of the reported user
         */

        public function getPseudoUser():?string{
            return $this->_pseudo_user;
        }

        /**
         * @param string|null $pseudo_user The reported user's pseudo
         */

        public function setPseudo_user(?string $pseudo_user){
            $this->_pseudo_user = $pseudo_user;
        }

        /**
         * @return string|null The biography of the reported user
         */

        public function getBioUser():?string{
            return $this->_bio_user;
        }  
        
        /**
         * @param string|null $bio_user The reported user's bio
         */
        
        public function setBio_user(?string $bio_user){
            $this->_bio_user = $bio_user;
        }

        /**
         * @return string The date when the report was submitted
         */

        public function getDate():string{
            return $this->_date;
        }

        /**
         * @param string $date The report date string
         */

        public function setDate(string $date){
            $this->_date = $date;
        }

        /**
         * @return int The ID of the user who filed the report
         */

        public function getReporterUserId():int{
            return $this->_reporter_user_id;
        }

        /**
         * @param int $reporter_user_id The ID of the user filing the report
         */
        
        public function setReporter_user_id(int $reporter_user_id){
            $this->_reporter_user_id = $reporter_user_id;
        }

        /**
         * @return string The reason for the report
         */

        public function getReason():string{
            return trim($this->_reason);
        }

        /**
         * @param string $reason The description of why the content is being reported
         */

        public function setReason(string $reason){
            $this->_reason = $reason;
        }

        public function getUserBan():bool{
            $curdate = new DateTime;

            if($this->_user_ban >= $curdate){
                return true;
            } else{
                return false;
            }

        }

        public function setUser_ban(?string $strBan){
            $this->_user_ban = $strBan;
        }
    }

<?php
    namespace App\Models;
    use PDO;

    /**
     * @author Marco Schmitt
     * 27/02/2026
     * Version 1
     */

    class PersonModel extends Connect{

    public ?string $strSearch = null;
    public int $intJob = 0;

    /**
    * * @author Audrey
    * Retrieving the complete cast and crew for a specific movie
    * @param int $idMovie the identifier of the movie
    * @return array a list of all persons (actors, directors, etc.) and their nationality
    */

    public function findAllPerson(int $idMovie=0): array {

        $strRq	= " SELECT persons.*, nat_country AS 'pers_country'
                    FROM persons
                    LEFT JOIN participates ON persons.pers_id = participates.part_pers_id
                    LEFT JOIN movies ON participates.part_mov_id = movies.mov_id
                    LEFT JOIN nationalities ON persons.pers_nat_id = nationalities.nat_id
                    WHERE mov_id = $idMovie
                    GROUP BY pers_id";

        return $this->_db->query($strRq)->fetchAll();
    }

    /**
    * @author Audrey
    * Retrieving a simplified list of all persons in the database
    * @return array a collection of all individuals with their IDs and full names
    */

    public function listPerson(): array {

        $strRq	= " SELECT pers_id, pers_name, pers_firstname
                    FROM persons";

        return $this->_db->query($strRq)->fetchAll();
    }

    /**
    * @author Marco
    * Retrieving a list of all individuals registered as Actors
    * @return array a collection of people who have held the 'Actor' role (Job ID 3)
    */

    public function findActor(): array {

        $strRq	= " SELECT pers_id, pers_name, pers_firstname
                    FROM persons
                    INNER JOIN participates ON persons.pers_id = participates.part_pers_id
                    INNER JOIN jobs ON participates.part_job_id = jobs.job_id
                    WHERE pers_id IN (	SELECT part_pers_id
                                   	FROM participates
                                   	WHERE part_job_id = 3)
                    GROUP BY pers_id;";

        return $this->_db->query($strRq)->fetchAll();

    }

    /**
    * @author Audrey
    * Retrieving a specific individual's profile
    * @param int $idPerson the unique identifier of the person
    * @return array|bool the complete person data including nationality, or false if not found
    */

   	public function findPerson(int $idPerson=0): array {

        $strRq	= " SELECT persons.*, nat_country AS 'pers_country'
                    FROM persons
                    INNER JOIN nationalities ON persons.pers_nat_id = nationalities.nat_id
                    WHERE pers_id = :idPerson";

        $rqPrep = $this->_db->prepare($strRq);
        $rqPrep->bindValue(':idPerson', $idPerson, PDO::PARAM_INT);
        $rqPrep->execute();
        return $rqPrep->fetch();
    }

    /**
    * @author Marco
    * Retrieving a list of all individuals registered as Directors
    * @return array a collection of people who have held the 'Director' role (Job ID 1)
    */
 
    public function findReal(): array {
        $strRq	= " SELECT pers_id, pers_name, pers_firstname
                    FROM persons
                    INNER JOIN participates ON persons.pers_id = participates.part_pers_id
                    INNER JOIN jobs ON participates.part_job_id = jobs.job_id
                    WHERE pers_id IN (	SELECT part_pers_id
                                   	FROM participates
                                   	WHERE part_job_id = 1)
                    GROUP BY pers_id;";

        return $this->_db->query($strRq)->fetchAll();
    }

    /**
    * @author Marco
    * Retrieving a list of all individuals registered as Producers
    * @return array a collection of people who have held the 'Producer' role (Job ID 2)
    */
  
    public function findProducer(): array {
        $strRq	= " SELECT pers_id, pers_name, pers_firstname
                    FROM persons
                    INNER JOIN participates ON persons.pers_id = participates.part_pers_id
                    INNER JOIN jobs ON participates.part_job_id = jobs.job_id
                    WHERE pers_id IN (	SELECT part_pers_id
                                   	FROM participates
                                   	WHERE part_job_id = 2)
                    GROUP BY pers_id;";

        return $this->_db->query($strRq)->fetchAll();
    }

    /**
     * @author Marco
    * Retrieving all professional roles (jobs) held by a specific person
    * @param int $idPerson the identifier of the person
    * @return array a collection of job IDs and names associated with the person
    */

    public function findJobsOfPerson(int $idPerson=0):array{
        $strRq	= " SELECT job_id AS 'pers_id',  job_name AS 'pers_NameJob'
                    FROM jobs
                    WHERE job_id IN (	SELECT part_job_id
                                   	FROM participates
                                   	WHERE part_pers_id = :idPerson
                               	) ";

        $rqPrep = $this->_db->prepare($strRq);
        $rqPrep->bindValue(':idPerson', $idPerson, PDO::PARAM_INT);
        $rqPrep->execute();
        return $rqPrep->fetchAll();
    }

    /**
     * @author Audrey
     * Retrieving the master list of all possible professional roles (Director, Actor, etc.)
     * @return array a collection of all jobs with consistent 'pers_' aliasing
     */

    public function findAllJobs():array{
        $strRq	= " SELECT job_id AS 'pers_id',  job_name AS 'pers_NameJob'
                    FROM jobs";

        return $this->_db->query($strRq)->fetchAll();
    }

    /**
     * @author Audrey
     * Retrieving the master list of all available nationalities
     * @return array a collection of all countries with consistent 'pers_' aliasing
     */

   public function allCountry(): array {

        $strRq	= " SELECT nat_id AS 'pers_id', nat_country AS 'pers_country'
                    FROM nationalities";

        return $this->_db->query($strRq)->fetchAll();
	}

    /**
     * Update an existing person's details in the database
     * @author Audrey
     * @param object $objPerson The Person entity containing the updated information
     * @return bool Returns true if the update was successful, false otherwise
     */
    public function updatePerson(object $objPerson): bool{
        $strRq = "UPDATE persons
                   SET  pers_name = :name, 
                        pers_firstname = :firstname, 
                        pers_birthdate = :birthdate, 
                        pers_nat_id = :nat_id, 
                        pers_photo = :photo,
                        pers_updated_at = NOW()";
        if(!empty($objPerson->getDeathdate())){   
            $strRq .=", pers_deathdate = :deathdate";
        }
                        
               $strRq .=" WHERE pers_id = :id";

        $rqPrep = $this->_db->prepare($strRq);
        $rqPrep->bindValue(':id', $objPerson->getId(), PDO::PARAM_INT);
        $rqPrep->bindValue(':name', $objPerson->getName(), PDO::PARAM_STR);
        $rqPrep->bindValue(':firstname', $objPerson->getFirstname(), PDO::PARAM_STR);
        $rqPrep->bindValue(':birthdate', $objPerson->getBirthdate(), PDO::PARAM_STR);
        if(!empty($objPerson->getDeathdate())){
            $rqPrep->bindValue(':deathdate', $objPerson->getDeathdate(), PDO::PARAM_STR);
        }
        $rqPrep->bindValue(':nat_id', $objPerson->getCountry(), PDO::PARAM_INT);
        $rqPrep->bindValue(':photo', $objPerson->getPhoto(), PDO::PARAM_STR);

        return $rqPrep->execute();
    }
    
    /**
     * Delete a person from the database
     * @author Audrey
     * @param int $intId The unique identifier of the person to be deleted
     * @return bool Returns true if the deletion was successful
     */

    public function deletePerson(int $intId): bool{
        $strRq = "DELETE FROM persons
                    WHERE pers_id = :id";

        $rqPrep = $this->_db->prepare($strRq);
        $rqPrep->bindValue(':id', $intId, PDO::PARAM_INT);

        return $rqPrep->execute();
    }

    /**
     * @author Audrey
     * Retrieves a list of persons based on search criteria, job filters, and sorting.
     * * This method builds a dynamic SQL query to find people by their full name,
     * filters them by a specific role (actor, producer, or director), 
     * and sorts the results alphabetically.
     * * @param string|null $strSearch The name or partial name to search for.
     * @param string $strFilter The job category filter (actor, producer, or realisator).
     * @param string $strSort The sorting direction ('asc' or 'desc').
     * @return array The list of persons matching the criteria.
     */
    public function findPersonWithFilters(?string $strSearch, string $strFilter, string $strSort): array {

        $strRq = "SELECT pers_id, pers_firstname, pers_name, job_name AS pers_job
                    FROM persons 
                    INNER JOIN participates ON participates.part_pers_id = persons.pers_id
                    INNER JOIN jobs ON participates.part_job_id = jobs.job_id
                    WHERE 1 = 1";
                    

        $params = [];

        if (!empty($strSearch)) {

            $strRq .= " AND CONCAT(pers_firstname, ' ', pers_name) LIKE :search";

            $params[':search'] = "%" . $strSearch . "%";
        }			

        switch($strFilter) {
            case 'actor':
                $strRq .= " AND jobs.job_id = 3";
                break;
            case 'producer':
                $strRq .= " AND jobs.job_id = 2";
                break;
            case 'realisator':
                $strRq .= " AND jobs.job_id = 1";
                break;				
            default:
                break;
        }
        $strRq .= " GROUP BY pers_id ";

        if ($strSort === 'desc') {
                $strRq .= " ORDER BY CONCAT(pers_firstname,' ' ,pers_name) DESC";
            } else {
                $strRq .= " ORDER BY CONCAT(pers_firstname,' ' ,pers_name) ASC";
        }
    

        $prep = $this->_db->prepare($strRq);

        foreach($params as $key => $val) {
            $prep->bindValue($key, $val, PDO::PARAM_STR);
        }

        $prep->execute();

        return $prep->fetchAll();
    }

}

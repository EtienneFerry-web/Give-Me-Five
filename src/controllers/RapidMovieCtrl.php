<?php
namespace App\Controllers;

use App\Models\RapidMovieModel;

/**
 * Controller for managing movie retrieval and display via Streaming Availability API.
 * This class translates user requests and passes data to the view.
 */
class RapidMovieCtrl extends MotherCtrl {

    /**
     * Search action to retrieve movies from the API and display them in the template.
     * Accessible via index.php?ctrl=rapidMovie&action=search
     */
    public function search() {
        // Instantiate the model
        $objModel = new RapidMovieModel();

        // Movie title to search for (default: "batman")
        $titleToSearch = $_GET['title'] ?? 'batman';

        // Call the search method
        $arrData = $objModel->searchMovieByTitle($titleToSearch);

        // Assign data to the parent data array for the view
        if (isset($arrData['error'])) {
            $this->_arrData['arrError'] = [$arrData['error']];
            $this->_arrData['arrResult'] = [];
        } else {
            // Streaming Availability API result is typically an array 'result'
            $this->_arrData['arrResult'] = $arrData['result'] ?? [];
            $this->_arrData['arrError'] = [];
        }

        $this->_arrData['searchedTitle'] = $titleToSearch;

        // Display results using the Smarty template engine
        $this->_display("rapidMoviesList");
    }
}

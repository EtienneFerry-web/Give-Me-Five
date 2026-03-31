<?php
namespace App\Models;

/**
 * Expert Model for Streaming Availability API (RapidAPI)
 * Handles data fetching and transformation for the Movie catalog.
 */
class RapidMovieModel extends Connect
{
    private string $apiKey = "8dd034362fmshc6eb8fd49364ca9p1ddb2bjsn055c4f0928f2";
    private string $host = "streaming-availability.p.rapidapi.com";

    /**
     * Executes a clean cURL request to the API.
     */
    private function callApi(string $endpoint, array $params = []): array
    {
        $queryString = http_build_query($params);
        $url = "https://{$this->host}/{$endpoint}?{$queryString}";

        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_SSL_VERIFYPEER => false, // Bypass SSL for local dev (MAMP)
            CURLOPT_HTTPHEADER => [
                "X-RapidAPI-Host: {$this->host}",
                "X-RapidAPI-Key: {$this->apiKey}",
                "Content-Type: application/json"
            ],
            CURLOPT_TIMEOUT => 20
        ]);

        $response = curl_exec($curl);
        $err = curl_error($curl);
        curl_close($curl);

        if ($err) {
            error_log("RapidMovieModel API cURL Error: " . $err);
            return ["error" => $err];
        }

        $decoded = json_decode($response, true);
        
        // Log the response for debugging (remove this once fixed)
        error_log("RapidMovieModel API Response: " . substr($response, 0, 500));

        return $decoded ?: [];
    }

    /**
     * Maps an API show object to the local MovieEntity structure.
     */
    private function mapToShow(array $item): array
    {
        return [
            'mov_id'          => $item['id'] ?? '',
            'mov_title'       => $item['title'] ?? '',
            'mov_description' => $item['overview'] ?? '',
            'mov_photo'       => $item['imageSet']['verticalPoster']['w480'] ?? $item['imageSet']['verticalPoster']['w240'] ?? '',
            'mov_rating'      => (float)(($item['rating'] ?? 0) / 10),
            'mov_release_date'=> $item['releaseYear'] ?? '',
            'mov_trailer_url' => $item['youtubeTrailerVideoId'] ?? '',
            'mov_like'        => 0,
            'is_api'          => true
        ];
    }

    /**
     * Fetch trending/new movies.
     */
    public function newMovie(): array
    {
        $data = $this->callApi("shows/search/filters", [
            "country"         => "fr",
            "show_type"       => "movie",
            "order_by"        => "popularity_alltime",
            "desc"            => "true",
            "year_min"        => date("Y") - 2,
            "output_language" => "fr"
        ]);

        $results = $data['shows'] ?? $data['result'] ?? [];
        return array_map([$this, 'mapToShow'], $results);
    }

    /**
     * Search movies by title.
     */
    public function searchMovieByTitle(string $title): array
    {
        $data = $this->callApi("shows/search/title", [
            "country" => "fr",
            "title" => $title,
            "show_type" => "movie",
            "output_language" => "fr"
        ]);

        $results = $data['result'] ?? $data['shows'] ?? $data; // search/title sometimes returns the array directly
        if (isset($results['id'])) return [$this->mapToShow($results)]; // Single result check

        return is_array($results) ? array_map([$this, 'mapToShow'], array_filter($results, 'is_array')) : [];
    }

    /**
     * Get a single movie by ID.
     */
    public function getMovieById(string $id): array|bool
    {
        $data = $this->callApi("shows/{$id}", ["output_language" => "fr"]);
        
        if (isset($data['id'])) {
            return $this->mapToShow($data);
        }
        return false;
    }
}

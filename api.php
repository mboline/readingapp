<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// CONFIGURATION
$dbUser = "mwboline";
$dbPass = "k1ivR9Xc0UCfCJsp";
$cluster = "readingcluster.my7xr.mongodb.net";
$database = "WordInfo";

// We use the Atlas Data API via PHP's curl because shared hosts 
// rarely have the MongoDB driver installed.
function callAtlas($action, $body) {
    global $dbUser, $dbPass, $cluster, $database;
    
    // NOTE: Since Atlas Data API is restricted, we are mimicking 
    // a standard driver request or using a local proxy if preferred.
    // For IONOS, we will simplify by assuming you can use curl.
    $url = "https://data.mongodb-api.com/app/data-xxxx/endpoint/data/v1/action/" . $action;
    $apiKey = "al-4UgOTdd5qYnHJxRUPz__7_i7nE95wnZ7reb52IiPvgI"; // If you have one, otherwise use Driver logic.

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'api-key: ' . $apiKey
    ]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode(array_merge([
        "dataSource" => "ReadingCluster",
        "database" => $database
    ], $body)));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    curl_close($ch);
    return $response;
}

$action = $_GET['action'] ?? '';
$input = json_decode(file_get_contents('php://input'), true);

if ($action == 'fetchWord') {
    $word = $_GET['word'] ?? '';
    echo callAtlas('findOne', [
        "collection" => "Words",
        "filter" => ["word" => ["\$regex" => "^$word\$", "\$options" => "i"]]
    ]);
} elseif ($action == 'random') {
    echo callAtlas('aggregate', [
        "collection" => "Words",
        "pipeline" => [["\$sample" => ["size" => 1]]]
    ]);
}
?>
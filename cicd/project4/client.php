<?php
/******************************************************************************!
 * \file client.php
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
******************************************************************************/
if (PHP_SAPI === 'cli') {
    parse_str(implode('&', array_slice($argv, 1)), $_GET);
}
$url = $_GET['url'];
$method = $_GET['method'];

$data = array(
    "jsonrpc" => "2.0",
    "method" => $method,
    );
if ($method != "quit") {
    $data["id"] = 1;
}

$options = array(
    'http' => array(
        'method' => 'POST',
        'content' => json_encode($data),
        'header' => "Content-Type: application/json\r\n",
        ),
    );
$context = stream_context_create($options);

if ($method == "quit") {
    $result = @file_get_contents($url, false, $context);
} else {
    $result = file_get_contents($url, false, $context);
}

if ($result != null) {
    $json = json_decode($result);
    if (isset($json->error)) {
        print('error: '.$json->error->message."\n");
    } else {
        print($json->result."\n");
    }
}
?>

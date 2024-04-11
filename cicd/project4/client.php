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
$server = $_GET['server'];
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
    $result = @file_get_contents($server, false, $context);
} else {
    $result = file_get_contents($server, false, $context);
}

if ($result != null) {
    $json = json_decode($result);
    if (isset($json->error)) {
        print('error: '.$json->error->message."\n");
    } else if (is_string($json->result)) {
        print($json->result."\n");
    } else {
        print_r($json->result);
    }
}
?>

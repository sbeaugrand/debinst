<?php
/******************************************************************************!
 * \file client.php
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
******************************************************************************/
if (PHP_SAPI === 'cli') {
    parse_str(implode('&', array_slice($argv, 1)), $_GET);
    $server = $_GET['server'];
    $method = $_GET['method'];
} else {
    $server = 'http://localhost:8383';
    if (! empty($_GET['method'])) {
        $method = $_GET['method'];
    } else {
        $method = 'info';
    }
}

print '<html><head></head><body>';
print '<a href="?method=info">info</a><br/>';
print '<a href="?method=rand">rand</a><br/>';
print '<a href="?method=ok">ok</a><br/>';
print '<a href="?method=list">list</a><br/>';
print '<a href="?method=play">play</a><br/>';
print '<a href="?method=pause">pause</a><br/>';
print '<a href="?method=next">next</a><br/>';
print '<a href="?method=prev">prev</a><br/>';
print '<a href="?method=dir&path=">dir</a><br/>';

$data = array(
    "jsonrpc" => "2.0",
    "method" => $method,
    );
if ($method != "quit") {
    $data["id"] = 1;
}
/*  */ if ($method == "pos") {
    $data["params"] = array("pos" => intval($_GET['pos']));
} else if ($method == "dir") {
    $data["params"] = array("path" => $_GET['path']);
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
        //print_r($json->result);
        if ($method == 'list') {
            print('<br/>');
            $pos = $json->result->pos + 1;
            $count = 0;
            foreach ($json->result->song as $s) {
                $count++;
                if ($count < 10) {
                    $line = '0';
                } else {
                    $line = '';
                }
                $line = $line.$count.' - '.$s->title;
                if ($count == $pos) {
                    print $line.'<br/>';
                } else {
                    print '<a href="?method=pos&pos='.($count - 1).'">'.
                        $line.'</a><br/>';
                }
            }
        } else if ($method == 'dir') {
            print('<br/>');
            foreach ($json->result->dir as $d) {
                print '<a href="?method=dir&path='.
                    urlencode($d).'">'.$d.'</a><br/>';
            }
        } else {
            print("<pre>");
            print(json_encode($json->result, JSON_PRETTY_PRINT));
            print("</pre>");
        }
    }
}

print '</body></html>';
?>

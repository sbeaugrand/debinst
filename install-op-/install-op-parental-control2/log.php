<?php
if (isset($_POST['t'])) {
    header('Access-Control-Allow-Origin: *');
    if ($_SERVER['REQUEST_METHOD'] != 'OPTIONS') {
        date_default_timezone_set('Europe/Paris');
        file_put_contents('/tmp/ctpar.log',
                          date('H:i:s ').$_SERVER['REMOTE_ADDR'].' '.
                          $_POST['t']."\n", FILE_APPEND);
    }
} else {
    print '<!DOCTYPE html><html><head></head><body><code>';
    $lines = file('/tmp/ctpar.log');
    foreach ($lines as $line) {
        print htmlspecialchars($line)."<br/>\n";
    }
    print '</code></body></html>';
}
?>

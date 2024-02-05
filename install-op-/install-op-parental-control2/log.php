<?php
if (isset($_POST['t'])) {
    header('Access-Control-Allow-Origin: *');
    if ($_SERVER['REQUEST_METHOD'] != 'OPTIONS') {
        date_default_timezone_set('Europe/Paris');
        $log = $_SERVER['REMOTE_ADDR'].' '.$_POST['t'];
        file_put_contents('/tmp/ctpar.log',
                          date('H:i:s ').$log.$_POST['t']."\n", FILE_APPEND);
        shell_exec('systemd-cat -t ctpar echo '.$log);
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

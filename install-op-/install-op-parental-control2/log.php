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
    if (file_exists('users.php')) {
        include_once('users.php');
    }
    print '<!DOCTYPE html><html><head></head><body><pre><code>';
    $lines = file('/tmp/ctpar.log');
    foreach ($lines as $line) {
        foreach ($users as $ip => $user) {
            $line = str_replace($ip, $user, $line);
        }
        print htmlspecialchars($line);
    }
    print '</pre></code></body></html>';
}
?>

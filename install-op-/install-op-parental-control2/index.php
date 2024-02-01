<html>
<head>
</head>
<body>
<code>
<?php
    $lines = file('/tmp/ctpar.log');
    foreach ($lines as $line) {
        print htmlspecialchars($line)."<br/>\n";
    }
?>
</code>
</body>
</html>

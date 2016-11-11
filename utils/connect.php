<?php
/*
 * A simple test script, useful for debugging connections in the absence of the `mysql`
 * console client.
 */

$dsn = 'mysql:dbname=piwik;host=localhost';
$user = 'piwik';
$password = 'password';

try {
    $dbh = new PDO($dsn, $user, $password);
} catch (PDOException $e) {
    echo 'Connection failed: ' . $e->getMessage();
}

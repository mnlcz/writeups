<?php

/*
CREATE TABLE `users` (
  `username` varchar(64) DEFAULT NULL,
  `password` varchar(64) DEFAULT NULL
);
*/

$link = mysqli_connect('localhost', 'natas15', '<censored>');
mysqli_select_db($link, 'natas15');
$query = "SELECT * from users where username=\"".$_REQUEST["username"]."\"";

if(array_key_exists("debug", $_GET)) {
    echo "Executing query: $query<br>";
}

$res = mysqli_query($link, $query);
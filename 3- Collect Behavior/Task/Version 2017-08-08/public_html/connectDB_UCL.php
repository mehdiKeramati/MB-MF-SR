<?php


$database="ucjtuhe";


$host="mysql-server.ucl.ac.uk";
$user="ucjtuhe";
$password="turhturh";
$db = new mysqli($host, $user, $password, $database);

if (mysqli_connect_errno()) {
   printf("DB error: %s", mysqli_connect_error());
   exit();
}
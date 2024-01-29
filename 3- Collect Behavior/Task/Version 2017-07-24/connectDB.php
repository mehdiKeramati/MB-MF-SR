<?php


$database="experiment1";
$host="localhost";

//Uri's setting 
$user="wampuser";
$password="turhturh";

//nareg's setting
//$user="nareg";
//$password="password";


$db = new mysqli($host, $user, $password, $database);

if (mysqli_connect_errno()) {
   printf("DB error: %s", mysqli_connect_error());
   exit();
}
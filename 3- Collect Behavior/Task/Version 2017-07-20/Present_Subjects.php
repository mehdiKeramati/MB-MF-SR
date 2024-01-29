<?php

$host="mysql-server.ucl.ac.uk";
$uname="ucjtuhe";
$pass="turhturh";
$database = "ucjtuhe";

//$database="experiment1";
//$host="localhost";
//$uname="wampuser";
//$pass="turhturh";

$connection=mysql_connect($host,$uname,$pass); 

echo mysql_error();

//or die("Database Connection Failed");
$selectdb=mysql_select_db($database) or 
die("Database could not be selected"); 

 //$data = mysql_query("SELECT ID,time FROM advice2data WHERE TrialNum=240") 
 $data = mysql_query("SELECT * FROM judge_finished") 
 or die(mysql_error()); 
 Print "<table border cellpadding=3>"; 
 while($info = mysql_fetch_array( $data )) 
 { 
 Print "<tr>Judge Experiment"; 
 Print "<th>ID:</th> <td>".$info['ID'] . "</td> "; 
 Print "<th>Time:</th> <td>".$info['time'] . " </td>";

 Print " <td><a href=Export_Table.php?SubCode=".$info['ID'] .">Export</a>  </td>"       . "</tr>"; 

 
 
 } 
 Print "</table>"; 


mysql_close($connection);


?>
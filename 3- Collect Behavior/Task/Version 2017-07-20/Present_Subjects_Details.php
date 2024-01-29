<?php


$host="mysql-server.ucl.ac.uk";
$uname="ucjtuhe";
$pass="turhturh";
$database = "ucjtuhe";

$connection=mysql_connect($host,$uname,$pass); 

echo mysql_error();

//or die("Database Connection Failed");
$selectdb=mysql_select_db($database) or 
die("Database could not be selected"); 
$out=mysql_select_db($database)
or die("database cannot be selected <br>");



$result = mysql_query("SELECT  ID,Age,Education,Gender,Time FROM judge_subjects");


$pasajeros = '';

if ($result) {
    while ($row = mysql_fetch_array($result)) {
        if ($row["Gender"]=='m'){
            $ThisGender =1;
        }else{
          $ThisGender =2;  
        }
        $ThisEdu=1;
        if (strcmp($row["Education"], 'High') == 0){
          $ThisEdu=2;  
        }
        if (strcmp($row["Education"], 'college') == 0){
          $ThisEdu=3;  
        }
        if (strcmp($row["Education"], 'post') == 0){
          $ThisEdu=4;  
        }
        $pasajeros .= $row["ID"] . ",".$row["Age"] .",".$ThisEdu . ",". $ThisGender. ",". $row["Time"] ."\r\n"; //note the comma here
    }
}
$filename = "pasajeros_" . date("Y-m-d_H-i"); 
header("Content-type: application/vnd.ms-excel");
header("Content-disposition: csv" . date("Y-m-d") . ".csv");
header("Content-disposition: filename=Advice2SubjectsDetails.csv");
mysql_close($connection);
echo $pasajeros;
exit();
?>
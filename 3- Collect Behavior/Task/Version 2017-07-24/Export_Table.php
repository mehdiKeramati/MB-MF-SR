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
$out=mysql_select_db($database)
or die("database cannot be selected <br>");



$Subject = $_GET['SubCode'];
$result = mysql_query("SELECT  Condition1,TrialNum,Time,RT,BW_Degree,Top,ThisResponse,Advice1,Advice2,CoinLocation,ThisReward,SumReward FROM judge_data WHERE ID= $Subject ");

$pasajeros = '';

if ($result) {
    while ($row = mysql_fetch_array($result)) {
               // $pasajeros .=$row["TrialNum"]."\r\n"; //note the comma here

        $pasajeros .=  $row["Condition1"] . ",".$row["TrialNum"] . ",".$row["Time"]. ",". $row["RT"]. ",". $row["BW_Degree"] . ",".$row["Top"] . ",".$row["ThisResponse"] . ",".$row["Advice1"] . ",".$row["Advice2"] . ",".$row["CoinLocation"] .",".$row["ThisReward"] .",".$row["SumReward"]."\r\n"; //note the comma here
    }
}
$filename = "pasajeros_" . date("Y-m-d_H-i"); 
header("Content-type: application/vnd.ms-excel");
header("Content-disposition: csv" . date("Y-m-d") . ".csv");
header("Content-disposition: filename=JudgeExp-" . $Subject . ".csv");
mysql_close($connection);
echo $pasajeros;
exit();
?>
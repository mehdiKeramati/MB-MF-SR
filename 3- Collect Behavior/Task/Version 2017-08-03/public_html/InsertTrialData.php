<?php

include 'connectDB.php';
           
$ID 				= stripslashes(htmlspecialchars($_POST['ID']));
$Condition			= stripslashes(htmlspecialchars($_POST['Condition']));
$TrialNum 			= stripslashes(htmlspecialchars($_POST['TrialNum']));
$Time 				= stripslashes(htmlspecialchars($_POST['Time']));
$RT		 			= stripslashes(htmlspecialchars($_POST['RT']));
$BW_Degree			= stripslashes(htmlspecialchars($_POST['BW_Degree']));
$Top	= stripslashes(htmlspecialchars($_POST['Top']));
$ThisResponse		= stripslashes(htmlspecialchars($_POST['ThisResponse']));
$Advice1			= stripslashes(htmlspecialchars($_POST['Advice1']));
$Advice2			= stripslashes(htmlspecialchars($_POST['Advice2']));
$CoinLocation		= stripslashes(htmlspecialchars($_POST['CoinLocation']));
$ThisReward			= stripslashes(htmlspecialchars($_POST['ThisReward']));
$SumReward			= stripslashes(htmlspecialchars($_POST['SumReward']));
$T					= stripslashes(htmlspecialchars($_POST['T']));


$stmt = $db->prepare("INSERT INTO judge_data VALUE(?,?,?,?,?,?,?,?,?,?,?,?,?)");

$stmt->bind_param("siiddiiiiiiii", $ID,$Condition,$TrialNum,$Time,$RT,$BW_Degree,$Top,$ThisResponse,$Advice1,$Advice2,$CoinLocation,$ThisReward,$SumReward);



$stmt->execute();
$err = $stmt->errno ;
$data[] = array(
      'ErrorNo' => $err,
    );
$stmt->close();
 $db->close();
echo json_encode($data);
 ?>

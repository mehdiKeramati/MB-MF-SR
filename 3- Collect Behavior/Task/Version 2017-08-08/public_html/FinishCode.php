<?php


include 'connectDB.php';
$ID = stripslashes(htmlspecialchars($_POST['SubID']));
$StartTime= stripslashes(htmlspecialchars($_POST['AllTime']));



$stmt = $db->prepare("INSERT INTO judge_finished VALUE(?,NOW(),?)");
$stmt->bind_param("sd", $ID,$StartTime );
$stmt->execute();
$err = $stmt->errno ;
$data[] = array(
      'ErrorNo' => $err,
    );
$stmt->close();
 $db->close();
echo json_encode($data);
 ?>

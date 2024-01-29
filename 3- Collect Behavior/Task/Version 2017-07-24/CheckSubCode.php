<?php


include 'connectDB.php';


$SUBCODE = stripslashes(htmlspecialchars($_POST['thisCode']));
$ID = stripslashes(htmlspecialchars($_POST['ID']));



$stmt = $db->prepare("SELECT subcode FROM  judge_subcode WHERE subcode = ?");
 $stmt->bind_param("s", $SUBCODE);
$stmt->execute();


if ($stmt->num_rows === 0) {
$stmt->close();
$stmt2 = $db->prepare("INSERT INTO judge_subcode VALUE(?,NOW(),?)");
$stmt2->bind_param("ss", $SUBCODE,$ID);
$stmt2->execute();
$err = $stmt2->errno ;
$data[] = array(
      'ErrorNo' => $err,
    );
$stmt2->close();
 $db->close();
echo json_encode($data);
    exit;
}else {
 $stmt->close();
 $db->close();
    $data[] = array(
      'ErrorNo' => 8,
    ); 

   echo json_encode($data);
   
     };
 ?>
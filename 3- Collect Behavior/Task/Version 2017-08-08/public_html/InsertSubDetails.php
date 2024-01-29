<?php


include 'connectDB.php';
$ID = stripslashes(htmlspecialchars($_POST['id']));
$AGE = stripslashes(htmlspecialchars($_POST['age']));
$EDU = stripslashes(htmlspecialchars($_POST['education']));
$GEN = stripslashes(htmlspecialchars($_POST['gender']));

$stmt = $db->prepare("INSERT INTO judge_subjects VALUE(?,?,?,?,NOW())");
$stmt->bind_param("siss", $ID,$AGE,$EDU,$GEN );
$stmt->execute();
$err = $stmt->errno ;
$data[] = array(
      'ErrorNo' => $err,
    );
$stmt->close();
 $db->close();
echo json_encode($data);
 ?>

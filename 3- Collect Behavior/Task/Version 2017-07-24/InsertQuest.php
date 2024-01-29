<?php


include 'connectDB.php';
           
$ID = stripslashes(htmlspecialchars($_POST['ID']));
$Q1Q01 = stripslashes(htmlspecialchars($_POST['Q1Q01']));
$Q1Q02 = stripslashes(htmlspecialchars($_POST['Q1Q02']));
$Q1Q03 = stripslashes(htmlspecialchars($_POST['Q1Q03']));
$Q1Q04 = stripslashes(htmlspecialchars($_POST['Q1Q04']));
$Q1Q05 = stripslashes(htmlspecialchars($_POST['Q1Q05']));
$Q1Q06 = stripslashes(htmlspecialchars($_POST['Q1Q06']));
$Q1Q07 = stripslashes(htmlspecialchars($_POST['Q1Q07']));
$Q1Q08 = stripslashes(htmlspecialchars($_POST['Q1Q08']));
$Q1Q09 = stripslashes(htmlspecialchars($_POST['Q1Q09']));
$Q1Q10 = stripslashes(htmlspecialchars($_POST['Q1Q10']));
$Q1Q11 = stripslashes(htmlspecialchars($_POST['Q1Q11']));
$Q1Q12 = stripslashes(htmlspecialchars($_POST['Q1Q12']));

$Q2Q01 = stripslashes(htmlspecialchars($_POST['Q2Q01']));
$Q2Q02 = stripslashes(htmlspecialchars($_POST['Q2Q02']));
$Q2Q03 = stripslashes(htmlspecialchars($_POST['Q2Q03']));
$Q2Q04 = stripslashes(htmlspecialchars($_POST['Q2Q04']));
$Q2Q05 = stripslashes(htmlspecialchars($_POST['Q2Q05']));
$Q2Q06 = stripslashes(htmlspecialchars($_POST['Q2Q06']));
$Q2Q07 = stripslashes(htmlspecialchars($_POST['Q2Q07']));
$Q2Q08 = stripslashes(htmlspecialchars($_POST['Q2Q08']));
$Q2Q09 = stripslashes(htmlspecialchars($_POST['Q2Q09']));
$Q2Q10 = stripslashes(htmlspecialchars($_POST['Q2Q10']));
$Q2Q11 = stripslashes(htmlspecialchars($_POST['Q2Q11']));



$stmt = $db->prepare("INSERT INTO judge_quest VALUE(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

$stmt->bind_param("ssssssssssssssssssssssss", $ID,$Q1Q01,$Q1Q02,$Q1Q03,$Q1Q04,$Q1Q05,$Q1Q06,$Q1Q07,$Q1Q08,$Q1Q09,$Q1Q10,$Q1Q11,$Q1Q12,$Q2Q01,$Q2Q02,$Q2Q03,$Q2Q04,$Q2Q05,$Q2Q06,$Q2Q07,$Q2Q08,$Q2Q09,$Q2Q10,$Q2Q11);
$stmt->execute();
$err = $stmt->errno ;
$data[] = array(
      'ErrorNo' => $err,
    );
$stmt->close();
 $db->close();
echo json_encode($data);
 ?>

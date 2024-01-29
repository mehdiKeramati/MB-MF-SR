<?php
require_once '../lib/swift_required.php';
$to = $_POST['email'];
$to=filter_var($to, FILTER_SANITIZE_EMAIL);
  // Validate e-mail address
  if(filter_var($to, FILTER_VALIDATE_EMAIL)){
//$content = $_POST['content'];
//$subject = $_POST['subject'];
//$from = $_POST['from'];
 
$pEmailGmail = 'crowdcognition@gmail.com';
$pPasswordGmail = 'icn@ERC13';
$pFromMail = 'u.hertz@ucl.ac.uk';
$pFromName = 'Uri Hertz'; //display name

$pTo = $to; //destination email
$pSubjetc = $_POST['subject']; //the subjetc 
$pBody = $_POST['content']; //body html

$transport = Swift_SmtpTransport::newInstance('tls://smtp.gmail.com', 465)
            ->setUsername($pEmailGmail)
            ->setPassword($pPasswordGmail);

$mMailer = Swift_Mailer::newInstance($transport);

$mEmail = Swift_Message::newInstance();
$mEmail->setSubject($pSubjetc);
$mEmail->setTo($pTo);
$mEmail->setFrom(array($pFromMail => $pFromName));
$mEmail->setBody($pBody, 'text/html'); //body html

if($mMailer->send($mEmail) == 1){
    echo 'Email was Sent.';
}
else {
    echo 'send error.';
}


  }
  
 



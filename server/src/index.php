<?php

require_once(dirname(__FILE__) .'/KLogger.php');

function getServer($key = null, $default = null)
{
    if (null === $key) {
        return $_SERVER;
    }

    return (isset($_SERVER[$key])) ? $_SERVER[$key] : $default;
}

function getClientIp($checkProxy = true)
{
    if ($checkProxy && getServer('HTTP_CLIENT_IP') != null) {
        $ip = getServer('HTTP_CLIENT_IP');
    } else if ($checkProxy && getServer('HTTP_X_FORWARDED_FOR') != null) {
        $ip = getServer('HTTP_X_FORWARDED_FOR');
    } else {
        $ip = getServer('REMOTE_ADDR');
    }
    return $ip;
}

//set logger parameter
date_default_timezone_set('America/Los_Angeles');

$log = new KLogger( "/tmp/sneeze" , KLogger::DEBUG );

$username="root";
$password="";
$database="test2";

$power=$_POST['power'];
$ip=getClientIp();
$date=$_POST['date'];
$user=$_POST['user'];

$log->logInfo('Result from user=' . $user . ' power=' . $power . ' ip=' . $ip);

mysql_connect('localhost', $username, $password);
@mysql_select_db($database) or die( "Unable to select database");

$query = sprintf("SELECT minpower FROM users WHERE user='%s'",
    mysql_real_escape_string($user));
$result = mysql_query($query);

if (!$result) {
    $log->logError('New user=' . $user);
    $minpower = 0;
} else {
    $rdict = mysql_fetch_assoc($result);
    $minpower = $rdict['minpower'];
}

if ($power > $minpower) {
    $logstr = '  Threshold reached, so recording this result (' . $user . ',' . $power . ')';
    $log->logInfo($logstr);
	$query = "INSERT INTO recording VALUES ('','$power','$ip','$date','$user')";
	$result = mysql_query($query);
}
    
mysql_close();
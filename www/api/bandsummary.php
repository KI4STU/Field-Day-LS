<?php
# collect summary stats by band from sql server for display

$ret = array();
$ret['data'] = array();

# connect to mysql server, database
$fdls = new mysqli("127.0.0.1", "phpmyadmin", "fieldday", "FDLS");
if ($fdls->connect_errno) {
        echo "Failed to connect to MySQL: (" . $mysqli->connect_errono . ") " . $mysqli->connect_error;
}

$entry = array();

$modes = array(CW, PHONE, DIGITAL);
#$bands = array("160M", "80M", "40M", "20M", "15M", "10M", "6M", "2M", "1.25M", "70CM", "33CM", "23CM", "Sat");
$bands = array("Sat", "23CM", "33CM", "70CM", "1.25M", "2M", "6M", "10M", "15M", "20M", "40M", "80M", "160M");
$jj = 1;

# get number of contacts by band & mode
foreach ($bands as &$bvalue) {
	$entry = array();
	array_push($entry, $jj);
	array_push($entry, $bvalue);
	$jj++;
	foreach ($modes as &$mvalue) {
		if ($result = $fdls->query("SELECT * FROM log WHERE mode = \"$mvalue\" and band = \"$bvalue\"")) {
			$ii = $result->num_rows;
			array_push($entry, $ii);
		}
	}
	array_push($ret['data'], $entry);
}
/*
*/


echo json_encode($ret);

?>

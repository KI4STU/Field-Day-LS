<?php
# collect summary stats from sql server for display

$ret = array();
$ret['summary'] = array();

# connect to mysql server, database
$fdls = new mysqli("127.0.0.1", "phpmyadmin", "fieldday", "FDLS");
if ($fdls->connect_errno) {
        echo "Failed to connect to MySQL: (" . $mysqli->connect_errono . ") " . $mysqli->connect_error;
}

$entry = array();

$modes = array(CW, PHONE, DIGITAL);

foreach ($modes as &$value) {

	if ($result = $fdls->query("SELECT * FROM log WHERE mode = \"$value\"")) {
	$$value = $result->num_rows;
	array_push($ret['summary'], $value.": ".$$value);
	}
}


echo json_encode($ret);

?>

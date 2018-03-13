<html>
	<head>
		<title>FDLS Statistics</title>
		<link rel="stylesheet" type="text/css" href="styles.css">
	</head>
	<body>
<?php

include (config.php);

$fdls = new mysqli("127.0.0.1", "root", "fieldday", "FDLS");
if ($fdls->connect_errno) {
	echo "Failed to connect to MySQL: (" . $mysqli->connect_errono . ") " . $mysqli->connect_error;
}	
#echo $fdls->host_info . "\n";

# get and display total number of contacts
if ($result = $fdls->query("SELECT * FROM log")) {
$numcontacts = $result->num_rows;

	print"<div>\n";
	print"Number of contacts: ". $numcontacts ."\n";
	print"</div>\n";
}

# get and dispaly number of contacts by mode
$modes = array(PHONE, CW, DIGITAL);

foreach ($modes as &$value) {

	if ($result = $fdls->query("SELECT * FROM log WHERE mode = \"$value\"")) {
	$$value = $result->num_rows;
	$pct = round($$value/$numcontacts*100, 1);

	print"<div>\n";
	print"Number of $value contacts: ". $$value ." ($pct%)\n";
	print"</div>\n";
	}
}

# get and display number of sections logged
if ($result = $fdls->query("SELECT DISTINCT section FROM log")) {
$sections = $result->num_rows;

	print"<div>\n";
	print"Number of sections: ". $sections ." out of 83 possible.\n";
	print"</div>\n";
}

# score calculation
$score = $PHONE+$CW*2+$DIGITAL*2;

switch ($rfpower) {
	case 5:
		if ($battery) {
			$score=$score*5;
		}
		else {
			$score=$score*2;
		}
		break;
	case 150:
		$score=$score*2;
		break;
}

	print"<div>\n";
	print"Current score (excludes bonus points): $score \n";
	print"</div>\n";


?>
	</body>

</html>

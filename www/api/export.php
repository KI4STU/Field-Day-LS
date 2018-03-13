<?php
# export log data in CSV format
# originally from https://bitbucket.org/pignology/hlfds
# modified by Detrick Merz (K4IZ) to function with FDLS (https://github.com/KI4STU/Field-Day-LS)

header("Content-type: text/csv");
header("Content-Disposition: attachment; filename=hlfds_contacts.csv");
header("Pragma: no-cache");
header("Expires: 0");

$ret = array();
$ret['data'] = array();

# connect to mysql server, database
$fdls = new mysqli("127.0.0.1", "root", "fieldday", "FDLS");
if ($fdls->connect_errno) {
        echo "Failed to connect to MySQL: (" . $mysqli->connect_errono . ") " . $mysqli->connect_error;
}

# get sql query results
$results = $fdls->query('SELECT * FROM logentries');

# create headers at top of CSV file
echo "Date,Band,Mode,Callsign,Class,Section,Operator\n";

# populate CSV file with data from database
while ($row = $results->fetchArray()) {
  $entry = array();
  $epoch = $row['epoch'];
  $dt = new DateTime("@$epoch");  

  echo $dt->format('Y-m-d H:i:s') . " UTC,";
  echo $row['band'] . ",";
  echo $row['mode'] . ",";
  echo $row['callsign'] . ",";
  echo $row['class'] . ",";
  echo $row['section'] . ",";
  echo $row['op'] . "\n";
}
?>

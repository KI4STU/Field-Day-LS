<?php
# collect log data from sql server for display
# originally from https://bitbucket.org/pignology/hlfds
# modified by Detrick Merz (K4IZ) to function with FDLS (https://github.com/KI4STU/Field-Day-LS)

$ret = array();
$ret['data'] = array();

# connect to mysql server, database
$fdls = new mysqli("127.0.0.1", "phpmyadmin", "fieldday", "FDLS");
if ($fdls->connect_errno) {
        echo "Failed to connect to MySQL: (" . $mysqli->connect_errono . ") " . $mysqli->connect_error;
}

# get results from sql query
$results = $fdls->query('SELECT * FROM log');

# put results in an array
while ($row = $results->fetch_array()) {
  $entry = array();
  $epoch = $row['epoch'];
  $dt = new DateTime("@$epoch");  
  array_push($entry, $dt->format('Y-m-d H:i:s'));
  array_push($entry, $row['band']);
  array_push($entry, $row['mode']);
  array_push($entry, $row['callsign']);
  array_push($entry, $row['class']);
  array_push($entry, $row['section']);
  array_push($entry, $row['op']);
  array_push($ret['data'], $entry);
}
echo json_encode($ret);
?>

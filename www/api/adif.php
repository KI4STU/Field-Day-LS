<?php
# export log data in ADIF format
# originally from https://bitbucket.org/pignology/hlfds
# modified by Detrick Merz (K4IZ) to function with FDLS (https://github.com/KI4STU/Field-Day-LS)

header("Content-type: text/plain");
header("Content-Disposition: attachment; filename=FDcontacts.adif");
header("Pragma: no-cache");
header("Expires: 0");

$ret = array();
$ret['data'] = array();

# connect to mysql server, database
$fdls = new mysqli("127.0.0.1", "phpmyadmin", "fieldday", "FDLS");
if ($fdls->connect_errno) {
        echo "Failed to connect to MySQL: (" . $mysqli->connect_errono . ") " . $mysqli->connect_error;
}

# get sql query results
$results = $fdls->query('SELECT * FROM log');

# create headers at top of CSV file
$dt = new DateTime("NOW");  
echo $dt->format('Y-m-d H:i:s') . " GMT+00:00<ProgramID:4>FDLS<eoh>\n";
#echo "GMT+00:00<ProgramID:4>FDLS<eoh>\n";

# populate CSV file with data from database
while ($row = $results->fetch_array()) {
  $entry = array();
  $epoch = $row['epoch'];
  $dt = new DateTime("@$epoch");
  
  echo "<QSO_DATE:8>".$dt->format('Ymd');
  echo "<TIME_ON:6>".$dt->format('His');
  echo "<TIME_OFF:6>".$dt->format('His');
  echo "<BAND:".strlen($row['band']).">".strtoupper($row['band']);
# NOTE: HamLog currently logs modes (phone, ditigal) which are *not*
# compliant with the ADIF standard! For now we'll dump the data, but
# your logging software (or LoTW) may not like it
  echo "<MODE:".strlen($row['mode']).">".strtoupper($row['mode']);
  echo "<CALL:".strlen($row['callsign']).">".strtoupper($row['callsign']);
  echo "<CLASS:".strlen($row['class']).">".strtoupper($row['class']);
  echo "<ARRL_SECT:".strlen($row['section']).">".strtoupper($row['section']);
  echo "<OPERATOR:".strlen($row['op']).">".strtoupper($row['op']);
# edit the callsign below to match that of your station (usually
# your club callsign during Field Day). Be sure to change the "5"
# to the number of characters in your callsign (e.g. K4IZ = 4, KI4STU = 6)
  echo "<STATION_CALLSIGN:5>W4OWL";
  echo "<eor>\n";
}
?>

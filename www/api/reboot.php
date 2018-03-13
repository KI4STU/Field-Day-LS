<?php
# reboot system
# originally from https://bitbucket.org/pignology/hlfds
# modified by Detrick Merz (K4IZ) to function with FDLS (https://github.com/KI4STU/Field-Day-LS)

  $ret = array();
  exec("/opt/FDLS/reboot");
  $ret['result'] = "Rebooting...<br>You'll need to refresh<br>in about a minute.";
  echo json_encode($ret);
?>

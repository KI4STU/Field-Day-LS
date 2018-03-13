<?php
# shutdown pi
# originally from https://bitbucket.org/pignology/hlfds
# modified by Detrick Merz (K4IZ) to function with FDLS (https://github.com/KI4STU/Field-Day-LS)

  $ret = array();
  exec("/opt/FDLS/shutdown");
  $ret['result'] = "Shutting down and powering off log server...";
  echo json_encode($ret);
?>

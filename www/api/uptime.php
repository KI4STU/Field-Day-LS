<?php
# display system uptime
# originally from https://bitbucket.org/pignology/hlfds
# modified by Detrick Merz (K4IZ) to function with FDLS (https://github.com/KI4STU/Field-Day-LS)
# (no real modifications were needed for this, save for adding these comments)

  $ret = array();
  $ret['uptime'] = exec("uptime");
  echo json_encode($ret);
?>

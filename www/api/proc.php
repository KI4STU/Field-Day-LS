<?php
# display status of FDLS process
# originally from https://bitbucket.org/pignology/hlfds
# modified by Detrick Merz (K4IZ) to function with FDLS (https://github.com/KI4STU/Field-Day-LS)

  $ret = array();
  exec('ps wax | egrep "FDLS" | grep -v grep', $ret['proc']);
  echo json_encode($ret);
?>

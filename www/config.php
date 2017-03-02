<?php

# number of HF transmitters
$xcvrs = 2;

# class
$class = "A";

# things that provide bonus points (1 for yes, 0 for no)
# battery/natural power (only applicable if class is A or B)
if ($class=="A" || $class=="B") {
$battery = 1;
}

# RF power not to exceed (5, 150, 1500)
$rfpower = 5;

?>

/*
** hlfds-reboot.c - reboots the system, called from PHP, this should be setuid root
** Copyright (C) 2017  Nick Garner / N3WG, Pignology
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char *argv[])
{

    printf("!!! Rebooting Now !!!\n");
    system("/sbin/reboot");

    return 0;
}

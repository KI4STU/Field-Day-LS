/*
** hlfds-shutdown.c - shuts down the system, called from PHP, this should be setuid root
** Copyright (C) 2017  Nick Garner / N3WG, Pignology
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char *argv[])
{

    printf("!!! Shutting Down !!!\n");
    system("/sbin/shutdown -h now");

    return 0;
}

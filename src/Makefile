# Makefile for compiling things for FDLS
# originally from https://bitbucket.org/pignology/hlfds
# modified by Detrick Merz (K4IZ) to function with FDLS (https://github.com/KI4STU/Field-Day-LS)

CC=gcc
CFLAGS=-Wall
INSTDEST=/opt/FDLS

all: 
	$(CC) $(CFLAGS) hlfds-announce.c -o hlfds-announce
	$(CC) $(CFLAGS) reboot.c -o reboot
	$(CC) $(CFLAGS) shutdown.c -o shutdown

install:
	mkdir -p $(INSTDEST)
	cp hlfds-announce $(INSTDEST)
	cp reboot $(INSTDEST)
	chmod 4755 $(INSTDEST)/reboot
	cp shutdown $(INSTDEST)
	chmod 4755 $(INSTDEST)/shutdown


clean:
	rm hlfds-announce
	rm reboot
	rm shutdown


/*
** hlfds-announce.c -- sends a UDP broadcast to port 7373 every 5 seconds for hlfds discovery
** Copyright (C) 2017  Nick Garner / N3WG, Pignology
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#define PINGPORT "7373" 

int main(int argc, char *argv[])
{
    printf("Sleeping for 15 seconds for DHCP to complete\n");
    sleep(15);

    int pinginterval = 5;

    int sockfd;
    struct addrinfo hints, *servinfo, *p;
    int rv;
    int numbytes;

    char dataToSend[] = "hlfds ping";

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_DGRAM;

    if ((rv = getaddrinfo("255.255.255.255", PINGPORT, &hints, &servinfo)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return 1;
    }

    // loop through all the results and make a socket
    for(p = servinfo; p != NULL; p = p->ai_next) {
        if ((sockfd = socket(p->ai_family, p->ai_socktype,
                p->ai_protocol)) == -1) {
            perror("prannounce: socket");
            continue;
        }

        break;
    }

    /* Set socket to allow broadcast */
    int bcastperm = 1;
    if (setsockopt(sockfd, SOL_SOCKET, SO_BROADCAST, (void *) &bcastperm, sizeof(bcastperm)) < 0)
    {
        perror("Can't set broadcast permission. Exiting.");
        exit(1);
    }

    if (p == NULL) {
        fprintf(stderr, "prannounce: failed to bind socket\n");
        return 2;
    }

    for (;;)
    {
      if ((numbytes = sendto(sockfd, dataToSend, strlen(dataToSend), 0, p->ai_addr, p->ai_addrlen)) == -1) {
        perror("prannounce: sendto");
        //don't exit if network is down, just try again, DHCP might not have done its job yet
        //exit(1);
      }
      //printf("prannounce: sent %d bytes to 255.255.255.255\n", numbytes);
      sleep(pinginterval);
    }

    freeaddrinfo(servinfo);

    close(sockfd);

    return 0;
}

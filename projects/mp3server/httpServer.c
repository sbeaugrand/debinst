/******************************************************************************!
 * \file httpServer.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <errno.h>
#include <search.h>
#include <linux/tcp.h>
#include "httpServer.h"
#include "resources.h"
#include "common.h"

/******************************************************************************!
 * \fn httpInit
 ******************************************************************************/
void httpInit()
{
    hcreate(27);  // 21 + 25 %
}

/******************************************************************************!
 * \fn httpAddResource
 ******************************************************************************/
void httpAddResource(const char* name, void* func)
{
    ENTRY e;

    e.key = (char*) name;
    e.data = func;
    if (hsearch(e, ENTER) == 0) {
        ERROR("hsearch");
    }
}

/******************************************************************************!
 * \fn httpSendResource
 ******************************************************************************/
unsigned int
httpSendResource(int sockClient, const char* resourceName,
                 struct Buffer* buffer, enum tFormat format)
{
    ENTRY e;
    ENTRY* ep;
    unsigned int (* func)(int sockClient,
                          struct Buffer* buffer, enum tFormat format);

    e.key = (char*) resourceName;
    if ((ep = hsearch(e, FIND)) == NULL) {
        if (send(sockClient, " ", 1, 0) != (ssize_t) 1) {
            ERROR("send");
            return 0;
        }
        return 1;
    }
    func = ep->data;
    (*func)(sockClient, buffer, format);

    return 1;
}

/******************************************************************************!
 * \fn httpGetResourceName
 ******************************************************************************/
#define RESOURCE_NAME_SIZE 16
const char* httpGetResourceName(const char* buffer)
{
    static char resourceName[RESOURCE_NAME_SIZE];
    const char* c;
    int i;

    if (strncmp(buffer, "GET /", 5) == 0) {
        c = buffer + 5;
    } else if (strncmp(buffer, "PUT /", 5) == 0) {
        c = buffer + 5;
    } else {
        return NULL;
    }
    i = 0;
    while (i < RESOURCE_NAME_SIZE - 1 &&
           *c != ' ' &&
           *c != '/' &&
           *c != '?' &&
           *c != '\0') {
        resourceName[i] = *c;
        ++c;
        ++i;
    }
    if (i == 0 && *c == ' ') {
        DEBUG("resource=root");
        return RESOURCE_NAME_ROOT;
    }
    if (i == 0 || i == RESOURCE_NAME_SIZE - 1) {
        return NULL;
    }
    resourceName[i] = '\0';

    DEBUG("resource=%s", resourceName);
    return resourceName;
}

/******************************************************************************!
 * \fn httpGetResourceParam
 ******************************************************************************/
#define RESOURCE_PARAM_SIZE 16
const char* httpGetResourceParam(const char* buffer, const char* param)
{
    static char value[RESOURCE_PARAM_SIZE];
    const char* c;
    const char* d;
    const size_t l = strlen(param);
    unsigned int i;

    c = buffer + 5;
    while (*c != '?') {
        if (*c == '\n' || *c == '\0') {
            return NULL;
        }
        ++c;
    }
    ++c;
    d = c;
    while (*d != '=') {
        if (*c == '\n' || *c == '\0') {
            return NULL;
        }
        ++d;
    }
    while (d - c != (ssize_t) l && strncmp(c, param, l) != 0) {
        c = d + 1;
        while (*c != '&' && *c != ' ') {
            if (*c == '\n' || *c == '\0') {
                return NULL;
            }
            ++c;
        }
        ++c;
        d = c;
        while (*d != '=') {
            if (*c == '\n' || *c == '\0') {
                return NULL;
            }
            ++d;
        }
    }
    c = d + 1;
    i = 0;
    while (*c != '&' && *c != ' ') {
        if (*c == '\n' || *c == '\0' || i >= RESOURCE_PARAM_SIZE - 1) {
            return NULL;
        }
        value[i] = *c;
        ++c;
        ++i;
    }
    value[i] = '\0';
    DEBUG("%s=%s", param, value);
    return value;
}

/******************************************************************************!
 * \fn httpRunServer
 ******************************************************************************/
void httpRunServer(struct Buffer* buffer)
{
    static int sockServer;
    static int sockClient;
    static struct sockaddr_in addrServer;
    static struct sockaddr_in addrClient;
    static unsigned int addrSize = sizeof(addrClient);
    static enum {
        STATE0_INIT,
        STATE1_WAIT_CONN,
        STATE2_WAIT_DATA
    } serverState = STATE0_INIT;
    int flags;
    const char* resourceName;
    const char* formatName;
    static char recvBuff[TCP_MSS_DEFAULT + 1];
    FILE* file;

    switch (serverState) {
    case STATE0_INIT:
        // socket
        if ((sockServer = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0) {
            ERROR("socket");
            return;
        }
        // sockaddr_in
        memset(&addrServer, 0, sizeof(addrServer));
        addrServer.sin_family = AF_INET;
        addrServer.sin_addr.s_addr = htonl(INADDR_ANY);
        addrServer.sin_port = htons(8080);
        // bind
        if (bind(sockServer, (struct sockaddr*) &addrServer,
                 sizeof(addrServer)) < 0) {
            ERROR("bind");
            return;
        }
        // listen
        if (listen(sockServer, 1) < 0) {
            ERROR("listen");
            return;
        }
        // nonblock
        flags = fcntl(sockServer, F_GETFL);
        fcntl(sockServer, F_SETFL, flags | O_NONBLOCK);
        // next state
        serverState = STATE1_WAIT_CONN;
        __attribute__ ((fallthrough));

    case STATE1_WAIT_CONN:
        // accept
        if ((sockClient =
                 accept(sockServer,
                        (struct sockaddr*) &addrClient,
                        &addrSize)) < 0) {
            if (errno != EWOULDBLOCK) {
                ERROR("accept");
            }
            return;
        }
        if (strcmp(inet_ntoa(addrClient.sin_addr), "127.0.0.1") != 0) {
            ERROR("unauthorized ip %s", inet_ntoa(addrClient.sin_addr));
            close(sockClient);
            return;
        }
        // next state
        serverState = STATE2_WAIT_DATA;
        __attribute__ ((fallthrough));

    case STATE2_WAIT_DATA:
        // recv
        *recvBuff = '\0';
        if (recv(sockClient, recvBuff, TCP_MSS_DEFAULT, MSG_DONTWAIT) == -1) {
            if (errno == EWOULDBLOCK) {
            } else if (errno == ECONNRESET) {  // nmap
                serverState = STATE1_WAIT_CONN;
            } else {
                ERROR("recv");
            }
            return;
        }
        // send
        if ((resourceName = httpGetResourceName(recvBuff)) != NULL) {
            formatName = httpGetResourceParam(recvBuff, "format");
            file = bufferInit(buffer);
            fprintf(file, "%s", recvBuff);
            if (formatName != NULL && strcmp(formatName, "html") == 0) {
                if (httpSendResource(sockClient, resourceName, buffer, HTML)) {
                    return;
                }
            } else {
                if (httpSendResource(sockClient, resourceName, buffer, RAW)) {
                    return;
                }
            }
        }
        // close
        close(sockClient);
        serverState = STATE1_WAIT_CONN;
        return;

    default:
        ERROR("server state");
    }
}

/******************************************************************************!
 * \fn httpGetHttpOk
 ******************************************************************************/
const char* httpGetHttpOk()
{
    static const char* r =
        "HTTP/1.0 200 OK\r\n"
        "Content-Type: text/html\r\n"
        "Connection: Keep-Alive\r\n"
        "Content-Length: ";
    return r;
}

/******************************************************************************!
 * \fn httpGetHttpOkSize
 ******************************************************************************/
size_t httpGetHttpOkSize()
{
    static size_t r = 0;
    if (r == 0) {
        r = strlen(httpGetHttpOk()) + (HTTP_LENGTH_SIZE - 1) +
            4 + 1;  // \r\n\r\n + \n
    }
    return r;
}

/******************************************************************************!
 * \fn httpQuit
 ******************************************************************************/
void httpQuit()
{
    hdestroy();
}

/******************************************************************************!
 * \file mp3client.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <linux/tcp.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include "mp3client.h"
#include "common.h"

#define SHIFT_A "  "

struct part_list* gPartRoot = NULL;
struct Buffer* gBuffer = NULL;

enum clientState gClientState = STATE0_NORMAL;
char gArtistLine[LINE_SIZE];
char gAlbumLine[LINE_SIZE];
char gPart[3];
char gLast[3];
int gPosDisplay = 0;
unsigned int gAlbumPos = 1;
struct timeval gTempo = {
    0, 0
};

/******************************************************************************!
 * \fn mp3clientWaitMp3rootDir
 ******************************************************************************/
void mp3clientWaitMp3rootDir(const char* root)
{
    char filename[LINE_SIZE];
    char line[LCD_COLS + 1];
    struct stat sstat;
    int i;

    strcpy(filename, root);
    strcat(filename, "/mp3");
    i = 0;
    while (stat(filename, &sstat) != 0) {
        sprintf(line, "%d", i);
        displayWrite("DISQUE", line);
        ++i;
        sleep(1);
    }
    if (i) {
        displayWrite("", "");
    }
}

/******************************************************************************!
 * \fn mp3clientGetMp3rootDir
 ******************************************************************************/
const char* mp3clientGetMp3rootDir()
{
    static char* root = NULL;

    if (root == NULL) {
        root = getenv("MP3DIR");
        if (root == NULL) {
            root = "/mnt/mp3";
        }
        mp3clientWaitMp3rootDir(root);
    }
    return root;
}

/******************************************************************************!
 * \fn loadAbrev
 ******************************************************************************/
void loadAbrev()
{
    struct part_list* part_elem = NULL;
    struct part_list* part_prev = NULL;
    FILE* fd;
    char filename[LINE_SIZE];
    char line[LINE_SIZE];
    char* c;

    strcpy(filename, mp3clientGetMp3rootDir());
    strcat(filename, "/.mp3abrev");
    if ((fd = fopen(filename, "r")) != NULL) {
        line[255] = '\0';
        while (fgets(line, sizeof(line), fd) != NULL) {
            if (strlen(line) > 4) {  // 3 + \n
                part_elem = malloc(sizeof(struct part_list));
                part_elem->next = NULL;
                if (gPartRoot == NULL) {
                    gPartRoot = part_elem;
                }
                if (part_prev != NULL) {
                    part_prev->next = part_elem;
                }
                part_elem->abrev[0] = line[0];
                part_elem->abrev[1] = line[1];
                part_elem->abrev[2] = '\0';
                for (c = line + 3; *c != '\0' && *c != '\n'; ++c) {
                    ;
                }
                *c = '\0';
                part_elem->name = malloc(strlen(line + 3) + 1);
                strcpy(part_elem->name, line + 3);
                part_prev = part_elem;
                DEBUG("=%s=%s=", part_elem->name, part_elem->abrev);
            }
        }
        fclose(fd);
    }
}

/******************************************************************************!
 * \fn isPortOpen
 ******************************************************************************/
int isPortOpen(int port)
{
    int sock;
    struct sockaddr_in sin;
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        ERROR("socket");
        return -1;
    }
    memset(&sin, 0, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    sin.sin_addr.s_addr = inet_addr("127.0.0.1");
    if ((connect(sock, (struct sockaddr*) &sin, sizeof(sin))) != 0) {
        DEBUG("port %d is closed", port);
        close(sock);
        return -1;
    } else {
        DEBUG("port %d is open", port);
        close(sock);
        return 0;
    }
}

/******************************************************************************!
 * \fn sendRequestAndReceive
 ******************************************************************************/
void sendRequestAndReceive(const char* action)
{
    int sock;
    struct sockaddr_in sockaddrServeur;
    ssize_t size;
    int flags;
    static char recvBuff[TCP_MSS_DEFAULT + 1];
    FILE* file = bufferInit(gBuffer);

    if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0) {
        ERROR("socket");
        fprintf(file, "err");
        return;
    }

    memset(&sockaddrServeur, 0, sizeof(sockaddrServeur));
    sockaddrServeur.sin_family = AF_INET;
    sockaddrServeur.sin_addr.s_addr = htonl(INADDR_ANY);
    sockaddrServeur.sin_port = htons(8080);

    if (connect(sock, (struct sockaddr*) &sockaddrServeur,
                sizeof(sockaddrServeur)) == -1) {
        ERROR("connect");
        close(sock);
        fprintf(file, "err");
        return;
    }
    // nonblock
    flags = fcntl(sock, F_GETFL);
    fcntl(sock, F_SETFL, flags | O_NONBLOCK);

    fprintf(file, "GET /%s ", action);
    if (send(sock, bufferGet(gBuffer), gBuffer->size, 0) !=
        (ssize_t) gBuffer->size) {
        ERROR("send");
        close(sock);
        fprintf(file, "err");
        return;
    }

    if (shutdown(sock, SHUT_WR) == -1) {
        ERROR("shutdown");
        close(sock);
        fprintf(file, "err");
        return;
    }

    file = bufferInit(gBuffer);
    while ((size = recv(sock, recvBuff, TCP_MSS_DEFAULT, 0)) == -1) {
        if (errno != EWOULDBLOCK) {
            ERROR("recv");
            close(sock);
            fprintf(file, "err");
            return;
        }
    }
    recvBuff[size] = '\0';
    fprintf(file, "%s", recvBuff);
    while ((size = recv(sock, recvBuff, TCP_MSS_DEFAULT, 0)) != -1) {
        recvBuff[size] = '\0';
        fprintf(file, "%s", recvBuff);
    }
    if (errno != EWOULDBLOCK) {
        ERROR("recv");
        close(sock);
        fprintf(file, "err");
        return;
    }

    if (close(sock) == -1) {
        ERROR("close");
        fprintf(file, "err");
        return;
    }

#   if ! defined(__arm__) && ! defined(__aarch64__)
    fprintf(stderr, "%s\n", bufferGet(gBuffer));
#   endif
}

/******************************************************************************!
 * \fn sendPid
 ******************************************************************************/
void sendPid(pid_t pid)
{
    char cmd[16];

    while (isPortOpen(8080) != 0) {
        sleep(1);
    }
    sprintf(cmd, "pid/%u", pid);
    sendRequestAndReceive(cmd);
}

/******************************************************************************!
 * \fn getBufferLine
 ******************************************************************************/
unsigned int getBufferLine(int pos, char (*line)[LINE_SIZE])
{
    const char* c;
    int i;
    int j;
    int n;
    const char* buffPtr = bufferGet(gBuffer);
    int m = gBuffer->size;

    if (pos == 0) {
        for (i = m - 2; i >= 0; --i) {
            if (buffPtr[i] == '\n') {
                ++i;
                n = 1;
                break;
            }
        }
        if (i < 0) {
            strncpy(gAlbumLine, buffPtr, LINE_SIZE - 1);
            gAlbumLine[LINE_SIZE - 1] = '\0';
            displayWrite(gArtistLine, gAlbumLine);
            return 0;
        }
    } else if (pos == 1) {
        i = 0;
        n = 1;
    } else {
        n = 1;
        for (i = 0; i < m; ++i) {
            if (buffPtr[i] == '\n') {
                ++n;
                if (n == pos) {
                    ++i;
                    break;
                }
            }
        }
    }
    if (i < 0 || i == m) {
        strcpy(gAlbumLine, "err getBufferLine");
        displayWrite(gArtistLine, gAlbumLine);
        return 0;
    }
    for (c = buffPtr + i, j = 0; j < LINE_SIZE - 1 &&
         c[j] != '\n' &&
         c[j] != '\0'; ++j) {
        (*line)[j] = c[j];
    }
    (*line)[j] = '\0';
    return n;
}

/******************************************************************************!
 * \fn changeAlbum
 ******************************************************************************/
void changeAlbum(int albumPos)
{
    char line[LINE_SIZE];
    char cmd[LINE_SIZE];
    unsigned int c;

    c = getBufferLine(albumPos, &line);
    if (c == 0 || strlen(line) < 14) {
        return;
    }
    sprintf(cmd, "album/%s/", line + 14);
    DEBUG("cmd = %s", cmd);
    sendRequestAndReceive(cmd);
}

/******************************************************************************!
 * \fn drawDate
 ******************************************************************************/
int drawDate()
{
    char line1[11];
    char line2[9];
    const char* buffPtr;

    sendRequestAndReceive("date");
    buffPtr = bufferGet(gBuffer);
    if (gBuffer->size != 19) {
        return 0;
    }
    snprintf(line1, 11, "%s", buffPtr);
    snprintf(line2, 9, "%s", buffPtr + 11);
    displayWrite(line1, line2);

    return 1;
}

/******************************************************************************!
 * \fn drawAlbum
 ******************************************************************************/
void drawAlbum()
{
    char line1[LINE_SIZE];
    char line2[LINE_SIZE];
    size_t artistSize;
    size_t albumSize;

    artistSize = strlen(gArtistLine);
    albumSize = strlen(gAlbumLine);
    if (gPosDisplay >= (ssize_t) artistSize &&
        gPosDisplay >= (ssize_t) albumSize) {
        gPosDisplay = -5;
        if (drawDate()) {
            gClientState = STATE4_DATE;
            return;
        }
    }

    if (gPosDisplay < 0) {
        gPosDisplay = 0;
    }

    if (*gPart != '\0' && gPosDisplay == 0) {
        line1[0] = gPart[0];
        line1[1] = gPart[1];
        line1[2] = ' ';
        strncpy(line1 + 3, gArtistLine, LINE_SIZE - 4);
        gArtistLine[LINE_SIZE - 1] = '\0';
    } else {
        if (gPosDisplay >= (ssize_t) artistSize) {
            line1[0] = '\0';
        } else {
            strncpy(line1, gArtistLine + gPosDisplay, LINE_SIZE - 1);
            gArtistLine[LINE_SIZE - 1] = '\0';
        }
    }
    if (*gLast != '\0' && gPosDisplay == 0) {
        line2[0] = gLast[0];
        line2[1] = gLast[1];
        line2[2] = ' ';
        strncpy(line2 + 3, gAlbumLine, LINE_SIZE - 4);
        gAlbumLine[LINE_SIZE - 1] = '\0';
    } else {
        if (gPosDisplay >= (ssize_t) albumSize) {
            line2[0] = '\0';
        } else {
            strncpy(line2, gAlbumLine + gPosDisplay, LINE_SIZE - 1);
            gAlbumLine[LINE_SIZE - 1] = '\0';
        }
    }
    displayWrite(line1, line2);
}

/******************************************************************************!
 * \fn changePart
 ******************************************************************************/
void changePart(char* line)
{
    struct part_list* part_elem;
    char part[LINE_SIZE];
    char* s;

    gPart[0] = '?';
    gPart[1] = '?';

    if (gPartRoot == NULL) {
        ERROR("empty abreviations");
        return;
    }

    s = line + 14;
    while (*s != '/') {
        if (*s == '\0') {
            ERROR("unknown part\n");
            return;
        }
        ++s;
    }
    strncpy(part, line + 14, s - line - 14);
    part[s - line - 14] = '\0';
    DEBUG("part = %s", part);

    part_elem = gPartRoot;
    while (part_elem != NULL) {
        if (strcmp(part_elem->name, part) == 0) {
            gPart[0] = part_elem->abrev[0];
            gPart[1] = part_elem->abrev[1];
            break;
        }
        part_elem = part_elem->next;
    }
}

/******************************************************************************!
 * \fn drawBuffer
 ******************************************************************************/
unsigned int drawBuffer(int albumPos)
{
    char line[LINE_SIZE];
    int i;
    unsigned int c;
    char* s;
    char* a = NULL;

    c = getBufferLine(albumPos, &line);
    if (c == 0) {
        return 0;
    }
    DEBUG("%s", line);
    if (*line != ' ') {
        gLast[0] = line[0];
        gLast[1] = line[1];
    } else {
        *gLast = '\0';
    }
    s = line;
    while (*s != '/') {
        if (*s == '\0') {
            return 0;
        }
        ++s;
    }
    i = s - line;
    for (; line[i] != '\0' &&
         (line[i] != '-' || line[i + 1] != ' ' || line[i - 1] != ' ') &&
         i < LINE_SIZE - 1; ++i) {
        ;
    }
    if (line[i] != '-' || line[i + 1] != ' ' || line[i - 1] != ' ') {
        strcpy(gAlbumLine, "err tiret 1");
        displayWrite(gArtistLine, gAlbumLine);
        return 0;
    }
    if (albumPos) {
        a = line + i + 2;
        snprintf(gArtistLine, line + i - s + 4,
                 "%c%c%c%c %s", a[0], a[1], a[2], a[3], s + 1);
    } else {
        snprintf(gArtistLine, line + i - s - 1, "%s", s + 1);
    }
    i += 2;
    for (; line[i] != '\0' &&
         (line[i] != '-' || line[i + 1] != ' ' || line[i - 1] != ' ') &&
         i < LINE_SIZE - 1; ++i) {
        ;
    }
    if (line[i] != '-' || line[i + 1] != ' ' || line[i - 1] != ' ') {
        strcpy(gAlbumLine, "err tiret 2");
        displayWrite(gArtistLine, gAlbumLine);
        return 0;
    }
    sprintf(gAlbumLine, "%s", line + i + 2);
    changePart(line);
    drawAlbum();
    return albumPos;
}

/******************************************************************************!
 * \fn drawTitle
 ******************************************************************************/
void drawTitle()
{
    int i;
    const char* buffPtr = bufferGet(gBuffer);
    int n = gBuffer->size;

    for (i = n - 2; i >= 0; --i) {
        if (buffPtr[i] == '\n') {
            strncpy(gAlbumLine, buffPtr + i + 1, LINE_SIZE - 1);
            gAlbumLine[LINE_SIZE - 1] = '\0';
            drawAlbum();
            return;
        }
    }
}

/******************************************************************************!
 * \fn signalFromServer
 ******************************************************************************/
void signalFromServer(int sig)
{
    if (sig == SIGUSR1) {
#       if ! defined(__arm__) && ! defined(__aarch64__)
        fprintf(stderr, "\n");
#       endif
        gClientState = STATE0_NORMAL;
        gTempo.tv_sec = 0;
        sendRequestAndReceive("info");
        drawBuffer(0);
#       if ! defined(__arm__) && ! defined(__aarch64__)
        fprintf(stderr, "mp3client> ");
#       endif
    }
}

/******************************************************************************!
 * \fn deletePartList
 ******************************************************************************/
void deletePartList(struct part_list* part)
{
    struct part_list* next;

    while (part != NULL) {
        free(part->name);
        next = part->next;
        free(part);
        part = next;
    }
}

/******************************************************************************!
 * \fn controlC
 ******************************************************************************/
void controlC(int sig)
{
    if (sig == SIGINT) {
        keypadQuit();
        deletePartList(gPartRoot);
        bufferQuit(gBuffer);
        free(gBuffer);
        displayQuit();
        fprintf(stderr, "\nok");
        exit(EXIT_SUCCESS);
    }
}

/******************************************************************************!
 * \fn state1forAlbum
 ******************************************************************************/
void state1forAlbum()
{
    if (leftButton()) {
        // Changement d'artiste
        gClientState = STATE2_ARTISTE;
        displayWrite(SHIFT_A "           A", "         F K P U");
        *gArtistLine = '\0';
        gettimeofday(&gTempo, NULL);
    } else if (gTempo.tv_sec != 0) {
        // Changement d'album
        if (upButton()) {
            if (gAlbumPos > 1) {
                --gAlbumPos;
                drawBuffer(gAlbumPos);
            }
            gettimeofday(&gTempo, NULL);
        } else if (downButton()) {
            ++gAlbumPos;
            if (drawBuffer(gAlbumPos) < gAlbumPos) {
                --gAlbumPos;
            }
            gettimeofday(&gTempo, NULL);
        } else if (okButton()) {
            gClientState = STATE0_NORMAL;
            gTempo.tv_sec = 0;
            changeAlbum(gAlbumPos);
        }
    }
}

/******************************************************************************!
 * \fn state2forArtist
 ******************************************************************************/
char state2forArtist()
{
    char line[LINE_SIZE + 8];  // + "artist//"
    char charPrev = '\0';
    const char* buffPtr;

    if (downButton()) {
        sprintf(line, "artist/%s/", gArtistLine);
        sendRequestAndReceive(line);
        buffPtr = bufferGet(gBuffer);
        if (buffPtr[0] != ' ' ||
            buffPtr[1] != '\0') {
            gClientState = STATE1_ALBUM;
            gAlbumPos = 1;
            drawBuffer(gAlbumPos);
            gettimeofday(&gTempo, NULL);
        } else {
            gClientState = STATE0_NORMAL;
            gTempo.tv_sec = 0;
            sendRequestAndReceive("info");
            drawBuffer(0);
        }
    } else {
        if (upButton()) {
            displayWrite(SHIFT_A "           A", "         B C D E");
            gClientState = STATE3_ARTISTE;
            charPrev = 'A';
        } else if (randButton()) {
            displayWrite(SHIFT_A "           F", "         G H I J");
            gClientState = STATE3_ARTISTE;
            charPrev = 'F';
        } else if (leftButton()) {
            displayWrite(SHIFT_A "           K", "         L M N O");
            gClientState = STATE3_ARTISTE;
            charPrev = 'K';
        } else if (okButton()) {
            displayWrite(SHIFT_A "           P", "         Q R S T");
            gClientState = STATE3_ARTISTE;
            charPrev = 'P';
        } else if (rightButton()) {
            displayWrite(SHIFT_A "           U", "         V W Y Z");
            gClientState = STATE3_ARTISTE;
            charPrev = 'U';
        }
        gettimeofday(&gTempo, NULL);
    }

    return charPrev;
}

/******************************************************************************!
 * \fn state3forArtist
 ******************************************************************************/
void state3forArtist(char charPrev)
{
    char line[LINE_SIZE + 8];  // + "artist//"
    const char* buffPtr;
    int i;

    if (downButton()) {
        sprintf(line, "artist/%s/", gArtistLine);
        sendRequestAndReceive(line);
        buffPtr = bufferGet(gBuffer);
        if (buffPtr[0] != ' ' ||
            buffPtr[1] != '\0') {
            gClientState = STATE1_ALBUM;
            gAlbumPos = 1;
            drawBuffer(gAlbumPos);
            gettimeofday(&gTempo, NULL);
        } else {
            gClientState = STATE0_NORMAL;
            gTempo.tv_sec = 0;
            sendRequestAndReceive("info");
            drawBuffer(0);
        }
    } else {
        if (upButton()) {
            switch (charPrev) {
            case 'A': strcat(gArtistLine, "A"); break;
            case 'F': strcat(gArtistLine, "F"); break;
            case 'K': strcat(gArtistLine, "K"); break;
            case 'P': strcat(gArtistLine, "P"); break;
            case 'U': strcat(gArtistLine, "U"); break;
            }
        } else if (randButton()) {
            switch (charPrev) {
            case 'A': strcat(gArtistLine, "B"); break;
            case 'F': strcat(gArtistLine, "G"); break;
            case 'K': strcat(gArtistLine, "L"); break;
            case 'P': strcat(gArtistLine, "Q"); break;
            case 'U': strcat(gArtistLine, "V"); break;
            }
        } else if (leftButton()) {
            switch (charPrev) {
            case 'A': strcat(gArtistLine, "C"); break;
            case 'F': strcat(gArtistLine, "H"); break;
            case 'K': strcat(gArtistLine, "M"); break;
            case 'P': strcat(gArtistLine, "R"); break;
            case 'U': strcat(gArtistLine, "W"); break;
            }
        } else if (okButton()) {
            switch (charPrev) {
            case 'A': strcat(gArtistLine, "D"); break;
            case 'F': strcat(gArtistLine, "I"); break;
            case 'K': strcat(gArtistLine, "N"); break;
            case 'P': strcat(gArtistLine, "S"); break;
            case 'U': strcat(gArtistLine, "Y"); break;
            }
        } else if (rightButton()) {
            switch (charPrev) {
            case 'A': strcat(gArtistLine, "E"); break;
            case 'F': strcat(gArtistLine, "J"); break;
            case 'K': strcat(gArtistLine, "O"); break;
            case 'P': strcat(gArtistLine, "T"); break;
            case 'U': strcat(gArtistLine, "Z"); break;
            }
        } else {
            return;
        }
        strcpy(line, SHIFT_A "           A");
        for (i = strlen(gArtistLine) - 1; i >= 0; --i) {
            line[i] = gArtistLine[i];
        }
        displayWrite(line, "         F K P U");
        gClientState = STATE2_ARTISTE;
        gettimeofday(&gTempo, NULL);
    }
}

/******************************************************************************!
 * \fn state4date
 ******************************************************************************/
int state4date()
{
    if (okButton()) {
        gClientState = STATE0_NORMAL;
        gPosDisplay = 0;
        drawAlbum();
        return 1;
    } else if (randButton()) {
        //gClientState = STATE0_NORMAL;
        //return (system("/usr/sbin/service dcf77d start") == 0) ? 1 : 0;
        if (system("sudo /usr/bin/rtc -slc") == 0) {
            drawDate();
        }
    } else if (upButton()) {
        if (system("date --date='+1 day' +%Y%m%d%n%H%M%S%n%w |"
            " sudo /usr/bin/rtc -sdsc; sudo /usr/bin/rtc -slc") == 0) {
            drawDate();
        }
    } else if (downButton()) {
        if (system("date --date='-1 day' +%Y%m%d%n%H%M%S%n%w |"
            " sudo /usr/bin/rtc -sdsc; sudo /usr/bin/rtc -slc") == 0) {
            drawDate();
        }
    } else if (leftButton()) {
        if (system("date --date='-1 hour' +%Y%m%d%n%H%M%S%n%w |"
            " sudo /usr/bin/rtc -sdsc; sudo /usr/bin/rtc -slc") == 0) {
            drawDate();
        }
    } else if (rightButton()) {
        if (system("date --date='+1 hour' +%Y%m%d%n%H%M%S%n%w |"
            " sudo /usr/bin/rtc -sdsc; sudo /usr/bin/rtc -slc") == 0) {
            drawDate();
        }
    }

    return 0;
}

/******************************************************************************!
 * \fn state0normal
 ******************************************************************************/
int state0normal()
{
    if (haltButton()) {
        displayWrite("ARRET", "");
        sendRequestAndReceive("halt");
        return 1;
    }
    if (leftButton()) {
        if (gPosDisplay >= 5) {
            gPosDisplay -= 5;
            drawAlbum();
        } else {
            // Changement d'album
            gClientState = STATE1_ALBUM;
            sendRequestAndReceive("info");
            gAlbumPos = 1;
            drawBuffer(gAlbumPos);
            gettimeofday(&gTempo, NULL);
        }
        return 1;
    }
    if (rightButton()) {
        gPosDisplay += 5;
        drawAlbum();
        return 1;
    }
    if (randButton()) {
        gPosDisplay = 0;
        sendRequestAndReceive("rand");
        drawBuffer(0);
        return 1;
    }
    if (okButton()) {
        gPosDisplay = 0;
        if (gTempo.tv_sec != 0) {
            gTempo.tv_sec = 0;
            // Changement d'album
            changeAlbum(gAlbumPos);
        } else {
            sendRequestAndReceive("ok");
            drawBuffer(0);
        }
        return 1;
    }
    if (downButton()) {
        gPosDisplay = 0;
        if (gTempo.tv_sec != 0) {
            // Changement d'album
            ++gAlbumPos;
            if (drawBuffer(gAlbumPos) < gAlbumPos) {
                --gAlbumPos;
            }
            gettimeofday(&gTempo, NULL);
        } else {
            // Chagement de titre
#           if defined(__arm__) || defined(__aarch64__)
            sendRequestAndReceive("ok");
#           endif
            sendRequestAndReceive("next");
            drawTitle();
        }
        return 1;
    }
    if (upButton()) {
        gPosDisplay = 0;
        if (gTempo.tv_sec != 0) {
            // Changement d'album
            if (gAlbumPos > 1) {
                --gAlbumPos;
                drawBuffer(gAlbumPos);
            }
            gettimeofday(&gTempo, NULL);
        } else {
            // Chagement de titre
#           if defined(__arm__) || defined(__aarch64__)
            sendRequestAndReceive("ok");
#           endif
            sendRequestAndReceive("prev");
            drawTitle();
        }
        return 1;
    }

    return 0;
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main()
{
#   if ! defined(__arm__) && ! defined(__aarch64__)
    char* getInput();
    char* input;
#   endif
    struct timeval tv;
    char charPrev = '\0';

    displayInit();
    loadAbrev();

    gBuffer = bufferNew();
    gPart[2] = '\0';
    gLast[2] = '\0';

    if (signal(SIGINT, controlC) == SIG_ERR) {
        ERROR("signal ctrl-c");
        return EXIT_FAILURE;
    }
    if (signal(SIGUSR1, signalFromServer) == SIG_ERR) {
        ERROR("signal");
        return EXIT_FAILURE;
    }

    sendPid(getpid());
    sendRequestAndReceive("info");
    drawBuffer(0);

    gTempo.tv_sec = 0;

    keypadInit();
    for (;;) {
        keypadRead();
#       if defined(__arm__) || defined(__aarch64__)
        nanoSleep(100000000);
#       else
        fprintf(stderr, "mp3client> ");
        input = getInput();
#       endif
        if (gTempo.tv_sec != 0) {
            gettimeofday(&tv, NULL);
            if (tv.tv_sec > gTempo.tv_sec + 30) {
                gClientState = STATE0_NORMAL;
                gTempo.tv_sec = 0;
                displayWrite("", "");
                nanoSleep(500000000);
                sendRequestAndReceive("info");
                drawBuffer(0);
                continue;
            }
        }
        if (gClientState == STATE1_ALBUM) {
            state1forAlbum();
        } else if (gClientState == STATE2_ARTISTE) {
            charPrev = state2forArtist();
        } else if (gClientState == STATE3_ARTISTE) {
            state3forArtist(charPrev);
        } else if (gClientState == STATE4_DATE) {
            state4date();
        } else {
            if (state0normal()) {
                continue;
            }
#           if ! defined(__arm__) && ! defined(__aarch64__)
            gPosDisplay = 0;
            if (strcmp(input, "prev") == 0 ||
                strcmp(input, "next") == 0) {
                sendRequestAndReceive(input);
                drawTitle();
            } else {
                sendRequestAndReceive(input);
                if (strcmp(input, "kill") == 0) {
                    deletePartList(gPartRoot);
                    bufferQuit(gBuffer);
                    free(gBuffer);
                    exit(EXIT_SUCCESS);
                }
                if (randButton()) {
                    drawBuffer(0);
                }
            }
#           endif
        }
    }

    return EXIT_SUCCESS;
}

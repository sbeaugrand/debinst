/******************************************************************************!
 * \file resources.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "resources.h"
#include "mp3server.h"
#include "player.h"
#include "log.h"
#include "html.h"
#include "common.h"

/******************************************************************************!
 * \fn sendPage
 ******************************************************************************/
void sendPage(int sock, struct Buffer* buffer)
{
    char http_length[HTTP_LENGTH_SIZE];
    char* buffPtr;
    unsigned int len;

    memset(http_length, ' ', HTTP_LENGTH_SIZE - 1);
    http_length[HTTP_LENGTH_SIZE - 1] = '\0';
    fprintf(buffer->file, http_length);
    buffPtr = bufferGet(buffer);

    strcpy(buffPtr, httpGetHttpOk());
    if (snprintf(http_length, HTTP_LENGTH_SIZE, "%zu",
                 strlen(buffPtr + httpGetHttpOkSize())) >= HTTP_LENGTH_SIZE) {
        ERROR("http_length = %s", http_length);
    }
    DEBUG("http_length = %s", http_length);
    strcat(buffPtr, http_length);
    strcat(buffPtr, "\r\n\r\n");
    len = strlen(buffPtr);
    if (len < httpGetHttpOkSize()) {
        memset(buffPtr + len, ' ', httpGetHttpOkSize() - len);
        buffPtr[httpGetHttpOkSize() - 1] = '\n';
    }
    len = strlen(buffPtr);
    if (send(sock, buffPtr, len, 0) != (ssize_t) len) {
        ERROR("send");
    }
}

/******************************************************************************!
 * \fn sendMessage
 ******************************************************************************/
void sendMessage(int sock, struct Buffer* buffer)
{
    const char* buffPtr = bufferGet(buffer);
    unsigned int buffLen = buffer->size;

    if (buffLen == 0) {
        if (send(sock, " ", 1, 0) != (ssize_t) 1) {
            ERROR("send");
        }
    } else {
        if (send(sock, buffPtr, buffLen, 0) != (ssize_t) buffLen) {
            ERROR("send");
        }
    }
}

/******************************************************************************!
 * \fn sendResourceRoot
 ******************************************************************************/
unsigned int
sendResourceRoot(int sockClient, struct Buffer* buffer,
                 enum tFormat __attribute__((__unused__)) format)
{
    FILE* buffFile = bufferInit(buffer);

    //if (format == HTML) {
    fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
    fprintf(buffFile, "%s%s", htmlGetBegin(), htmlGetEnd());
    sendPage(sockClient, buffer);
    //} else {
    //    sendMessage(sockClient, buffer);
    //}
    return 1;
}

/******************************************************************************!
 * \fn sendResourceList
 ******************************************************************************/
unsigned int
sendResourceList(int sockClient, struct Buffer* buffer, enum tFormat format)
{
    if (format == HTML) {
        sendPage(sockClient, playerTitleList(buffer, HTML));
    } else {
        sendMessage(sockClient, playerTitleList(buffer, RAW));
    }
    return 1;
}

/******************************************************************************!
 * \fn sendResourceRand
 ******************************************************************************/
unsigned int
sendResourceRand(int sockClient,
                 struct Buffer __attribute__((__unused__))* buffer,
                 enum tFormat format)
{
    if (format == HTML) {
        sendPage(sockClient, mp3serverMp3rand(HTML));
        mp3serverSignalToClient(SIGUSR1);
    } else {
        sendMessage(sockClient, mp3serverMp3rand(RAW));
    }
    return 1;
}

/******************************************************************************!
 * \fn sendResourceOk
 ******************************************************************************/
unsigned int
sendResourceOk(int sockClient, struct Buffer* buffer,
               enum tFormat __attribute__((__unused__)) format)
{
    if (mp3serverStopTempo()) {
        mp3serverReadAlbum();
        sendMessage(sockClient, mp3serverMp3info(NULL, RAW));
    } else {
        playerPause();
        sendMessage(sockClient, playerCurrentTitle(buffer));
    }
    return 1;
}

/******************************************************************************!
 * \fn sendResourceInfo
 ******************************************************************************/
unsigned int
sendResourceInfo(int sockClient,
                 struct Buffer __attribute__((__unused__))* buffer,
                 enum tFormat format)
{
    if (format == HTML) {
        sendPage(sockClient, mp3serverMp3info(NULL, HTML));
    } else {
        sendMessage(sockClient, mp3serverMp3info(NULL, RAW));
    }
    return 1;
}

/******************************************************************************!
 * \fn sendResourcePlay
 ******************************************************************************/
unsigned int
sendResourcePlay(int sockClient,
                 struct Buffer __attribute__((__unused__))* buffer,
                 enum tFormat format)
{
    playerStart();
    if (format == HTML) {
        sendPage(sockClient, playerTitleList(buffer, HTML));
    } else {
        sendMessage(sockClient, playerTitleList(buffer, RAW));
    }
    return 1;
}

/******************************************************************************!
 * \fn sendResourcePause
 ******************************************************************************/
unsigned int
sendResourcePause(int sockClient,
                  struct Buffer __attribute__((__unused__))* buffer,
                  enum tFormat format)
{
    playerPause();
    if (format == HTML) {
        sendPage(sockClient, playerTitleList(buffer, HTML));
    } else {
        sendMessage(sockClient, playerTitleList(buffer, RAW));
    }
    return 1;
}

/******************************************************************************!
 * \fn sendResourceStop
 ******************************************************************************/
unsigned int
sendResourceStop(int sockClient, struct Buffer* buffer, enum tFormat format)
{
    FILE* buffFile = bufferInit(buffer);

    mp3serverSavePlaytime(playerGetPlaytime());
    playerStop();
    if (format == HTML) {
        fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
        fprintf(buffFile, "%s%s", htmlGetEmpty(), htmlGetEnd());
        sendPage(sockClient, buffer);
    } else {
        fprintf(buffFile, "ok");
        sendMessage(sockClient, buffer);
    }
    return 1;
}

/******************************************************************************!
 * \fn sendResourceResume
 ******************************************************************************/
unsigned int
sendResourceResume(int sockClient,
                   struct Buffer __attribute__((__unused__))* buffer,
                   enum tFormat format)
{
    playerResume();
    if (format == HTML) {
        sendPage(sockClient, playerTitleList(buffer, HTML));
    } else {
        sendMessage(sockClient, playerTitleList(buffer, RAW));
    }
    return 1;
}

/******************************************************************************!
 * \fn sendResourcePrev
 ******************************************************************************/
unsigned int
sendResourcePrev(int sockClient,
                 struct Buffer __attribute__((__unused__))* buffer,
                 enum tFormat __attribute__((__unused__)) format)
{
    playerStartRel(-1);
#   if defined(__arm__)
    nanoSleep(500000000);
#   endif
    sendMessage(sockClient, playerCurrentTitle(buffer));
    return 1;
}

/******************************************************************************!
 * \fn sendResourceNext
 ******************************************************************************/
unsigned int
sendResourceNext(int sockClient,
                 struct Buffer __attribute__((__unused__))* buffer,
                 enum tFormat __attribute__((__unused__)) format)
{
    playerStartRel(1);
#   if defined(__arm__)
    nanoSleep(500000000);
#   endif
    sendMessage(sockClient, playerCurrentTitle(buffer));
    return 1;
}

/******************************************************************************!
 * \fn sendResourceDir
 ******************************************************************************/
unsigned int
sendResourceDir(int sockClient,
                struct Buffer* buffer,
                enum tFormat __attribute__((__unused__)) format)
{
    char dir[32];
    unsigned int pos;
    unsigned int i;
    char* buffPtr = bufferGet(buffer);

    pos = 5 + strlen(RESOURCE_NAME_DIR) + 1;
    for (i = 0; i < 32; ++i) {
        if (buffPtr[pos] == ' ' ||
            buffPtr[pos] == '?') {
            dir[i] = '\0';
            break;
        }
        if (buffPtr[pos] == '%' &&
            buffPtr[pos + 1] == '2' &&
            buffPtr[pos + 2] == '0') {
            dir[i] = ' ';
            pos += 3;
        } else {
            dir[i] = buffPtr[pos];
            ++pos;
        }
    }
    DEBUG("dir = %s", dir);
    sendPage(sockClient, mp3serverGetHtmlDir(dir));
    return 1;
}

/******************************************************************************!
 * \fn sendResourcePos
 ******************************************************************************/
unsigned int
sendResourcePos(int sockClient, struct Buffer* buffer,
                enum tFormat __attribute__((__unused__)) format)
{
    unsigned int pos;
    char* buffPtr = bufferGet(buffer);

    sscanf(buffPtr + 5 + strlen(RESOURCE_NAME_POS) + 1, "%3u", &pos);
    DEBUG("id = %u", pos);
    playerStartId(pos);
    sendPage(sockClient, playerTitleList(buffer, HTML));
    return 1;
}

/******************************************************************************!
 * \fn sendResourceAlbum
 ******************************************************************************/
unsigned int
sendResourceAlbum(int sockClient, struct Buffer* buffer, enum tFormat format)
{
    char album[LINE_SIZE];
    unsigned int pos;
    unsigned int i;
    char* buffPtr = bufferGet(buffer);

    pos = 5 + strlen(RESOURCE_NAME_ALBUM) + 1;
    for (i = 0; i < LINE_SIZE - 1; ++i) {
        if (buffPtr[pos] == '/' &&
            (buffPtr[pos + 1] == ' ' ||
             buffPtr[pos + 1] == '?')) {
            album[i] = '\0';
            break;
        }
        if (buffPtr[pos] == '%' &&
            buffPtr[pos + 1] == '2' &&
            buffPtr[pos + 2] == '0') {
            album[i] = ' ';
            pos += 3;
        } else if (buffPtr[pos] == '%' &&
                   buffPtr[pos + 1] == '2' &&
                   buffPtr[pos + 2] == '7') {
            album[i] = '\'';
            pos += 3;
        } else {
            album[i] = buffPtr[pos];
            ++pos;
        }
    }
    DEBUG("album = %s", album);
    mp3serverStartAlbum(album);
    if (format == HTML) {
        sendPage(sockClient, mp3serverMp3info(NULL, HTML));
        mp3serverSignalToClient(SIGUSR1);
    } else {
        sendMessage(sockClient, mp3serverMp3info(NULL, RAW));
    }
    return 1;
}

/******************************************************************************!
 * \fn sendResourceArtist
 ******************************************************************************/
unsigned int
sendResourceArtist(int sockClient, struct Buffer* buffer,
                   enum tFormat __attribute__((__unused__)) format)
{
    char artist[LINE_SIZE];
    unsigned int pos;
    unsigned int i;
    FILE* buffFile;
    char* buffPtr = bufferGet(buffer);

    pos = 5 + strlen(RESOURCE_NAME_ARTIST) + 1;
    for (i = 0; i < LINE_SIZE - 1; ++i) {
        if (buffPtr[pos] == '/' &&
            (buffPtr[pos + 1] == ' ' ||
             buffPtr[pos + 1] == '?')) {
            artist[i] = '\0';
            break;
        }
        if (buffPtr[pos] == '%' &&
            buffPtr[pos + 1] == '2' &&
            buffPtr[pos + 2] == '0') {
            artist[i] = ' ';
            pos += 3;
        } else if (buffPtr[pos] == '%' &&
                   buffPtr[pos + 1] == '2' &&
                   buffPtr[pos + 2] == '7') {
            artist[i] = '\'';
            pos += 3;
        } else {
            artist[i] = buffPtr[pos];
            ++pos;
        }
    }
    strcpy(buffPtr, mp3serverGetArtist(artist));
    DEBUG("artist = %s ==> %s", artist, buffPtr);
    if (*buffPtr != '\0') {
        sendMessage(sockClient, mp3serverMp3info(buffPtr, RAW));
    } else {
        buffFile = bufferInit(buffer);
        fprintf(buffFile, " ");
        sendMessage(sockClient, buffer);
    }
    return 1;
}

/******************************************************************************!
 * \fn sendResourceKill
 ******************************************************************************/
unsigned int
sendResourceKill(int sockClient, struct Buffer* buffer, enum tFormat format)
{
    FILE* buffFile = bufferInit(buffer);

    if (format == HTML) {
        fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
        fprintf(buffFile, "%s", htmlGetEmpty());
        fprintf(buffFile, "%s", htmlGetEnd());
        sendPage(sockClient, buffer);
    } else {
        fprintf(buffFile, "ok");
        sendMessage(sockClient, buffer);
    }
    if (close(sockClient) == -1) {
        ERROR("close");
    }
    mp3serverSavePlaytime(playerGetPlaytime());
    mp3serverQuit(EXIT_SUCCESS);

    return 1;
}

/******************************************************************************!
 * \fn sendResourceHalt
 ******************************************************************************/
unsigned int
sendResourceHalt(int sockClient, struct Buffer* buffer, enum tFormat format)
{
    FILE* buffFile = bufferInit(buffer);

    if (format == HTML) {
        fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
        fprintf(buffFile, "%s%s", htmlGetEmpty(), htmlGetEnd());
        sendPage(sockClient, buffer);
    } else {
        fprintf(buffFile, "ok");
        sendMessage(sockClient, buffer);
    }
    if (close(sockClient) == -1) {
        ERROR("close");
    }
    mp3serverSavePlaytime(playerGetPlaytime());
#   if defined(__arm__)
    if (system("sudo halt") != EXIT_SUCCESS) {
    }
#   endif
    mp3serverQuit(EXIT_SUCCESS);
    return 1;
}

/******************************************************************************!
 * \fn sendResourcePid
 ******************************************************************************/
unsigned int
sendResourcePid(int sockClient, struct Buffer* buffer,
                enum tFormat __attribute__((__unused__)) format)
{
    pid_t pid;
    FILE* buffFile;
    char* buffPtr = bufferGet(buffer);

    sscanf(buffPtr + 5 + strlen(RESOURCE_NAME_PID) + 1, "%5u", &pid);
    mp3serverSetClientPid(pid);
    DEBUG("pid = %u", pid);

    buffFile = bufferInit(buffer);
    fprintf(buffFile, "pid=%u", pid);
    sendMessage(sockClient, buffer);
    return 1;
}

/******************************************************************************!
 * \fn sendResourceDate
 ******************************************************************************/
unsigned int
sendResourceDate(int sockClient, struct Buffer* buffer, enum tFormat format)
{
    char dateOfTheDay[20];
    FILE* buffFile = bufferInit(buffer);

    strftime(dateOfTheDay,
             sizeof(dateOfTheDay), "%F %T", mp3serverTmOfTheDay());
    if (format == HTML) {
        fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
        fprintf(buffFile, "%s%s%s", htmlGetBegin(), dateOfTheDay, htmlGetEnd());
        sendPage(sockClient, buffer);
    } else {
        fprintf(buffFile, "%s", dateOfTheDay);
        sendMessage(sockClient, buffer);
    }
    return 1;
}

/******************************************************************************!
 * \fn bufferPrintFile
 ******************************************************************************/
void bufferPrintFile(FILE* buffFile, const char* filename)
{
    char buf[BUFSIZ];
    int source;
    ssize_t size;

    source = open(filename, O_RDONLY, 0);
    if (source == -1) {
        return;
    }
    while ((size = read(source, buf, BUFSIZ - 1)) > 0) {
        buf[size] = '\0';
        fprintf(buffFile, "%s", buf);
    }
    close(source);
}

/******************************************************************************!
 * \fn sendResourceLast
 ******************************************************************************/
unsigned int
sendResourceLast(int sockClient, struct Buffer* buffer, enum tFormat format)
{
    char filename[LINE_SIZE];
    FILE* buffFile = bufferInit(buffer);

    if (format == HTML) {
        fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
        fprintf(buffFile, "%s", htmlGetBegin());
    }
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3log");
    bufferPrintFile(buffFile, filename);
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3last");
    bufferPrintFile(buffFile, filename);
    if (format == HTML) {
        fprintf(buffFile, "%s", htmlGetEnd());
        sendPage(sockClient, buffer);
    } else {
        sendMessage(sockClient, buffer);
    }
    return 1;
}

/******************************************************************************!
 * \fn sendResourceLog
 ******************************************************************************/
unsigned int
sendResourceLog(int sockClient, struct Buffer* buffer, enum tFormat format)
{
    char filename[LINE_SIZE];
    FILE* buffFile = bufferInit(buffer);

    if (format == HTML) {
        fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
        fprintf(buffFile, "%s", htmlGetBegin());
    }
    fprintf(buffFile, "Server\n\n");
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3server.log.5");
    bufferPrintFile(buffFile, filename);
    fprintf(buffFile, "\n");
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3server.log.4");
    bufferPrintFile(buffFile, filename);
    fprintf(buffFile, "\n");
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3server.log.3");
    bufferPrintFile(buffFile, filename);
    fprintf(buffFile, "\n");
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3server.log.2");
    bufferPrintFile(buffFile, filename);
    fprintf(buffFile, "\n");
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3server.log.1");
    bufferPrintFile(buffFile, filename);
    fprintf(buffFile, "\n");
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3server.log");
    bufferPrintFile(buffFile, filename);
    fprintf(buffFile, "\n");
    fprintf(buffFile, "Client\n\n");
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3client.log.5");
    bufferPrintFile(buffFile, filename);
    fprintf(buffFile, "\n");
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3client.log.4");
    bufferPrintFile(buffFile, filename);
    fprintf(buffFile, "\n");
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3client.log.3");
    bufferPrintFile(buffFile, filename);
    fprintf(buffFile, "\n");
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3client.log.2");
    bufferPrintFile(buffFile, filename);
    fprintf(buffFile, "\n");
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3client.log.1");
    bufferPrintFile(buffFile, filename);
    fprintf(buffFile, "\n");
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3client.log");
    bufferPrintFile(buffFile, filename);
    fprintf(buffFile, "\n");
    if (format == HTML) {
        fprintf(buffFile, "%s", htmlGetEnd());
        sendPage(sockClient, buffer);
    } else {
        sendMessage(sockClient, buffer);
    }
    return 1;
}

/******************************************************************************!
 * \fn createResources
 ******************************************************************************/
void createResources()
{
    httpInit();
    httpAddResource(RESOURCE_NAME_ROOT, sendResourceRoot);
    httpAddResource(RESOURCE_NAME_LIST, sendResourceList);
    httpAddResource(RESOURCE_NAME_RAND, sendResourceRand);
    httpAddResource(RESOURCE_NAME_OK, sendResourceOk);
    httpAddResource(RESOURCE_NAME_INFO, sendResourceInfo);
    httpAddResource(RESOURCE_NAME_PLAY, sendResourcePlay);
    httpAddResource(RESOURCE_NAME_PAUSE, sendResourcePause);
    httpAddResource(RESOURCE_NAME_STOP, sendResourceStop);
    httpAddResource(RESOURCE_NAME_RESUME, sendResourceResume);
    httpAddResource(RESOURCE_NAME_DIR, sendResourceDir);
    httpAddResource(RESOURCE_NAME_POS, sendResourcePos);
    httpAddResource(RESOURCE_NAME_PREV, sendResourcePrev);
    httpAddResource(RESOURCE_NAME_NEXT, sendResourceNext);
    httpAddResource(RESOURCE_NAME_ALBUM, sendResourceAlbum);
    httpAddResource(RESOURCE_NAME_ARTIST, sendResourceArtist);
    httpAddResource(RESOURCE_NAME_KILL, sendResourceKill);
    httpAddResource(RESOURCE_NAME_HALT, sendResourceHalt);
    httpAddResource(RESOURCE_NAME_PID, sendResourcePid);
    httpAddResource(RESOURCE_NAME_DATE, sendResourceDate);
    httpAddResource(RESOURCE_NAME_LAST, sendResourceLast);
    httpAddResource(RESOURCE_NAME_LOG, sendResourceLog);
}

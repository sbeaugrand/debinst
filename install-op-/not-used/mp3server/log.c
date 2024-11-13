/******************************************************************************!
 * \file log.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include "log.h"
#include "mp3server.h"
#include "common.h"

/******************************************************************************!
 * \fn logGetLastAlbum
 ******************************************************************************/
int
logGetLastAlbum(char (*lastPart)[LINE_SIZE])
{
    FILE* flog = NULL;
    char line[LINE_SIZE];
    int len;
    int i;

    strcpy(line, mp3serverGetMp3rootDir());
    strcat(line, "/.mp3last");
    if ((flog = fopen(line, "r")) == NULL) {
        DEBUG("open mp3last == NULL");
        strcpy(line, mp3serverGetMp3rootDir());
        strcat(line, "/.mp3log");
        if ((flog = fopen(line, "r")) == NULL) {
            DEBUG("open mp3log == NULL");
            return 0;
        }
        fseek(flog, -LINE_SIZE, SEEK_END);
        len = fread(line, 1, LINE_SIZE, flog);
        fclose(flog);
        if (len > 1) {
            line[len - 1] = '\0';
            for (i = len - 2; i >= 0 && line[i] != '\n'; --i) {
                ;
            }
            strncpy(*lastPart, line + i + 1, LINE_SIZE);
        } else {
            ERROR("fread");
            return 0;
        }
    } else {
        len = fread(*lastPart, 1, LINE_SIZE, flog);
        fclose(flog);
    }
    for (i = len - 1; i < LINE_SIZE; ++i) {
        (*lastPart)[i] = '\0';
    }
    DEBUG("%s", *lastPart);

    return len;
}

/******************************************************************************!
 * \fn logUnreadAlbum
 ******************************************************************************/
void
logUnreadAlbum()
{
    char line[LINE_SIZE];
    const char* mp3rootDir;

    //FIXME: debug
    /*
       FILE* flog = NULL;
       char last[LINE_SIZE];
     */

    mp3rootDir = mp3serverGetMp3rootDir();
    DEBUG("effacement de la derniere selection");
    strcpy(line, mp3rootDir);
    strcat(line, "/.mp3last");

    //FIXME: debug
    /*
       if ((flog = fopen(line, "r")) != NULL) {
        if (fgets(last, LINE_SIZE, flog) == NULL) {
            ERROR("fgets");
        }
        fclose(flog);
        last[strlen(last) - 1] = '\0';
        ERROR("%s", last);
       } else {
        ERROR("fread");
        return;
       }
     */

    unlink(line);
    strcpy(line, mp3rootDir);
    strcat(line, "/.mp3date");
    unlink(line);
}

/******************************************************************************!
 * \fn logFillDatesFromLogs
 ******************************************************************************/
struct bloc_list*
logFillDatesFromLogs(struct bloc_list* bloc_artist_root, const char* artist,
                     struct tm* tmOfTheDay)
{
    char dateOfTheDay[11];
    char line[LINE_SIZE];
    FILE* flog;
    int i;
    unsigned int j;
    char logsfile[LINE_SIZE];
    struct bloc_list* bloc_elem = NULL;
    int len;
    unsigned int n = 0;

    len = strlen(artist);
    strftime(dateOfTheDay, sizeof(dateOfTheDay), "%F", tmOfTheDay);

    strcpy(logsfile, mp3serverGetMp3rootDir());
    strcat(logsfile, "/.mp3log");
    flog = fopen(logsfile, "r");
    while (! feof(flog)) {
        memset(line, 0, LINE_SIZE);
        if (fgets(line, LINE_SIZE, flog) == NULL) {
            break;
        }
        ++n;
        for (i = LINE_SIZE - 1; i >= 0 && line[i] != '/'; --i) {
            ;
        }
        if (i < 0 || line[i] != '/') {
            continue;
        }
        j = strlen(line);
        if (line[j - 1] == '\n') {
            line[j - 1] = '\0';
        }
        if (strncmp(line + i + 1, artist, len) == 0) {
            bloc_elem = bloc_artist_root;
            while (bloc_elem != NULL) {
                for (j = 0; j < bloc_elem->count; ++j) {
                    if (strcmp(bloc_elem->name[j] + 11, line + 11) == 0) {
                        strcpy(bloc_elem->name[j], line);
                        bloc_elem = NULL;
                        DEBUG("%05u %s", n, line);
                        break;
                    }
                }
                if (bloc_elem != NULL) {
                    bloc_elem = bloc_elem->next;
                }
            }
        }
    }

    fclose(flog);

    return bloc_artist_root;
}

/******************************************************************************!
 * \fn logMp3log
 ******************************************************************************/
#define DATESIZE 17
void
logMp3log(const char* album)
{
    char prevDate[DATESIZE];
    char nextDate[DATESIZE];
    FILE* logsFd;
    FILE* dateFd;
    FILE* lastFd;
    time_t t;
    struct tm* tmp;
    int d1[5] = {
        0
    };
    int d2[5] = {
        0
    };
    int i;
    char logsFile[LINE_SIZE];
    char dateFile[LINE_SIZE];
    char lastFile[LINE_SIZE];
    const char* mp3rootDir;
    char line[LINE_SIZE];
    char* token;

    mp3rootDir = mp3serverGetMp3rootDir();

    DEBUG("%s", album);

    strcpy(logsFile, mp3rootDir);
    strcat(logsFile, "/.mp3log");
    strcpy(dateFile, mp3rootDir);
    strcat(dateFile, "/.mp3date");
    strcpy(lastFile, mp3rootDir);
    strcat(lastFile, "/.mp3last");

    // Date courante
    *nextDate = '\0';
    t = time(NULL);
    tmp = localtime(&t);
    if (strftime(nextDate, DATESIZE, "%Y-%m-%d %H:%M", tmp) == 0) {
        ERROR("strftime");
        return;
    }
    DEBUG("nextDate = %s", nextDate);
    if ((token = strtok(nextDate, "-: ")) != NULL) {
        d2[0] = atoi(token);
        for (i = 1; i < 5; ++i) {
            if ((token = strtok(NULL, "-: ")) != NULL) {
                d2[i] = atoi(token);
            } else {
                ERROR("strtok nextDate (i = %d)", i);
            }
        }
    } else {
        ERROR("strtok nextDate (i = %d)", 0);
    }

    // Date precedante
    *prevDate = '\0';
    dateFd = fopen(dateFile, "r");
    if (dateFd != NULL && fgets(prevDate, DATESIZE, dateFd) == NULL) {
        fclose(dateFd);
        dateFd = NULL;
    }
    DEBUG("prevDate = %s", prevDate);
    if (dateFd != NULL) {
        fclose(dateFd);
        if ((token = strtok(prevDate, "-: ")) != NULL) {
            d1[0] = atoi(token);
            for (i = 1; i < 5; ++i) {
                if ((token = strtok(NULL, "-: ")) != NULL) {
                    d1[i] = atoi(token);
                } else {
                    ERROR("strtok prevDate (i = %d)", i);
                }
            }
        } else {
            ERROR("strtok prevDate (i = %d)", 0);
        }
        ERROR("d2 = %d %d %d %d %d, d1 = %d %d %d %d %d",
              d2[0], d2[1], d2[2], d2[3], d2[4],
              d1[0], d1[1], d1[2], d1[3], d1[4]);
        i = (d2[0] - d1[0]) * 535680 +  // 60 * 24 * 31 * 12
            (d2[1] - d1[1]) * 44640 +  // 60 * 24 * 31
            (d2[2] - d1[2]) * 1440 +  // 60 * 24
            (d2[3] - d1[3]) * 60 +
            (d2[4] - d1[4]);
#       ifndef NDEBUG
        if (i < 2) {
            DEBUG("derniere selection il y a %d minute", i);
        } else {
            DEBUG("derniere selection il y a %d minutes", i);
        }
#       endif
        if (i < 5) {
            logUnreadAlbum();
        }
    }

    // Ecriture du log
    if ((logsFd = fopen(logsFile, "a")) == NULL) {
        ERROR("fopen %s", logsFile);
        return;
    }
    if ((lastFd = fopen(lastFile, "r+")) == NULL) {
        if ((lastFd = fopen(lastFile, "w")) == NULL) {
            ERROR("fopen %s", lastFile);
            fclose(logsFd);
            return;
        }
    } else {
        if (fgets(line, LINE_SIZE, lastFd)) {
            fputs(line, logsFd);
        }
        rewind(lastFd);
    }
    fprintf(lastFd, "%d-%02d-%02d %s\n", d2[0], d2[1], d2[2], album);
    if (ftruncate(fileno(lastFd), ftell(lastFd)) != 0) {
        ERROR("ftruncate");
    }
    fclose(logsFd);
    fclose(lastFd);

    // Ecriture de la date
    if ((dateFd = fopen(dateFile, "w")) != NULL) {
        fprintf(dateFd, "%d %02d %02d %02d %02d",
                d2[0], d2[1], d2[2], d2[3], d2[4]);
        fclose(dateFd);
    } else {
        ERROR("fopen %s", dateFile);
    }
}

/******************************************************************************!
 * \file mp3server.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <signal.h>
#include "mp3server.h"
#include "player.h"
#include "log.h"
#include "resources.h"
#include "html.h"
#include "common.h"

struct part_list* gPartRoot = NULL;
struct Buffer* gBuffer = NULL;

struct tm* gTmOfTheDay = NULL;
pid_t gClientPid = 0;
struct timeval gTempo = {
    0, 0
};

unsigned int gNbWeights = 0;
int* gWeights = NULL;

/******************************************************************************!
 * \fn mp3serverWaitMp3rootDir
 ******************************************************************************/
void mp3serverWaitMp3rootDir(const char* root)
{
    char filename[LINE_SIZE];

    strcpy(filename, root);
    strcat(filename, "/mp3");
    while (access(filename, R_OK) != 0) {
        sleep(1);
    }
}

/******************************************************************************!
 * \fn mp3serverGetMp3rootDir
 ******************************************************************************/
const char* mp3serverGetMp3rootDir()
{
    static char* root = NULL;

    if (root == NULL) {
        root = getenv("MP3DIR");
        if (root == NULL) {
            root = "/mnt/mp3";
        }
        mp3serverWaitMp3rootDir(root);
    }
    return root;
}

/******************************************************************************!
 * \fn mp3serverWeightsInit
 ******************************************************************************/
void mp3serverWeightsInit()
{
    char filename[LINE_SIZE];
    char line[LINE_SIZE];
    char* ptr;
    FILE* fp;
    FILE* buffFile;
    unsigned int i;

    gNbWeights = 0;
    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3weights");
    fp = fopen(filename, "r");
    if (fp == NULL) {
        ERROR(".mp3weights not found");
        return;
    }

    buffFile = bufferInit(gBuffer);
    while (fgets(line, LINE_SIZE, fp) != NULL) {
        ptr = strtok(line, " ");
        for (; ptr != NULL; ++gNbWeights) {
            fprintf(buffFile, "%d ", atoi(ptr));
            ptr = strtok(NULL, " ");
        }
    }
    fclose(fp);
    DEBUG("nb weights = %u", gNbWeights);
    DEBUG("weights =");
    i = 0;
    gWeights = malloc(gNbWeights * sizeof(int));
    ptr = strtok(bufferGet(gBuffer), " ");
    do {
        gWeights[i] = atoi(ptr);
        DEBUG(" %d", gWeights[i]);
        ++i;
    } while ((ptr = strtok(NULL, " ")) != NULL);
}

/******************************************************************************!
 * \fn mp3serverTmOfTheDay
 ******************************************************************************/
struct tm* mp3serverTmOfTheDay()
{
    time_t tOfTheDay;
    char dateOfTheDay[20];

    tOfTheDay = time(NULL);
    gTmOfTheDay = localtime(&tOfTheDay);
    strftime(dateOfTheDay, sizeof(dateOfTheDay), "%F %T", gTmOfTheDay);
    DEBUG("date = %s", dateOfTheDay);
    return gTmOfTheDay;
}

/******************************************************************************!
 * \fn mp3serverDeleteBlocList
 ******************************************************************************/
void mp3serverDeleteBlocList(struct bloc_list* bloc)
{
    struct bloc_list* next;
    unsigned int i;

    while (bloc != NULL) {
        for (i = 0; i < bloc->count; ++i) {
            free(bloc->name[i]);
        }
        next = bloc->next;
        free(bloc);
        bloc = next;
    }
}

/******************************************************************************!
 * \fn mp3serverDeletePartList
 ******************************************************************************/
void mp3serverDeletePartList(struct part_list* part)
{
    struct part_list* next;

    while (part != NULL) {
        free(part->name);
        mp3serverDeleteBlocList(part->bloc);
        next = part->next;
        free(part);
        part = next;
    }
}

/******************************************************************************!
 * \fn mp3serverQuit
 ******************************************************************************/
void mp3serverQuit(int status)
{
    if (gBuffer != NULL) {
        bufferQuit(gBuffer);
        free(gBuffer);
    }
    if (gPartRoot != NULL) {
        mp3serverDeletePartList(gPartRoot);
    }
    if (gWeights != NULL) {
        free(gWeights);
    }
    playerQuit();
    httpQuit();
    exit(status);
}

/******************************************************************************!
 * \fn controlC
 ******************************************************************************/
void controlC(int sig)
{
    if (sig == SIGINT) {
        if (gClientPid != 0) {
            mp3serverSignalToClient(SIGINT);
        }
        mp3serverQuit(EXIT_SUCCESS);
    }
}

/******************************************************************************!
 * \fn mp3serverFillAlbumsForArtist
 ******************************************************************************/
struct bloc_list*
mp3serverFillAlbumsForArtist(struct part_list* partRoot, const char* artist)
{
    unsigned int j;
    struct part_list* part_elem;
    struct bloc_list* bloc_elem = NULL;
    struct bloc_list* bloc_artist_root = NULL;
    struct bloc_list* bloc_artist_elem = NULL;
    char* str;
    int len;

    len = strlen(artist);

    part_elem = partRoot;
    while (part_elem != NULL) {
        bloc_elem = part_elem->bloc;
        while (bloc_elem != NULL) {
            for (j = 0; j < bloc_elem->count; ++j) {
                if (strncmp(bloc_elem->name[j], artist, len) == 0) {
                    if (bloc_artist_elem == NULL) {
                        bloc_artist_elem = malloc(sizeof(struct bloc_list));
                        bloc_artist_elem->count = 0;
                        bloc_artist_elem->next = NULL;
                        bloc_artist_root = bloc_artist_elem;
                    }
                    if (bloc_artist_elem->count == BLOC_SIZE) {
                        bloc_artist_elem->next =
                            malloc(sizeof(struct bloc_list));
                        bloc_artist_elem = bloc_artist_elem->next;
                        bloc_artist_elem->count = 0;
                        bloc_artist_elem->next = NULL;
                    }
                    str = malloc(strlen(part_elem->name) +
                                 strlen(bloc_elem->name[j]) + 13);
                    strcpy(str, "           ");
                    strcat(str, part_elem->name);
                    strcat(str, "/");
                    strcat(str, bloc_elem->name[j]);
                    bloc_artist_elem->name[bloc_artist_elem->count] = str;
                    bloc_artist_elem->count++;
                }
            }
            bloc_elem = bloc_elem->next;
        }
        part_elem = part_elem->next;
    }

    return bloc_artist_root;
}

/******************************************************************************!
 * \fn mp3serverArtist
 ******************************************************************************/
struct bloc_list*
mp3serverArtist(struct part_list* partRoot, const char** newAlbum)
{
    static char album[LINE_SIZE];
    char line[LINE_SIZE];
    char artist[LINE_SIZE];
    int i;

    if (gTmOfTheDay == NULL) {
        mp3serverTmOfTheDay();
    }

    if (*newAlbum == NULL) {
        if (logGetLastAlbum(&line) == 0) {
            ERROR("logGetLastAlbum == 0");
            return NULL;
        }
    } else {
        strcpy(line, *newAlbum);
    }
    for (i = strlen(line) - 1; i >= 0 && line[i] != '/'; --i) {
        ;
    }
    if (line[i] != '/') {
        ERROR("/ not found");
        return NULL;
    }
    strcpy(album, line + i);
    *newAlbum = album + 1;

    for (i = 0; i < LINE_SIZE - 2 &&
         (album[i + 1] != '-' || album[i + 2] != ' ' || album[i] != ' ');
         ++i) {
        artist[i] = album[i + 1];
    }
    if (i >= LINE_SIZE - 2 || album[i + 1] != '-') {
        DEBUG("- not found");
        return NULL;
    }
    artist[i] = '-';
    artist[i + 1] = ' ';
    artist[i + 2] = '\0';

    return logFillDatesFromLogs(mp3serverFillAlbumsForArtist(partRoot, artist),
                                artist, gTmOfTheDay);
}

/******************************************************************************!
 * \fn mp3serverGetArtist
 ******************************************************************************/
const char* mp3serverGetArtist(const char* a)
{
    static char artist[LINE_SIZE];
    struct part_list* part_elem;
    struct bloc_list* bloc_elem = NULL;
    unsigned int i;
    const char* a1;
    const char* a2;

    part_elem = gPartRoot;
    while (part_elem != NULL) {
        bloc_elem = part_elem->bloc;
        while (bloc_elem != NULL) {
            for (i = 0; i < bloc_elem->count; ++i) {
                a1 = bloc_elem->name[i];
                a2 = a;
                while (*a2 != '\0') {
                    if (*a1 != *a2 &&
                        *a1 != *a2 + 32) {
                        break;
                    }
                    ++a1;
                    while (*a1 == ' ' ||
                           *a1 == 'x' ||
                           *a1 == 'X') {
                        ++a1;
                    }
                    ++a2;
                }
                if (*a2 == '\0') {
                    sprintf(artist, "%s/%s",
                            part_elem->name, bloc_elem->name[i]);
                    return artist;
                }
            }
            bloc_elem = bloc_elem->next;
        }
        part_elem = part_elem->next;
    }

    *artist = '\0';
    return artist;
}

/******************************************************************************!
 * \fn mp3serverGetRelativeDate
 ******************************************************************************/
const char* mp3serverGetRelativeDate(const char* ymd)
{
    static char dateR[3];
    int y;
    int m;
    int d;
    int dInit;

    if (ymd == NULL) {
        return NULL;
    }

    if (gTmOfTheDay == NULL) {
        mp3serverTmOfTheDay();
    }

    if (sscanf(ymd, "%4d-%2d-%2d", &y, &m, &d) != 3) {
        return NULL;
    }
    y = gTmOfTheDay->tm_year + 1900 - y;
    m = gTmOfTheDay->tm_mon + 1 - m;
    d = gTmOfTheDay->tm_mday - d;
    DEBUG("y = %d, m = %d, d = %d", y, m, d);
    if (d < 0) {
        d += 31;
        m -= 1;
    }
    if (m < 0) {
        m += 12;
        y -= 1;
    }
    d += m * 31 + y * 372;
    DEBUG("d = %d", d);
    if (d < 0) {  // When DS1302 is frozen
        d = 0;
    }
    if (d == 0) {
        mp3serverTmOfTheDay();
    }
    dInit = d;
    if (d > 9) {
        d /= 7;
        if (d > 9) {
            d = dInit / 31;
            if (d > 9) {
                d /= 12;
                dateR[1] = 'A';
            } else {
                dateR[1] = 'M';
            }
        } else {
            dateR[1] = 'S';
        }
    } else {
        dateR[1] = 'J';
    }
    dateR[0] = '0' + d;
    dateR[2] = '\0';

    return dateR;
}

/******************************************************************************!
 * \fn mp3serverDirFilter
 ******************************************************************************/
int mp3serverDirFilter(const struct dirent* d)
{
    if (d->d_name[0] == '.') {
        return 0;
    }

    if (d->d_type != DT_UNKNOWN &&
        d->d_type != DT_DIR) {
        return 0;
    }

    return 1;
}

/******************************************************************************!
 * \fn mp3serverGetHtmlDir
 ******************************************************************************/
struct Buffer* mp3serverGetHtmlDir(const char* dir)
{
    struct dirent** filelist = NULL;
    char fulldir[LINE_SIZE];
    int ndirs;
    int i;
    int max;
    FILE* buffFile = bufferInit(gBuffer);

    fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
    fprintf(buffFile, "%s", htmlGetBegin());

    strcpy(fulldir, mp3serverGetMp3rootDir());
    strcat(fulldir, "/mp3");
    if (dir[0] != '\0') {
        strcat(fulldir, "/");
        strcat(fulldir, dir);
    }

    fprintf(buffFile, "%s", htmlGetTableBegin());

    ndirs = scandir(fulldir, &filelist, mp3serverDirFilter, alphasort);
    if (dir[0] == '\0') {
        max = ndirs;
    } else {
        max = ndirs / DIR_PAGE_NB;
    }
    for (i = 0; i < ndirs; ++i) {
        if (strstr(filelist[i]->d_name, "tmp") != NULL) {
            continue;
        }
        if (i >= max) {
            fprintf(buffFile, "%s", htmlGetTableNewTd());
            max += ndirs / DIR_PAGE_NB;
            if (max >= ndirs - (DIR_PAGE_NB - 1)) {
                max = ndirs;
            }
        }
        if (dir[0] == '\0') {
            fprintf(buffFile, "%s", htmlGetHrefDir());
        } else {
            fprintf(buffFile, "%s", htmlGetHrefAlbum());
            fprintf(buffFile, "%s", dir);
        }
        fprintf(buffFile, "%s", filelist[i]->d_name);
        fprintf(buffFile, "%s", "/?format=html\">");
        fprintf(buffFile, "%s", filelist[i]->d_name);
        fprintf(buffFile, "%s", "</a><br/>");
    }
    if (filelist != NULL) {
        for (i = 0; i < ndirs; ++i) {
            free(filelist[i]);
        }
        free(filelist);
    }

    fprintf(buffFile, "%s", htmlGetTableEnd());

    fprintf(buffFile, "%s", htmlGetEnd());

    return gBuffer;
}

/******************************************************************************!
 * \fn mp3serverMp3info
 ******************************************************************************/
struct Buffer* mp3serverMp3info(const char* newAlbum, enum tFormat format)
{
    char line[LINE_SIZE << 1];
    char curAlbum[LINE_SIZE];
    unsigned int j;
    struct bloc_list* bloc_elem = NULL;
    struct bloc_list* bloc_artist_root = NULL;
    char* str;
    const char* dateR;
    const char* album;
    FILE* buffFile = bufferInit(gBuffer);

    if (format == HTML) {
        fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
        fprintf(buffFile, "%s", htmlGetBegin());
    }
    *curAlbum = '\0';

    album = newAlbum;
    bloc_artist_root = mp3serverArtist(gPartRoot, &album);
    if (bloc_artist_root == NULL) {
        return gBuffer;
    }

    bloc_elem = bloc_artist_root;
    while (bloc_elem != NULL) {
        for (j = 0; j < bloc_elem->count; ++j) {
            str = bloc_elem->name[j];
            dateR = mp3serverGetRelativeDate(str);
            if (dateR != NULL) {
                strcpy(line, dateR);
                strcat(line, " ");
            } else {
                strcpy(line, "   ");
            }
            strncpy(line + 3, str, 11);
            if (strlen(str) >= strlen(album) + 11 &&
                strcmp(str + strlen(str) - strlen(album), album) == 0) {
                if (format == HTML) {
                    sprintf(line + 3 + 11,
                            "%s%s/?format=html\""
                            " style=color:#ffffff>%s</a><br/>",
                            htmlGetHrefAlbum(),
                            str + 11,
                            str + 11);
                } else {
                    sprintf(line + 3 + 11, "%s\n", str + 11);
                    strcpy(curAlbum, line);
                    curAlbum[strlen(curAlbum) - 1] = '\0';
                }
            } else {
                if (format == HTML) {
                    sprintf(line + 3 + 11,
                            "%s%s/?format=html\">%s</a><br/>",
                            htmlGetHrefAlbum(),
                            str + 11,
                            str + 11);
                } else {
                    sprintf(line + 3 + 11, "%s\n", str + 11);
                }
            }
            fprintf(buffFile, "%s", line);
        }
        bloc_elem = bloc_elem->next;
    }
    mp3serverDeleteBlocList(bloc_artist_root);

    if (format == HTML) {
        fprintf(buffFile, "%s", htmlGetEnd());
    } else {
        fprintf(buffFile, "\n%s", curAlbum);
    }

    return gBuffer;
}

/******************************************************************************!
 * \fn mp3serverReadMp3List
 ******************************************************************************/
void mp3serverReadMp3List()
{
    FILE* fd;
    char listFilename[LINE_SIZE];
    char line[LINE_SIZE];
    char prev[LINE_SIZE];
    char* part;
    char* title;
    unsigned int nbParts = 0;
    struct part_list* part_elem = NULL;
    struct part_list* part_prev = NULL;
    struct bloc_list* bloc_elem = NULL;
    struct bloc_list* bloc_prev = NULL;

    strcpy(listFilename, mp3serverGetMp3rootDir());
    strcat(listFilename, "/mp3/mp3.list");

    fd = fopen(listFilename, "r");
    if (fd == NULL) {
        ERROR("fopen %s", listFilename);
        mp3serverQuit(EXIT_FAILURE);
    }
    prev[0] = '\0';
    if (gPartRoot != NULL) {
        free(gPartRoot);
        gPartRoot = NULL;
    }
    while (fgets(line, LINE_SIZE, fd) != NULL) {
        if (strstr(line, "tmp") != NULL) {
            continue;
        }
        if ((part = strtok(line, "/")) == NULL) {
            continue;
        }
        if ((title = strtok(NULL, "/")) == NULL) {
            continue;
        }
        if (strcmp(part, prev) != 0) {
            nbParts++;
            if (gNbWeights > 0 && nbParts > gNbWeights) {
                ERROR("nbParts > gNbWeights");
                break;
            }
            strcpy(prev, part);
            DEBUG("%s", prev);
            part_elem = malloc(sizeof(struct part_list));
            part_elem->name = malloc(strlen(prev) + 1);
            strcpy(part_elem->name, prev);
            part_elem->count = 0;
            part_elem->bloc = NULL;
            part_elem->next = NULL;
            if (gPartRoot == NULL) {
                gPartRoot = part_elem;
            } else {
                part_prev->next = part_elem;
            }
            part_prev = part_elem;
            bloc_prev = NULL;
        }
        if (bloc_prev == NULL) {
            bloc_elem = malloc(sizeof(struct bloc_list));
            bloc_elem->count = 0;
            bloc_elem->next = NULL;
            bloc_prev = bloc_elem;
            part_elem->bloc = bloc_elem;
        } else if (bloc_prev->count == BLOC_SIZE) {
            DEBUG("BLOC_SIZE");
            bloc_elem = malloc(sizeof(struct bloc_list));
            bloc_elem->count = 0;
            bloc_elem->next = NULL;
            bloc_prev->next = bloc_elem;
            bloc_prev = bloc_elem;
        }
        bloc_elem->name[bloc_elem->count] = malloc(strlen(title) + 1);
        strcpy(bloc_elem->name[bloc_elem->count], title);
        bloc_elem->count++;
        part_elem->count++;
    }
    fclose(fd);

    if (gNbWeights == 0) {
        gNbWeights = nbParts;
        gWeights = malloc(gNbWeights * sizeof(int));
        for (nbParts = 0; nbParts < gNbWeights; ++nbParts) {
            gWeights[nbParts] = 1;
        }
    }
}

/******************************************************************************!
 * \fn mp3serverStartAlbum
 ******************************************************************************/
void mp3serverStartAlbum(const char* album)
{
    char m3u[LINE_SIZE];

    logMp3log(album);

    strcpy(m3u, "file://");
    strcat(m3u, mp3serverGetMp3rootDir());
    strcat(m3u, "/mp3/");
    strcat(m3u, album);
    strcat(m3u, "/00.m3u");
    DEBUG("m3u = %s", m3u);

    playerM3u(m3u);

    mp3serverStopTempo();
}

/******************************************************************************!
 * \fn mp3serverReadAlbum
 ******************************************************************************/
void mp3serverReadAlbum()
{
    char album[LINE_SIZE];

    if (logGetLastAlbum(&album) == 0) {
        return;
    }
    mp3serverStartAlbum(album + 11);
}

/******************************************************************************!
 * \fn mp3serverGetRandomNumber
 ******************************************************************************/
int mp3serverGetRandomNumber(unsigned int min, unsigned int max)
{
    static int r = -1;
    char line[LINE_SIZE];
    FILE* fp = NULL;
    int i;
    unsigned int seed;

    strcpy(line, mp3serverGetMp3rootDir());
    strcat(line, "/.mp3rand");

    if (r == -1) {
        fp = fopen(line, "r+");
        if (fp != NULL) {
            fseek(fp, -LINE_SIZE, SEEK_END);
            i = fread(line, 1, LINE_SIZE, fp);
            if (i > 1) {
                line[i - 1] = '\0';
                for (i -= 2; i >= 0 && line[i] != '\n'; --i) {
                    ;
                }
                if (i >= 0) {
                    seed = atoi(line + (i + 1));
                    srand(seed);
                    r = rand();
                } else {
                    ERROR("i < 0");
                    seed = time(NULL);
                    srand(seed);
                    r = seed;
                }
            } else {
                ERROR("fread");
                seed = time(NULL);
                srand(seed);
                r = seed;
            }
        } else {
            ERROR("fopen");
            seed = time(NULL);
            srand(seed);
            r = seed;
        }
        DEBUG("seed = %u", seed);
    } else {
        r = rand();
    }

    i = r / ((RAND_MAX / (max - min + 1)) + 1) + min;

    if (fp != NULL) {
        if (fseek(fp, 0, SEEK_END) == -1) {
            ERROR("fseek");
        }
    } else {
        fp = fopen(line, "a");
        if (fp == NULL) {
            ERROR("fopen");
        }
    }
    if (fp != NULL) {
        fprintf(fp, "%d %u %u %d\n", r, min, max, i);
        fclose(fp);
    }

    return i;
}

/******************************************************************************!
 * \fn mp3serverMp3rand
 ******************************************************************************/
struct Buffer* mp3serverMp3rand(enum tFormat format)
{
    char album[LINE_SIZE];
    struct part_list* part_elem = gPartRoot;
    struct bloc_list* bloc_elem = NULL;
    int part;
    int max;
    int r;
    unsigned int i;
    FILE* buffFile;

    if (gPartRoot == NULL) {
        ERROR("gPartRoot == NULL");
        buffFile = bufferInit(gBuffer);
        fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
        return gBuffer;
    }

    max = 0;
    for (i = 0; i < gNbWeights; i++) {
        max += gWeights[i];
    }
    r = mp3serverGetRandomNumber(0, max - 1);
    DEBUG("max = %d rand = %d", max, r);

    part = 1;
    max = 0;
    for (i = 0; i < gNbWeights; ++i) {
        max += gWeights[i];
        if (r < max) {
            break;
        }
        part++;
        part_elem = part_elem->next;
        if (part_elem == NULL) {
            ERROR("part_elem == NULL");
            buffFile = bufferInit(gBuffer);
            fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
            return gBuffer;
        }
    }
    DEBUG("name = %s", part_elem->name);

    max = part_elem->count;
    r = mp3serverGetRandomNumber(0, max - 1);
    DEBUG("max = %d rand = %d", max, r);

    bloc_elem = part_elem->bloc;
    for (i = (r >> 4); i > 0; i--) {
        bloc_elem = bloc_elem->next;
        if (bloc_elem == NULL) {
            ERROR("bloc_elem == NULL");
            buffFile = bufferInit(gBuffer);
            fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
            return gBuffer;
        }
    }
    DEBUG("ptr = %p", bloc_elem->name);
    DEBUG("name = %s", bloc_elem->name[r & 0x0F]);

    strcpy(album, part_elem->name);
    strcat(album, "/");
    strcat(album, bloc_elem->name[r & 0x0F]);

    logMp3log(album);
    mp3serverStartTempo();
    return mp3serverMp3info(album, format);
}

/******************************************************************************!
 * \fn mp3serverSavePlaytime
 ******************************************************************************/
void mp3serverSavePlaytime(int32_t playtime)
{
    char timefile[LINE_SIZE];
    FILE* fp;

    strcpy(timefile, mp3serverGetMp3rootDir());
    strcat(timefile, "/.mp3time");
    fp = fopen(timefile, "w");
    if (fp != NULL) {
        fprintf(fp, "%d", playtime);
        fclose(fp);
    }
}

/******************************************************************************!
 * \fn mp3serverSignalToClient
 ******************************************************************************/
void mp3serverSignalToClient(int sig)
{
#   if defined(__arm__) || defined(__aarch64__)
    char cmd[32];
#   endif

    if (gClientPid != 0) {
#       if defined(__arm__) || defined(__aarch64__)
        sprintf(cmd, "sudo kill -%d %u", sig, gClientPid);
        if (system(cmd) != EXIT_SUCCESS) {
        }
#       else
        kill(gClientPid, sig);
#       endif
    }
}

/******************************************************************************!
 * \fn mp3serverStartTempo
 ******************************************************************************/
void mp3serverStartTempo()
{
    gettimeofday(&gTempo, NULL);
}

/******************************************************************************!
 * \fn mp3serverStopTempo
 ******************************************************************************/
int mp3serverStopTempo()
{
    if (gTempo.tv_sec != 0) {
        gTempo.tv_sec = 0;
        return 1;
    }
    return 0;
}

/******************************************************************************!
 * \fn mp3serverSetClientPid
 ******************************************************************************/
void mp3serverSetClientPid(pid_t pid)
{
    gClientPid = pid;
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main()
{
    struct timeval tv;
    struct rlimit rlim;

    mp3serverGetMp3rootDir();
#   ifdef RPI
    if (system("sudo /etc/init.d/fake-hwclock start >/dev/null") !=
        EXIT_SUCCESS) {
        ERROR("system /etc/init.d/fake-hwclock start != 0");
    }
#   endif

    getrlimit(RLIMIT_CORE, &rlim);
    DEBUG("rlimit_core = %lu(cur) %lu(max)", rlim.rlim_cur, rlim.rlim_max);
    rlim.rlim_cur = RLIM_INFINITY;
    rlim.rlim_max = RLIM_INFINITY;
    setrlimit(RLIMIT_CORE, &rlim);
    getrlimit(RLIMIT_CORE, &rlim);
    DEBUG("rlimit_core = %lu(cur) %lu(max)", rlim.rlim_cur, rlim.rlim_max);

    gBuffer = bufferNew();
    mp3serverWeightsInit();
    mp3serverReadMp3List();
    playerInit();
    createResources();
    httpRunServer(gBuffer);
    playerResume();

    if (signal(SIGINT, controlC) == SIG_ERR) {
        ERROR("signal ctrl-c");
        return EXIT_FAILURE;
    }

    for (;;) {
        nanoSleep(100000000);
        httpRunServer(gBuffer);
        if (gTempo.tv_sec != 0) {
            gettimeofday(&tv, NULL);
            if (tv.tv_sec > gTempo.tv_sec + 30) {
                gTempo.tv_sec = 0;
                logUnreadAlbum();
                if (gClientPid != 0) {
                    mp3serverSignalToClient(SIGUSR1);
                }
            }
        }
    }

    return EXIT_SUCCESS;
}

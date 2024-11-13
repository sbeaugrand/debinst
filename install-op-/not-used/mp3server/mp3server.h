/******************************************************************************!
 * \file mp3server.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef MP3SERVER_H
#define MP3SERVER_H
#include <dirent.h>
#include "httpServer.h"

#define BLOC_SIZE 16

struct part_list {
    char abrev[3];
    char* name;
    unsigned int count;
    struct bloc_list* bloc;
    struct part_list* next;
};

struct bloc_list {
    char* name[BLOC_SIZE];
    unsigned int count;
    struct bloc_list* next;
};

void mp3serverWeightsInit();
void mp3serverDateDuJour();
void mp3serverDeleteBlocList(struct bloc_list* bloc);
void mp3serverDeletePartList(struct part_list* part);
void mp3serverQuit(int status);
struct bloc_list*
mp3serverFillAlbumsForArtist(struct part_list* partRoot, const char* artist);
struct bloc_list*
mp3serverArtist(struct part_list* partRoot, const char** newAlbum);
const char* mp3serverGetArtist(const char* a);
const char* mp3serverGetRelativeDate(const char* ymd);
int mp3serverDirFilter(const struct dirent* d);
struct Buffer* mp3serverGetHtmlDir(const char* dir);
struct Buffer* mp3serverMp3info(const char* newAlbum, enum tFormat format);
void mp3serverReadMp3List();
void mp3serverStartAlbum(const char* album);
void mp3serverReadAlbum();
struct Buffer* mp3serverMp3rand(enum tFormat format);
void mp3serverSavePlaytime(int32_t playtime);
void mp3serverSignalToClient(int sig);
const char* mp3serverGetMp3rootDir();
void mp3serverStartTempo();
int mp3serverStopTempo();
void mp3serverSetClientPid(pid_t pid);
struct tm* mp3serverTmOfTheDay();

#endif

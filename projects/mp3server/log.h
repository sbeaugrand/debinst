/******************************************************************************!
 * \file log.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef LOG_H
#define LOG_H
#include <time.h>

#define LINE_SIZE 256

int logGetLastAlbum(char (*lastPart)[LINE_SIZE]);
void logUnreadAlbum();
struct bloc_list*
logFillDatesFromLogs(struct bloc_list* bloc_artist_root, const char* artist,
                     struct tm* tmOfTheDay);
void logMp3log(const char* album);

#endif

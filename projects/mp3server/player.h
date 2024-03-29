/******************************************************************************!
 * \file player.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef PLAYER_H
#define PLAYER_H
#include "httpServer.h"
#include "common.h"

int playerInit();
int32_t playerGetStatus();
int32_t playerGetPlaytime();
int32_t playerGetPlaytime();
struct Buffer* playerTitleList(struct Buffer* buffer, enum tFormat format);
void playerStop();
void playerStart();
void playerStartId(int pos);
void playerStartRel(int pos);
void playerPause();
void playerResume();
void playerM3u(const char* m3u);
struct Buffer* playerCurrentTitle(struct Buffer* buffer);
void playerQuit();

#endif

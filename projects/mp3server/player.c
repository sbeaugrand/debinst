/******************************************************************************!
 * \file player.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <xmmsclient/xmmsclient.h>
#include "player.h"
#include "mp3server.h"
#include "log.h"
#include "html.h"
#include "common.h"

xmmsc_connection_t* gConn = NULL;

/******************************************************************************!
 * \fn playerInit
 ******************************************************************************/
int playerInit()
{
    int ret = 0;

    gConn = xmmsc_init("MP3");

    if (system("xmms2-launcher -i unix:///run/xmms-ipc-ip"
               " 2>/run/xmms2-launcher.log") != EXIT_SUCCESS) {
        DEBUG("warning: system xmms2-launcher != 0");
    }
    ret = xmmsc_connect(gConn, NULL);

    return ret;
}

/******************************************************************************!
 * \fn playerIsError
 ******************************************************************************/
int playerIsError(xmmsv_t* val, const char* func)
{
    const char* err;

    if (xmmsv_is_error(val)) {
        if (xmmsv_get_error(val, &err)) {
            ERROR("%s: %s", func, err);
        } else {
            ERROR("%s", func);
        }
        return 1;
    }
    return 0;
}

/******************************************************************************!
 * \fn playerGetStatus
 ******************************************************************************/
int32_t playerGetStatus()
{
    xmmsc_result_t* res;
    xmmsv_t* val;
    int32_t status;

    res = xmmsc_playback_status(gConn);
    xmmsc_result_wait(res);
    val = xmmsc_result_get_value(res);
    if (playerIsError(val, __FUNCTION__)) {
        xmmsc_result_unref(res);
        return 0;
    }
    xmmsv_get_int(val, &status);
    xmmsc_result_unref(res);

    return status;
}

/******************************************************************************!
 * \fn playerGetPlaytime
 ******************************************************************************/
int32_t playerGetPlaytime()
{
    xmmsc_result_t* res;
    xmmsv_t* val;
    int32_t status;
    int32_t playtime;

    // Status
    status = playerGetStatus();
    if (status != XMMS_PLAYBACK_STATUS_PLAY &&
        status != XMMS_PLAYBACK_STATUS_PAUSE) {
        return 0;
    }

    // Playtime
    res = xmmsc_playback_playtime(gConn);
    xmmsc_result_wait(res);
    val = xmmsc_result_get_value(res);
    if (playerIsError(val, __FUNCTION__)) {
        xmmsc_result_unref(res);
        return 0;
    }
    xmmsv_get_int(val, &playtime);
    xmmsc_result_unref(res);

    return playtime;
}

/******************************************************************************!
 * \fn playerGetPosition
 ******************************************************************************/
int playerGetPosition()
{
    xmmsc_result_t* res;
    xmmsv_t* val;
    int pos;

    res = xmmsc_playlist_current_pos(gConn, XMMS_ACTIVE_PLAYLIST);
    xmmsc_result_wait(res);
    val = xmmsc_result_get_value(res);
    if (! xmmsv_dict_entry_get_int(val, "position", &pos)) {
        ERROR("xmmsv_dict_entry_get_int");
        pos = 0;
    }
    xmmsc_result_unref(res);
    DEBUG("pos = %d", pos);

    return pos;
}

/******************************************************************************!
 * \fn playerTitleList
 ******************************************************************************/
struct Buffer* playerTitleList(struct Buffer* buffer, enum tFormat format)
{
    xmmsc_result_t* res;
    xmmsv_t* val;
    xmmsv_list_iter_t* it;
    xmmsv_t* entry;
    xmmsc_result_t* infores;
    xmmsv_t* infoval;
    int32_t id;
    int32_t playtime;
    int pos;
    int duration;
    const char* strval = NULL;
    int count = 0;
    char href[LINE_SIZE];
    FILE* buffFile = bufferInit(buffer);

    // Position
    pos = playerGetPosition();

    if (format == HTML) {
        fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
        fprintf(buffFile, "%s", htmlGetBegin());
    }

    // List
    res = xmmsc_playlist_list_entries(gConn, XMMS_ACTIVE_PLAYLIST);
    xmmsc_result_wait(res);
    val = xmmsc_result_get_value(res);

    for (xmmsv_get_list_iter(val, &it);
         xmmsv_list_iter_valid(it);
         xmmsv_list_iter_next(it), ++count) {
        xmmsv_list_iter_entry(it, &entry);
        if (xmmsv_get_int(entry, &id)) {
            DEBUG("id = %d", id);
            if (count == pos) {
                fprintf(buffFile, "->");
                DEBUG("id == pos");
            } else {
                fprintf(buffFile, "  ");
            }
            infores = xmmsc_medialib_get_info(gConn, id);
            xmmsc_result_wait(infores);
            infoval =
                xmmsv_propdict_to_dict(xmmsc_result_get_value(infores), NULL);

            fprintf(buffFile, "[%02d] ", count + 1);
            if ((xmmsv_dict_entry_get_string) (infoval, "artist", &strval)) {
                fprintf(buffFile, "%s", strval);
            }
            if ((xmmsv_dict_entry_get_string) (infoval, "title", &strval)) {
                fprintf(buffFile, " - ");
                if (count == pos) {
                    fprintf(buffFile, "%s", strval);
                } else {
                    if (format == HTML) {
                        sprintf(href, "<a href=\"/pos/%d\">%s</a>",
                                count, strval);
                        fprintf(buffFile, "%s", href);
                    } else {
                        fprintf(buffFile, "%s", strval);
                    }
                }
                DEBUG("%s", strval);
            }
            if ((xmmsv_dict_entry_get_int) (infoval, "duration", &duration)) {
                duration /= 1000;
                if (count == pos) {
                    playtime = playerGetPlaytime();
                    if (playtime != 0) {
                        playtime /= 1000;
                        fprintf(buffFile,
                                " (%02d:%02d/%02d:%02d)",
                                playtime / 60,
                                playtime % 60,
                                duration / 60,
                                duration % 60);

                    } else {
                        fprintf(buffFile, " (%02d:%02d)",
                                duration / 60,
                                duration % 60);
                    }
                } else {
                    fprintf(buffFile, " (%02d:%02d)",
                            duration / 60,
                            duration % 60);
                }
            }
            if (format == HTML) {
                fprintf(buffFile, "<br/>");
            } else {
                fprintf(buffFile, "\n");
            }

            xmmsc_result_unref(infores);
            xmmsv_unref(infoval);
        }
    }

    if (format == HTML) {
        fprintf(buffFile, "%s", htmlGetEnd());
    }

    xmmsc_result_unref(res);

    return buffer;
}

/******************************************************************************!
 * \fn playerStop
 ******************************************************************************/
void playerStop()
{
    xmmsc_result_t* res;
    xmmsv_t* val;

    res = xmmsc_playback_stop(gConn);
    xmmsc_result_wait(res);
    val = xmmsc_result_get_value(res);
    if (playerIsError(val, __FUNCTION__)) {
    }
    xmmsc_result_unref(res);
}

/******************************************************************************!
 * \fn playerStart
 ******************************************************************************/
void playerStart()
{
    xmmsc_result_t* res;
    xmmsv_t* val;

    res = xmmsc_playback_start(gConn);
    xmmsc_result_wait(res);
    val = xmmsc_result_get_value(res);
    if (playerIsError(val, __FUNCTION__)) {
    }
    xmmsc_result_unref(res);
}

/******************************************************************************!
 * \fn playerStartId
 ******************************************************************************/
void playerStartId(int pos)
{
    xmmsc_result_t* res;

    res = xmmsc_playlist_set_next(gConn, pos);
    xmmsc_result_wait(res);
    xmmsc_result_unref(res);

    res = xmmsc_playback_tickle(gConn);
    xmmsc_result_wait(res);
    xmmsc_result_unref(res);

    playerStart();
}

/******************************************************************************!
 * \fn playerStartRel
 ******************************************************************************/
void playerStartRel(int pos)
{
    xmmsc_result_t* res;

    res = xmmsc_playlist_set_next_rel(gConn, pos);
    xmmsc_result_wait(res);
    xmmsc_result_unref(res);

    res = xmmsc_playback_tickle(gConn);
    xmmsc_result_wait(res);
    xmmsc_result_unref(res);

    playerStart();
}

/******************************************************************************!
 * \fn playerPause
 ******************************************************************************/
void playerPause()
{
    xmmsc_result_t* res;
    xmmsv_t* val;
    int32_t status;

    // Status
    status = playerGetStatus();

    // Pause
    if (status == XMMS_PLAYBACK_STATUS_PAUSE) {
        res = xmmsc_playback_start(gConn);
    } else {
        res = xmmsc_playback_pause(gConn);
    }
    xmmsc_result_wait(res);
    val = xmmsc_result_get_value(res);
    if (playerIsError(val, __FUNCTION__)) {
    }
    xmmsc_result_unref(res);
}

/******************************************************************************!
 * \fn playerResume
 ******************************************************************************/
void playerResume()
{
    xmmsc_result_t* res;
    xmmsv_t* val;
    int32_t status;
    char filename[LINE_SIZE];
    FILE* fp;
    int milliseconds;

    strcpy(filename, mp3serverGetMp3rootDir());
    strcat(filename, "/.mp3time");
    fp = fopen(filename, "r");
    if (fp == NULL) {
        return;
    }
    if (fscanf(fp, "%10d", &milliseconds) != 1) {
        fclose(fp);
        return;
    }
    fclose(fp);
    DEBUG("milliseconds = %d", milliseconds);

    // Status
    status = playerGetStatus();
    if (status != XMMS_PLAYBACK_STATUS_PLAY) {
        playerStart();
        sleep(2);
    }

    // Seek
    res = xmmsc_playback_seek_ms(gConn, milliseconds,
                                 XMMS_PLAYBACK_SEEK_SET);
    xmmsc_result_wait(res);
    val = xmmsc_result_get_value(res);
    if (playerIsError(val, __FUNCTION__)) {
    }
    xmmsc_result_unref(res);

    unlink(filename);
}

/******************************************************************************!
 * \fn playerM3u
 ******************************************************************************/
void playerM3u(char* m3u)
{
    xmmsc_result_t* res;
    xmmsc_result_t* res2;
    xmmsv_t* val;
    xmmsv_coll_t* coll = NULL;

    playerStop();

    // Clear
    res = xmmsc_playlist_clear(gConn, XMMS_ACTIVE_PLAYLIST);
    xmmsc_result_wait(res);
    val = xmmsc_result_get_value(res);
    if (playerIsError(val, __FUNCTION__)) {
    }
    xmmsc_result_unref(res);

    // Coll
    res = xmmsc_coll_idlist_from_playlist_file(gConn, m3u);
    xmmsc_result_wait(res);
    val = xmmsc_result_get_value(res);
    if (playerIsError(val, __FUNCTION__)) {
    }
    xmmsv_get_coll(val, &coll);

    // Add
//  version > 0.8 :
//  res2 = xmmsc_playlist_add_idlist(gConn, XMMS_ACTIVE_PLAYLIST, val);
    res2 = xmmsc_playlist_add_idlist(gConn, XMMS_ACTIVE_PLAYLIST, coll);
    xmmsc_result_wait(res2);
    val = xmmsc_result_get_value(res2);
    if (playerIsError(val, __FUNCTION__)) {
    }

    xmmsc_result_unref(res2);
    xmmsc_result_unref(res);

    playerStart();
}

/******************************************************************************!
 * \fn playerCurrentTitle
 ******************************************************************************/
struct Buffer* playerCurrentTitle(struct Buffer* buffer)
{
    FILE* buffFile = bufferInit(buffer);

    xmmsc_result_t* res;
    xmmsc_result_t* infores;
    xmmsv_t* val;
    xmmsv_t* infoval;
    xmmsv_list_iter_t* it;
    xmmsv_t* entry;
    int32_t status;
    int32_t id;
    int pos;
    int count = 0;
    const char* strval = NULL;
#   if defined(__arm__)
    const char* c;
#   endif

    // Status
    status = playerGetStatus();
    if (status == XMMS_PLAYBACK_STATUS_PAUSE) {
        fprintf(buffFile, "PAUSE ");
    }

    // Position
    pos = playerGetPosition();
    fprintf(buffFile, "%02d ", pos + 1);

    // Title
/*
    res = xmmsc_playback_current_id(mConn);
    xmmsc_result_wait(res);
    val = xmmsc_result_get_value(res);
    if (! xmmsv_get_int(val, &id)) {
        strval = "erreur: playerCurrentTitle xmmsv_get_int";
        DEBUG("%s", strval);
        fprintf(buffFile, "%s", strval);
        return buffer;
    }
    infores = xmmsc_medialib_get_info(mConn, id);
    xmmsc_result_wait(infores);
    info = xmmsv_propdict_to_dict(xmmsc_result_get_value(infores), NULL);
    if (xmmsv_dict_entry_get_string(info, "title", &strval)) {
        fprintf(buffFile, "%s", strval);
    }
    xmmsv_unref(info);
    xmmsc_result_unref(infores);
    xmmsc_result_unref(res);
 */
    res = xmmsc_playlist_list_entries(gConn, XMMS_ACTIVE_PLAYLIST);
    xmmsc_result_wait(res);
    val = xmmsc_result_get_value(res);
    for (xmmsv_get_list_iter(val, &it);
         xmmsv_list_iter_valid(it);
         xmmsv_list_iter_next(it), ++count) {
        if (count != pos) {
            continue;
        }
        xmmsv_list_iter_entry(it, &entry);
        if (! xmmsv_get_int(entry, &id)) {
            break;
        }
        infores = xmmsc_medialib_get_info(gConn, id);
        xmmsc_result_wait(infores);
        infoval = xmmsv_propdict_to_dict(xmmsc_result_get_value(infores), NULL);
        if ((xmmsv_dict_entry_get_string) (infoval, "title", &strval)) {
#           if defined(__arm__)
            for (c = strval; *c != '\0'; ++c) {
                if (c[0] == ' ' &&
                    c[1] == '-' &&
                    c[2] == ' ') {
                    strval = c + 3;
                    break;
                }
            }
#           endif
            fprintf(buffFile, "%s", strval);
        }
        xmmsv_unref(infoval);
        xmmsc_result_unref(infores);
        xmmsc_result_unref(res);
        break;
    }

    return buffer;
}

/******************************************************************************!
 * \fn playerQuit
 ******************************************************************************/
void playerQuit()
{
    if (gConn != NULL) {
        xmmsc_unref(gConn);
    }
}

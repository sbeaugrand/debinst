/******************************************************************************!
 * \file player-mpd.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <mpd/client.h>
#include "player.h"
#include "mp3server.h"
#include "log.h"
#include "html.h"
#include "common.h"

const int32_t STATE_UNKNOWN = 0;
const int32_t STATE_PLAY = 2;
const int32_t STATE_PAUSE = 3;

struct mpd_connection* gConn = NULL;

/******************************************************************************!
 * \fn playerIsError
 ******************************************************************************/
int
playerIsError(const char* func)
{
    enum mpd_error err = mpd_connection_get_error(gConn);
    if (err != MPD_ERROR_SUCCESS) {
        if (err == MPD_ERROR_CLOSED ||
            err == MPD_ERROR_SYSTEM) {
            return err;
        }
        ERROR("%s: %d: %s", func, err, mpd_connection_get_error_message(gConn));
        mpd_connection_clear_error(gConn);
        return -1;
    }
    return 0;
}

/******************************************************************************!
 * \fn playerInit
 ******************************************************************************/
int
playerInit()
{
    if (gConn != NULL) {
        mpd_connection_free(gConn);
    }
    gConn = mpd_connection_new("/run/mpd.sock", 0, 0);
    if (gConn == NULL) {
        ERROR("gConn == NULL");
        return 1;
    }
    if (playerIsError(__FUNCTION__)) {
        mpd_connection_free(gConn);
        gConn = NULL;
        return 2;
    }
    if (! mpd_connection_set_keepalive(gConn, true)) {
        ERROR("set_keepalive");
        return 3;
    }
    return 0;
}

/******************************************************************************!
 * \fn playerGetMPDStatus
 ******************************************************************************/
struct mpd_status*
playerGetMPDStatus()
{
    int res;
    struct mpd_status* status = mpd_run_status(gConn);
    res = playerIsError(__FUNCTION__);
    if (res == MPD_ERROR_CLOSED ||
        res == MPD_ERROR_SYSTEM) {
        if (status != NULL) {
            mpd_status_free(status);
        }
        DEBUG("reconnect");
        playerInit();
        status = mpd_run_status(gConn);
        if (playerIsError(__FUNCTION__)) {
        }
    }
    return status;
}

/******************************************************************************!
 * \fn playerGetStatus
 ******************************************************************************/
int32_t
playerGetStatus()
{
    enum mpd_state res;
    struct mpd_status* status = playerGetMPDStatus();
    if (status == NULL) {
        return STATE_UNKNOWN;
    }

    res = mpd_status_get_state(status);
    mpd_status_free(status);

    /*  */ if (res == MPD_STATE_PLAY) {
        return STATE_PLAY;
    } else if (res == MPD_STATE_PAUSE) {
        return STATE_PAUSE;
    }
    return STATE_UNKNOWN;
}

/******************************************************************************!
 * \fn playerGetPlaytime
 ******************************************************************************/
int32_t
playerGetPlaytime()
{
    unsigned int res;
    struct mpd_status* status = playerGetMPDStatus();
    if (status == NULL) {
        return 0;
    }

    res = mpd_status_get_elapsed_ms(status);
    mpd_status_free(status);

    return res;
}

/******************************************************************************!
 * \fn playerGetPosition
 ******************************************************************************/
int
playerGetPosition()
{
    unsigned int res;
    struct mpd_status* status = playerGetMPDStatus();
    if (status == NULL) {
        return 0;
    }

    res = mpd_status_get_song_pos(status);
    mpd_status_free(status);
    DEBUG("pos = %u", res);

    return res;
}

/******************************************************************************!
 * \fn playerTitleList
 ******************************************************************************/
struct Buffer*
playerTitleList(struct Buffer* buffer, enum tFormat format)
{
    int32_t playtime;
    int pos;
    unsigned int duration;
    struct mpd_song* song = NULL;
    int count = 0;
    char href[LINE_SIZE];
    FILE* buffFile = bufferInit(buffer);
    int length;
    const char* tag;

    struct mpd_status* status = playerGetMPDStatus();
    if (status == NULL) {
        return buffer;
    }

    pos = mpd_status_get_song_pos(status);
    DEBUG("pos = %d", pos);
    length = mpd_status_get_queue_length(status);
    DEBUG("length = %d", length);
    mpd_status_free(status);

    if (format == HTML) {
        fseek(buffFile, httpGetHttpOkSize(), SEEK_SET);
        fprintf(buffFile, "%s", htmlGetBegin());
    }

    for (count = 0; count < length; ++count) {
        song = mpd_run_get_queue_song_pos(gConn, count);
        if (playerIsError(__FUNCTION__)) {
            if (song != NULL) {
                mpd_song_free(song);
            }
            return buffer;
        }
        if (song == NULL) {
            return buffer;
        }
        DEBUG("id = %d", mpd_song_get_id(song));
        if (count == pos) {
            fprintf(buffFile, "->");
            DEBUG("count == pos");
        } else {
            fprintf(buffFile, "  ");
        }

        fprintf(buffFile, "[%02d] ", count + 1);
        tag = mpd_song_get_tag(song, MPD_TAG_ARTIST, 0);
        if (tag != NULL) {
            fprintf(buffFile, "%s", tag);
        }
        fprintf(buffFile, " - ");
        tag = mpd_song_get_tag(song, MPD_TAG_TITLE, 0);
        if (tag != NULL) {
            if (count == pos) {
                fprintf(buffFile, "%s", tag);
            } else {
                if (format == HTML) {
                    sprintf(href, "<a href=\"/pos/%d\">%s</a>", count, tag);
                    fprintf(buffFile, "%s", href);
                } else {
                    fprintf(buffFile, "%s", tag);
                }
            }
            DEBUG("%s", tag);
        }
        duration = mpd_song_get_duration_ms(song);
        duration /= 1000;
        if (count == pos) {
            playtime = playerGetPlaytime();
            if (playtime != 0) {
                playtime /= 1000;
                fprintf(buffFile,
                        " (%02d:%02d/%02u:%02u)",
                        playtime / 60,
                        playtime % 60,
                        duration / 60,
                        duration % 60);
            } else {
                fprintf(buffFile, " (%02u:%02u)",
                        duration / 60,
                        duration % 60);
            }
        } else {
            fprintf(buffFile, " (%02u:%02u)",
                    duration / 60,
                    duration % 60);
        }
        if (format == HTML) {
            fprintf(buffFile, "<br/>");
        } else {
            fprintf(buffFile, "\n");
        }
        mpd_song_free(song);
    }

    if (format == HTML) {
        fprintf(buffFile, "%s", htmlGetEnd());
    }

    return buffer;
}

/******************************************************************************!
 * \fn playerStop
 ******************************************************************************/
void
playerStop()
{
    bool res;
    struct mpd_status* status = playerGetMPDStatus();
    if (status == NULL) {
        return;
    }
    mpd_status_free(status);

    res = mpd_run_stop(gConn);
    if (playerIsError(__FUNCTION__)) {
    }
    if (! res) {
        ERROR("mpd_run_stop");
    }
}

/******************************************************************************!
 * \fn playerStart
 ******************************************************************************/
void
playerStart()
{
    bool res;
    struct mpd_status* status = playerGetMPDStatus();
    if (status == NULL) {
        return;
    }
    mpd_status_free(status);

    res = mpd_run_play(gConn);
    if (playerIsError(__FUNCTION__)) {
    }
    if (! res) {
        ERROR("mpd_run_play");
    }
}

/******************************************************************************!
 * \fn playerStartId
 ******************************************************************************/
void
playerStartId(int pos)
{
    bool res;
    struct mpd_status* status = playerGetMPDStatus();
    if (status == NULL) {
        return;
    }
    mpd_status_free(status);

    if (pos < 0) {
        res = mpd_run_previous(gConn);
    } else {
        res = mpd_run_next(gConn);
    }
    if (playerIsError(__FUNCTION__)) {
        return;
    }
    if (! res) {
        ERROR("mpd_run_ previous next");
        return;
    }
    playerStart();
}

/******************************************************************************!
 * \fn playerStartRel
 ******************************************************************************/
void
playerStartRel(int pos)
{
    bool res;
    struct mpd_status* status = playerGetMPDStatus();
    if (status == NULL) {
        return;
    }
    mpd_status_free(status);

    if (pos > 0) {
        res = mpd_run_next(gConn);
    } else {
        res = mpd_run_previous(gConn);
    }
    if (playerIsError(__FUNCTION__)) {
        return;
    }
    if (! res) {
        ERROR("mpd_run_ next previous");
        return;
    }
    playerStart();
}

/******************************************************************************!
 * \fn playerPause
 ******************************************************************************/
void
playerPause()
{
    bool res;
    if (playerGetStatus() == STATE_PAUSE) {
        res = mpd_run_play(gConn);
    } else {
        res = mpd_run_pause(gConn, true);
    }
    if (playerIsError(__FUNCTION__)) {
    }
    if (! res) {
        ERROR("mpd_run_ play pause");
    }
}

/******************************************************************************!
 * \fn playerResume
 ******************************************************************************/
void
playerResume()
{
    bool res;
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
    if (status != STATE_PLAY) {
        playerStart();
        sleep(2);
    }

    // Seek
    res = mpd_run_seek_current(gConn, milliseconds / 1000.0, false);
    if (playerIsError(__FUNCTION__)) {
    }
    if (! res) {
        ERROR("mpd_run_seek_current");
    }

    unlink(filename);
}

/******************************************************************************!
 * \fn playerM3u
 ******************************************************************************/
void
playerM3u(const char* m3u)
{
    bool res;

    playerStop();

    res = mpd_run_clear(gConn);
    if (playerIsError(__FUNCTION__)) {
    }
    if (! res) {
        ERROR("mpd_run_clear");
    }

    DEBUG("m3u = %s", m3u);
    res = mpd_run_load(gConn, m3u);
    if (playerIsError(__FUNCTION__)) {
    }
    if (! res) {
        ERROR("mpd_run_load");
    }

    playerStart();
}

/******************************************************************************!
 * \fn playerCurrentTitle
 ******************************************************************************/
struct Buffer*
playerCurrentTitle(struct Buffer* buffer)
{
    FILE* buffFile = bufferInit(buffer);

    int32_t status;
    int pos;
    struct mpd_song* song = NULL;
    const char* tag;
#   if defined(__arm__) || defined(__aarch64__)
    const char* c;
#   endif

    // Status
    status = playerGetStatus();
    if (status == STATE_PAUSE) {
        fprintf(buffFile, "PAUSE ");
    }

    // Position
    pos = playerGetPosition();
    fprintf(buffFile, "%02d ", pos + 1);
    if (pos < 0) {
        return buffer;
    }

    // Title
    song = mpd_run_get_queue_song_pos(gConn, pos);
    if (playerIsError(__FUNCTION__)) {
        if (song != NULL) {
            mpd_song_free(song);
        }
        return buffer;
    }
    if (song == NULL) {
        ERROR("mpd_run_get_queue_song_pos");
        return buffer;
    }
    tag = mpd_song_get_tag(song, MPD_TAG_TITLE, 0);
#   if defined(__arm__) || defined(__aarch64__)
    if (tag != NULL) {
        for (c = tag; *c != '\0'; ++c) {
            if (c[0] == ' ' &&
                c[1] == '-' &&
                c[2] == ' ') {
                tag = c + 3;
                break;
            }
        }
    }
#   endif
    if (tag != NULL) {
        fprintf(buffFile, "%s", tag);
    }
    mpd_song_free(song);

    return buffer;
}

/******************************************************************************!
 * \fn playerQuit
 ******************************************************************************/
void
playerQuit()
{
    if (gConn == NULL) {
        ERROR("gConn == NULL");
        return;
    }

    struct mpd_status* status = playerGetMPDStatus();
    if (status == NULL) {
        gConn = NULL;
        return;
    }
    mpd_status_free(status);

    mpd_connection_free(gConn);
    gConn = NULL;
}

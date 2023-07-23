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

struct mpd_connection* gConn = NULL;

/******************************************************************************!
 * \fn playerIsError
 ******************************************************************************/
int playerIsError(const char* func)
{
    if (mpd_connection_get_error(gConn) != MPD_ERROR_SUCCESS) {
        ERROR("%s: %s\n", func, mpd_connection_get_error_message(gConn));
        return 1;
    }
    return 0;
}

/******************************************************************************!
 * \fn playerInit
 ******************************************************************************/
int playerInit()
{
    gConn = mpd_connection_new(NULL, 0, 0);
    if (gConn == NULL) {
        ERROR("%s: %s\n", __FUNCTION__, "gConn == NULL");
        return 1;
    }
    if (playerIsError(__FUNCTION__)) {
        mpd_connection_free(gConn);
        gConn = NULL;
        return 2;
    }
    return 0;
}

/******************************************************************************!
 * \fn playerGetStatus
 ******************************************************************************/
int32_t playerGetStatus()
{
    enum mpd_state res;
    struct mpd_status* status = mpd_run_status(gConn);
    if (playerIsError(__FUNCTION__)) {
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
int32_t playerGetPlaytime()
{
    unsigned res;
    struct mpd_status* status = mpd_run_status(gConn);
    if (playerIsError(__FUNCTION__)) {
        return 0;
    }
    res = mpd_status_get_elapsed_ms(status);
    mpd_status_free(status);

    return res;
}

/******************************************************************************!
 * \fn playerGetPosition
 ******************************************************************************/
int playerGetPosition()
{
    unsigned res;
    struct mpd_status* status = mpd_run_status(gConn);
    if (playerIsError(__FUNCTION__)) {
        return 0;
    }
    res = mpd_status_get_song_pos(status);
    mpd_status_free(status);
    DEBUG("pos = %d", res);

    return res;
}

/******************************************************************************!
 * \fn playerTitleList
 ******************************************************************************/
struct Buffer* playerTitleList(struct Buffer* buffer, enum tFormat format)
{
    unsigned id;
    int32_t playtime;
    int pos;
    unsigned duration;
    struct mpd_song* song = NULL;
    int count = 0;
    char href[LINE_SIZE];
    FILE* buffFile = bufferInit(buffer);
    int length;

    struct mpd_status* status = mpd_run_status(gConn);
    if (playerIsError(__FUNCTION__)) {
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
            return buffer;
        }
        id = mpd_song_get_id(song);
        DEBUG("id = %d", id);
        if (count == pos) {
            fprintf(buffFile, "->");
            DEBUG("id == pos");
        } else {
            fprintf(buffFile, "  ");
        }

        fprintf(buffFile, "[%02d] ", count + 1);
        fprintf(buffFile, "%s", mpd_song_get_tag(song, MPD_TAG_ARTIST, id));
        fprintf(buffFile, " - ");
        if (count == pos) {
            fprintf(buffFile, "%s", mpd_song_get_tag(song, MPD_TAG_TITLE, id));
        } else {
            if (format == HTML) {
                sprintf(href, "<a href=\"/pos/%d\">%s</a>",
                        count, mpd_song_get_tag(song, MPD_TAG_TITLE, id));
                fprintf(buffFile, "%s", href);
            } else {
                fprintf(buffFile, "%s",
                        mpd_song_get_tag(song, MPD_TAG_TITLE, id));
            }
        }
        DEBUG("%s", mpd_song_get_tag(song, MPD_TAG_TITLE, id));
        duration = mpd_song_get_duration_ms(song);
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
void playerStop()
{
    mpd_run_stop(gConn);
    if (playerIsError(__FUNCTION__)) {
    }
}

/******************************************************************************!
 * \fn playerStart
 ******************************************************************************/
void playerStart()
{
    mpd_run_play(gConn);
    if (playerIsError(__FUNCTION__)) {
    }
}

/******************************************************************************!
 * \fn playerStartId
 ******************************************************************************/
void playerStartId(int pos)
{
    if (pos < 0) {
        mpd_run_previous(gConn);
    } else {
        mpd_run_next(gConn);
    }
    if (playerIsError(__FUNCTION__)) {
        return;
    }
    playerStart();
}

/******************************************************************************!
 * \fn playerStartRel
 ******************************************************************************/
void playerStartRel(int pos)
{
    mpd_run_seek_pos(gConn, pos, 0);
    if (playerIsError(__FUNCTION__)) {
        return;
    }
    playerStart();
}

/******************************************************************************!
 * \fn playerPause
 ******************************************************************************/
void playerPause()
{
	if (playerGetStatus(gConn) == STATE_PAUSE) {
        mpd_run_play(gConn);
	} else {
        mpd_run_pause(gConn, true);
	}
    if (playerIsError(__FUNCTION__)) {
    }
}

/******************************************************************************!
 * \fn playerResume
 ******************************************************************************/
void playerResume()
{
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
    mpd_send_seek_current(gConn, milliseconds / 1000.0, false);
    if (playerIsError(__FUNCTION__)) {
    }

    unlink(filename);
}

/******************************************************************************!
 * \fn playerM3u
 ******************************************************************************/
void playerM3u(char* m3u)
{
    playerStop();

    mpd_run_clear(gConn);
    if (playerIsError(__FUNCTION__)) {
    }

    mpd_run_load(gConn, m3u);
    if (playerIsError(__FUNCTION__)) {
    }

    playerStart();
}

/******************************************************************************!
 * \fn playerCurrentTitle
 ******************************************************************************/
struct Buffer* playerCurrentTitle(struct Buffer* buffer)
{
    FILE* buffFile = bufferInit(buffer);

    int32_t status;
    int pos;
    struct mpd_song* song = NULL;
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

    // Title
    song = mpd_run_get_queue_song_pos(gConn, pos);
    if (playerIsError(__FUNCTION__)) {
        return buffer;
    }
#   if defined(__arm__) || defined(__aarch64__)
    for (c = mpd_song_get_tag(song, MPD_TAG_TITLE, pos); *c != '\0'; ++c) {
        if (c[0] == ' ' &&
            c[1] == '-' &&
            c[2] == ' ') {
            strval = c + 3;
            break;
        }
    }
#   endif
    fprintf(buffFile, "%s", mpd_song_get_tag(song, MPD_TAG_TITLE, pos));
    mpd_song_free(song);

    return buffer;
}

/******************************************************************************!
 * \fn playerQuit
 ******************************************************************************/
void playerQuit()
{
    if (gConn == NULL) {
        ERROR("%s: %s\n", __FUNCTION__, "gConn == NULL");
        return;
    }
    mpd_connection_free(gConn);
}

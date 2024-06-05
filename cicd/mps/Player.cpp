/******************************************************************************!
 * \file Player.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <iostream>
#include "Player.h"
#include "log.h"

/******************************************************************************!
 * \fn ~Player
 ******************************************************************************/
Player::~Player()
{
    DEBUG("");
    this->quit();
}

/******************************************************************************!
 * \fn isError
 ******************************************************************************/
int
Player::isError(const char* func)
{
    enum mpd_error err = mpd_connection_get_error(mConn);
    if (err != MPD_ERROR_SUCCESS) {
        if (err == MPD_ERROR_CLOSED ||
            err == MPD_ERROR_SYSTEM) {
            DEBUG("MPD_ERROR_CLOSED || MPD_ERROR_SYSTEM");
            return err;
        }
        ERROR(func << " " <<
              err << " " << mpd_connection_get_error_message(mConn));
        mpd_connection_clear_error(mConn);
        return -1;
    }
    return 0;
}

/******************************************************************************!
 * \fn init
 ******************************************************************************/
int
Player::init()
{
    if (mConn != NULL) {
        mpd_connection_free(mConn);
    }
    mConn = mpd_connection_new("/run/mpd.sock", 0, 0);
    if (mConn == NULL) {
        ERROR("mConn == NULL");
        return 1;
    }
    if (this->isError(__FUNCTION__)) {
        mpd_connection_free(mConn);
        mConn = NULL;
        return 2;
    }
    if (! mpd_connection_set_keepalive(mConn, true)) {
        ERROR("set_keepalive");
        return 3;
    }

    if (! mpd_send_command(mConn, "config", NULL)) {
        return 4;
    }
    struct mpd_pair* pair = mpd_recv_pair_named(mConn, "music_directory");
    if (pair == NULL) {
        DEBUG("default music directory");
        this->musicDirectory = "/mnt/mp3/mp3";
    } else {
        this->musicDirectory = pair->value;
        mpd_return_pair(mConn, pair);
    }
    mpd_response_finish(mConn) || mpd_connection_clear_error(mConn);
    DEBUG(this->musicDirectory);

    return 0;
}

/******************************************************************************!
 * \fn getMPDStatus
 ******************************************************************************/
struct mpd_status*
Player::getMPDStatus()
{
    int res;
    struct mpd_status* status = mpd_run_status(mConn);
    res = this->isError(__FUNCTION__);
    if (res == MPD_ERROR_CLOSED ||
        res == MPD_ERROR_SYSTEM) {
        if (status != NULL) {
            mpd_status_free(status);
        }
        DEBUG("reconnect");
        this->init();
        status = mpd_run_status(mConn);
        if (this->isError(__FUNCTION__)) {
        }
    }
    return status;
}

/******************************************************************************!
 * \fn getStatus
 ******************************************************************************/
unsigned int
Player::getStatus()
{
    enum mpd_state res;
    struct mpd_status* status = this->getMPDStatus();
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
 * \fn getPlaytime
 ******************************************************************************/
unsigned int
Player::getPlaytime()
{
    unsigned int res;
    struct mpd_status* status = this->getMPDStatus();
    if (status == NULL) {
        return 0;
    }

    res = mpd_status_get_elapsed_ms(status);
    mpd_status_free(status);

    return res;
}

/******************************************************************************!
 * \fn titleList
 ******************************************************************************/
Json::Value
Player::titleList()
{
    Json::Value r;
    unsigned int playtime;
    int pos;
    struct mpd_song* song = NULL;
    int count = 0;
    int length;
    const char* tag;

    struct mpd_status* status = this->getMPDStatus();
    if (status == NULL) {
        return r;
    }

    pos = mpd_status_get_song_pos(status);
    DEBUG("pos " << pos);
    r["pos"] = pos;
    length = mpd_status_get_queue_length(status);
    DEBUG("length " << length);
    mpd_status_free(status);

    r["song"] = {};
    for (count = 0; count < length; ++count) {
        Json::Value s;
        song = mpd_run_get_queue_song_pos(mConn, count);
        if (this->isError(__FUNCTION__)) {
            if (song != NULL) {
                mpd_song_free(song);
            }
            return r;
        }
        if (song == NULL) {
            return r;
        }
        DEBUG("id " << mpd_song_get_id(song));

        tag = mpd_song_get_tag(song, MPD_TAG_ARTIST, 0);
        if (tag != NULL) {
            s["artist"] = tag;
        }
        tag = mpd_song_get_tag(song, MPD_TAG_TITLE, 0);
        if (tag != NULL) {
            s["title"] = tag;
        }
        unsigned int duration = mpd_song_get_duration_ms(song);
        duration /= 1000;
        s["duration"] = duration;
        if (count == pos) {
            playtime = this->getPlaytime();
            if (playtime != 0) {
                playtime /= 1000;
                s["playtime"] = playtime;
            }
        }
        mpd_song_free(song);
        r["song"].append(s);
    }

    return r;
}

/******************************************************************************!
 * \fn stop
 ******************************************************************************/
void
Player::stop()
{
    bool res;
    struct mpd_status* status = this->getMPDStatus();
    if (status == NULL) {
        return;
    }
    mpd_status_free(status);

    res = mpd_run_stop(mConn);
    if (this->isError(__FUNCTION__)) {
    }
    if (! res) {
        ERROR("mpd_run_stop");
    }
}

/******************************************************************************!
 * \fn start
 ******************************************************************************/
void
Player::start()
{
    DEBUG("");
    bool res;
    struct mpd_status* status = this->getMPDStatus();
    if (status == NULL) {
        DEBUG("status == NULL");
        return;
    }
    mpd_status_free(status);

    res = mpd_run_play(mConn);
    if (this->isError(__FUNCTION__)) {
    }
    if (! res) {
        ERROR("mpd_run_play");
    }
}

/******************************************************************************!
 * \fn startId
 ******************************************************************************/
void
Player::startId(int pos)
{
    bool res;
    struct mpd_status* status = this->getMPDStatus();
    if (status == NULL) {
        return;
    }
    mpd_status_free(status);

    if (pos < 0) {
        res = mpd_run_previous(mConn);
    } else {
        res = mpd_run_next(mConn);
    }
    if (this->isError(__FUNCTION__)) {
        return;
    }
    if (! res) {
        ERROR("mpd_run_ previous next");
        return;
    }
    this->start();
}

/******************************************************************************!
 * \fn startRel
 ******************************************************************************/
void
Player::startRel(int pos)
{
    bool res;
    struct mpd_status* status = this->getMPDStatus();
    if (status == NULL) {
        return;
    }
    mpd_status_free(status);

    if (pos > 0) {
        res = mpd_run_next(mConn);
    } else {
        res = mpd_run_previous(mConn);
    }
    if (this->isError(__FUNCTION__)) {
        return;
    }
    if (! res) {
        ERROR("mpd_run_ next previous");
        return;
    }
    this->start();
}

/******************************************************************************!
 * \fn pause
 ******************************************************************************/
void
Player::pause()
{
    bool res;
    if (this->getStatus() == STATE_PAUSE) {
        res = mpd_run_play(mConn);
    } else {
        res = mpd_run_pause(mConn, true);
    }
    if (this->isError(__FUNCTION__)) {
    }
    if (! res) {
        ERROR("mpd_run_ play pause");
    }
}

/******************************************************************************!
 * \fn resume
 ******************************************************************************/
void
Player::resume(int milliseconds)
{
    bool res;
    unsigned int status;

    // Status
    status = this->getStatus();
    if (status != STATE_PLAY) {
        this->start();
        sleep(2);
    }

    // Seek
    res = mpd_run_seek_current(mConn, milliseconds / 1000.0, false);
    if (this->isError(__FUNCTION__)) {
    }
    if (! res) {
        ERROR("mpd_run_seek_current");
    }
}

/******************************************************************************!
 * \fn m3u
 ******************************************************************************/
void
Player::m3u(std::string_view album)
{
    bool res;

    this->stop();

    res = mpd_run_clear(mConn);
    if (this->isError(__FUNCTION__)) {
    }
    if (! res) {
        ERROR("mpd_run_clear");
    }

    std::string m3u = this->musicDirectory + '/' + album.data();
    DEBUG(m3u);
    res = mpd_run_load(mConn, m3u.c_str());
    if (this->isError(__FUNCTION__)) {
        ERROR(m3u);
    }
    if (! res) {
        ERROR("mpd_run_load");
    }

    this->start();
}

/******************************************************************************!
 * \fn currentTitle
 ******************************************************************************/
Json::Value
Player::currentTitle()
{
    Json::Value r;

    struct mpd_status* status = this->getMPDStatus();
    if (status == NULL) {
        return r;
    }
    int pos = mpd_status_get_song_pos(status);
    if (pos < 0) {
        return r;
    }
    r["pos"] = pos;
    r["length"] = mpd_status_get_queue_length(status);
    if (mpd_status_get_state(status) == MPD_STATE_PAUSE) {
        r["pause"] = true;
    } else {
        r["pause"] = false;
    }
    mpd_status_free(status);

    struct mpd_song* song = mpd_run_get_queue_song_pos(mConn, pos);
    if (this->isError(__FUNCTION__)) {
        if (song != NULL) {
            mpd_song_free(song);
        }
        return r;
    }
    if (song == NULL) {
        ERROR("mpd_run_get_queue_song_pos");
        return r;
    }

    if (const char* tag = mpd_song_get_tag(song, MPD_TAG_TITLE, 0);
        tag != NULL) {
        r["title"] = tag;
    }

    if (const char* tag = mpd_song_get_tag(song, MPD_TAG_ALBUM, 0);
        tag != NULL) {
        r["album"] = tag;
    }

    if (const char* tag = mpd_song_get_tag(song, MPD_TAG_ARTIST, 0);
        tag != NULL) {
        r["artist"] = tag;
    }

    if (const char* tag = mpd_song_get_tag(song, MPD_TAG_DATE, 0);
        tag != NULL) {
        r["date"] = tag;
    }

    mpd_song_free(song);
    return r;
}

/******************************************************************************!
 * \fn quit
 ******************************************************************************/
void
Player::quit()
{
    if (mConn == NULL) {
        return;
    }

    struct mpd_status* status = this->getMPDStatus();
    if (status == NULL) {
        mConn = NULL;
        return;
    }
    mpd_status_free(status);

    mpd_connection_free(mConn);
    mConn = NULL;
}

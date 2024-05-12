/******************************************************************************!
 * \file Player.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <jsoncpp/json/value.h>
#include <mpd/client.h>

class Player
{
public:
    const int32_t STATE_UNKNOWN = 0;
    const int32_t STATE_PLAY = 2;
    const int32_t STATE_PAUSE = 3;
    explicit Player(const std::string& path);
    ~Player();
    int init();
    Json::Value currentTitle();
    void resume(int milliseconds);
    int32_t getPlaytime();
    Json::Value titleList();
    void start();
    void startRel(int pos);
    void pause();
    void stop();
    void m3u(std::string_view album);
private:
    int isError(const char* func);
    struct mpd_status* getMPDStatus();
    int32_t getStatus();
    int getPosition();
    void startId(int pos);
    void quit();

    std::string mPath;
    struct mpd_connection* mConn = nullptr;
};

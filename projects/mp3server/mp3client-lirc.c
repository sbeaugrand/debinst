/******************************************************************************!
 * \file mp3client-lirc.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <fcntl.h>
#include <lirc/lirc_client.h>
#include "mp3client.h"
#include "debug.h"

int gLircSocket = -1;
enum {
    KEY_BACK,
    KEY_DOWN,
    KEY_LEFT,
    KEY_MODE,
    KEY_OK,
    KEY_PLAYPAUSE,
    KEY_RIGHT,
    KEY_SETUP,
    KEY_UP,
    KEY_UNDEFINED
} gKey;

/******************************************************************************!
 * \fn keypadInit
 ******************************************************************************/
void keypadInit()
{
    gLircSocket = lirc_init("irexec", 1);
    if (gLircSocket == -1) {
        ERROR("lirc_init");
    }
    if (fcntl(gLircSocket, F_SETFL,
              fcntl(gLircSocket, F_GETFL, 0) | O_NONBLOCK) == -1) {
        ERROR("fcntl");
    }
}

/******************************************************************************!
 * \fn keypadRead
 ******************************************************************************/
void keypadRead()
{
    char* code;
    char* backup;
    char* button;

    gKey = KEY_UNDEFINED;

    if (lirc_nextcode(&code) != 0 || code == NULL) {
        return;
    }

    backup = strdup(code);
    if (backup == NULL) {
        ERROR("strdup");
        free(code);
        return;
    }
    strtok(backup, " ");
    strtok(NULL, " ");
    button = strtok(NULL, " ");
    if (button == NULL) {
        ERROR("strtok");
        free(backup);
        free(code);
        return;
    }

    /*  */ if (strcmp(button, "KEY_BACK") == 0) {
        gKey = KEY_BACK;
    } else if (strcmp(button, "KEY_DOWN") == 0) {
        gKey = KEY_DOWN;
    } else if (strcmp(button, "KEY_LEFT") == 0) {
        gKey = KEY_LEFT;
    } else if (strcmp(button, "KEY_MODE") == 0) {
        gKey = KEY_MODE;
    } else if (strcmp(button, "KEY_OK") == 0) {
        gKey = KEY_OK;
    } else if (strcmp(button, "KEY_PLAYPAUSE") == 0) {
        gKey = KEY_PLAYPAUSE;
    } else if (strcmp(button, "KEY_RIGHT") == 0) {
        gKey = KEY_RIGHT;
    } else if (strcmp(button, "KEY_SETUP") == 0) {
        gKey = KEY_SETUP;
    } else if (strcmp(button, "KEY_UP") == 0) {
        gKey = KEY_UP;
    } else {
        ERROR("KEY_UNDEFINED %s", button);
        gKey = KEY_UNDEFINED;
    }
    DEBUG("key = %d", gKey);

    free(backup);
    free(code);
}

/******************************************************************************!
 * \fn keypadQuit
 ******************************************************************************/
void keypadQuit()
{
    lirc_deinit();
}

/******************************************************************************!
 * \fn undefinedButton
 ******************************************************************************/
int undefinedButton()
{
    return gKey == KEY_UNDEFINED;
}

/******************************************************************************!
 * \fn downButton
 ******************************************************************************/
int downButton()
{
    return gKey == KEY_DOWN;
}

/******************************************************************************!
 * \fn leftButton
 ******************************************************************************/
int leftButton()
{
    return gKey == KEY_LEFT;
}

/******************************************************************************!
 * \fn okButton
 ******************************************************************************/
int okButton()
{
    return gKey == KEY_OK;
}

/******************************************************************************!
 * \fn rightButton
 ******************************************************************************/
int rightButton()
{
    return gKey == KEY_RIGHT;
}

/******************************************************************************!
 * \fn randButton
 ******************************************************************************/
int randButton()
{
    return gKey == KEY_SETUP;
}

/******************************************************************************!
 * \fn upButton
 ******************************************************************************/
int upButton()
{
    return gKey == KEY_UP;
}

/******************************************************************************!
 * \fn haltButton
 ******************************************************************************/
int haltButton()
{
    return gKey == KEY_MODE;
}

/******************************************************************************!
 * \fn backButton
 ******************************************************************************/
int backButton()
{
    return gKey == KEY_BACK;
}

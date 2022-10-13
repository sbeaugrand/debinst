/******************************************************************************!
 * \file setup.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdlib.h>

int okButton();
int randButton();
int upButton();
int downButton();
int leftButton();
int rightButton();
int haltButton();
int drawDate(int isDay);

/******************************************************************************!
 * \fn setupTime
 ******************************************************************************/
int setupTime()
{
    if (okButton()) {
        return 1;
    } else if (randButton()) {
        if (system("sudo /usr/sbin/rtc") == 0) {
            drawDate(0);
        }
    } else if (upButton()) {
        if (system("sudo /usr/sbin/rtc `date --date='+1 hour' +%FT%Tw%w`;"
                   " sudo /usr/sbin/rtc") == 0) {
            drawDate(0);
        }
    } else if (downButton()) {
        if (system("sudo /usr/sbin/rtc `date --date='-1 hour' +%FT%Tw%w`;"
                   " sudo /usr/sbin/rtc") == 0) {
            drawDate(0);
        }
    } else if (leftButton()) {
        if (system("sudo /usr/sbin/rtc `date --date='-1 min' +%FT%Tw%w`;"
                   " sudo /usr/sbin/rtc") == 0) {
            drawDate(0);
        }
    } else if (rightButton()) {
        if (system("sudo /usr/sbin/rtc `date --date='+1 min' +%FT%Tw%w`;"
                   " sudo /usr/sbin/rtc") == 0) {
            drawDate(0);
        }
    } else if (haltButton()) {
        if (system("sudo /usr/sbin/shutter-restart.sh") == 0) {
            drawDate(0);
        }
    }
    return 0;
}

/******************************************************************************!
 * \fn setupDate
 ******************************************************************************/
int setupDate()
{
    if (okButton()) {
        return 1;
    } else if (randButton()) {
        if (system("sudo /usr/sbin/rtc") == 0) {
            drawDate(1);
        }
    } else if (upButton()) {
        if (system("sudo /usr/sbin/rtc `date --date='+1 month' +%FT%Tw%w`;"
                   " sudo /usr/sbin/rtc") == 0) {
            drawDate(1);
        }
    } else if (downButton()) {
        if (system("sudo /usr/sbin/rtc `date --date='-1 month' +%FT%Tw%w`;"
                   " sudo /usr/sbin/rtc") == 0) {
            drawDate(1);
        }
    } else if (leftButton()) {
        if (system("sudo /usr/sbin/rtc `date --date='-1 day' +%FT%Tw%w`;"
                   " sudo /usr/sbin/rtc") == 0) {
            drawDate(1);
        }
    } else if (rightButton()) {
        if (system("sudo /usr/sbin/rtc `date --date='+1 day' +%FT%Tw%w`;"
                   " sudo /usr/sbin/rtc") == 0) {
            drawDate(1);
        }
    } else if (haltButton()) {
        if (system("sudo /usr/sbin/shutter-restart.sh") == 0) {
            drawDate(1);
        }
    }
    return 0;
}

/******************************************************************************!
 * \file mp3client.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef MP3CLIENT_H
#define MP3CLIENT_H

#define LINE_SIZE 256
#define LCD_COLS 16

void displayInit();
void displayWrite(const char* line1, const char* line2);
void displayQuit();

void keypadInit();
void keypadRead();
void keypadQuit();

int leftButton();
int downButton();
int rightButton();
int upButton();
int okButton();
int randButton();
int haltButton();

struct part_list {
    char abrev[3];
    char* name;
    struct part_list* next;
};

enum clientState {
    STATE0_NORMAL,
    STATE1_ALBUM,
    STATE2_ARTISTE,
    STATE3_ARTISTE,
    STATE4_DATE
};

#endif

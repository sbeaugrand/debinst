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

void displayWrite(const char* line1, const char* line2);
int leftButton();
int downButton();
int rightButton();
int upButton();
int okButton();
int randButton();
int haltButton();
int setupTime();
int setupDate();

#if defined(__arm__) || defined(__aarch64__)
void displayInit();
void displayQuit();
void keypadInit();
void keypadRead();
void keypadQuit();
int displayScreenSaver();
int backButton();
int undefinedButton();
#endif

struct part_list {
    char abrev[3];
    char* name;
    struct part_list* next;
};

#endif

/******************************************************************************!
 * \file mp3client-term.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <string.h>
#include "mp3client.h"
#include "common.h"

#define PP_STRINGIZE_I(x) #x
#define PP_STRINGIZE(x) PP_STRINGIZE_I(x)

char gInput[LINE_SIZE];

/******************************************************************************!
 * \fn displayInit
 ******************************************************************************/
void displayInit()
{
}

/******************************************************************************!
 * \fn displayWrite
 ******************************************************************************/
void displayWrite(const char* line1, const char* line2)
{
    char l1[LCD_COLS + 1];
    char l2[LCD_COLS + 1];

    snprintf(l1, LCD_COLS + 1, "%s", line1);
    snprintf(l2, LCD_COLS + 1, "%s", line2);
    fprintf(stderr, "### %-"PP_STRINGIZE (LCD_COLS) "s ###\n", l1);
    fprintf(stderr, "### %-"PP_STRINGIZE (LCD_COLS) "s ###\n", l2);
}

/******************************************************************************!
 * \fn getInput
 ******************************************************************************/
char* getInput()
{
    static char lInputPrev[LINE_SIZE] = {
        0
    };

    if (fgets(gInput, 255, stdin) == NULL) {
        ERROR("fgets == NULL");
        *gInput = '\0';
        return gInput;
    }
    gInput[strlen(gInput) - 1] = '\0';
    if (*gInput == '\0') {
        strcpy(gInput, lInputPrev);
    } else {
        strcpy(lInputPrev, gInput);
    }

    return gInput;
}

/******************************************************************************!
 * \fn leftButton
 ******************************************************************************/
int leftButton()
{
    return strcmp(gInput, "l") == 0;
}

/******************************************************************************!
 * \fn downButton
 ******************************************************************************/
int downButton()
{
    return strcmp(gInput, "d") == 0;
}

/******************************************************************************!
 * \fn rightButton
 ******************************************************************************/
int rightButton()
{
    return strcmp(gInput, "r") == 0;
}

/******************************************************************************!
 * \fn upButton
 ******************************************************************************/
int upButton()
{
    return strcmp(gInput, "u") == 0;
}

/******************************************************************************!
 * \fn okButton
 ******************************************************************************/
int okButton()
{
    return strcmp(gInput, "ok") == 0;
}

/******************************************************************************!
 * \fn randButton
 ******************************************************************************/
int randButton()
{
    return strcmp(gInput, "rand") == 0;
}

/******************************************************************************!
 * \fn haltButton
 ******************************************************************************/
int haltButton()
{
    return strcmp(gInput, "halt") == 0;
}

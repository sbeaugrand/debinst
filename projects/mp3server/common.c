/******************************************************************************!
 * \file common.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "common.h"

/******************************************************************************!
 * \fn bufferNew
 ******************************************************************************/
struct Buffer*
bufferNew()
{
    struct Buffer* b = malloc(sizeof(struct Buffer));
    if (b == NULL) {
        return NULL;
    }
    b->file = NULL;
    b->ptr = NULL;
    b->size = 0;
    return b;
}

/******************************************************************************!
 * \fn bufferInit
 ******************************************************************************/
FILE*
bufferInit(struct Buffer* b)
{
    if (b == NULL) {
        return NULL;
    }
    if (b->file == NULL) {
        b->file = open_memstream(&b->ptr, &b->size);
    } else {
        rewind(b->file);
    }
    return b->file;
}

/******************************************************************************!
 * \fn bufferQuit
 ******************************************************************************/
void
bufferQuit(struct Buffer* b)
{
    if (b == NULL) {
        return;
    }
    if (b->file != NULL) {
        fclose(b->file);
    }
    if (b->ptr != NULL) {
        free(b->ptr);
        b->ptr = NULL;
    }
}

/******************************************************************************!
 * \fn bufferGet
 ******************************************************************************/
char*
bufferGet(struct Buffer* b)
{
    if (b == NULL) {
        return NULL;
    }
    if (b->file != NULL) {
        fflush(b->file);
        //FIXME
        b->ptr[b->size] = '\0';
    }
    return b->ptr;
}

/******************************************************************************!
 * \fn getTimestamp
 ******************************************************************************/
const char*
getTimestamp()
{
    static char timestamp[20];
    time_t t;
    struct tm* l;

    t = time(NULL);
    l = localtime(&t);
    strftime(timestamp, sizeof(timestamp), "%F %T", l);

    return timestamp;
}

/******************************************************************************!
 * \fn nanoSleep
 ******************************************************************************/
void
nanoSleep(long nanoseconds)
{
    struct timespec req = {
        0, nanoseconds
    };

    nanosleep(&req, NULL);
}

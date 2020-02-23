/******************************************************************************!
 * \file common.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef COMMON_H
#define COMMON_H
#include <stdio.h>
#define DEBUG_WITH_TIMESTAMP
#include "debug.h"

struct Buffer {
    FILE* file;
    char* ptr;
    size_t size;
};

struct Buffer* bufferNew();
FILE* bufferInit(struct Buffer* b);
void bufferQuit(struct Buffer* b);
char* bufferGet(struct Buffer* b);
const char* getTimestamp();
void nanoSleep(long nanoseconds);

#endif

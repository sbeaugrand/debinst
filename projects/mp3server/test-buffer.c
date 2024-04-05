/******************************************************************************!
 * \file test-buffer.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "common.h"

/******************************************************************************!
 * \fn checkSize
 ******************************************************************************/
void
checkSize(struct Buffer* b, size_t val)
{
    //size_t s = strlen(bufferGet(b));
    bufferGet(b);
    size_t s = b->size;

    if (s != val) {
        fprintf(stderr, "error: %zu != %zu\n", s, val);
        bufferQuit(b);
        free(b);
        exit(EXIT_FAILURE);
    }
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main()
{
    FILE* f;
    struct Buffer* b = bufferNew();

    f = bufferInit(b);
    fprintf(f, "azertyuiop");
    checkSize(b, 10);

    fseek(f, 7, SEEK_SET);
    checkSize(b, 7);

    bufferInit(b);
    checkSize(b, 0);

    fprintf(f, "azerty");
    checkSize(b, 6);

    bufferQuit(b);
    free(b);
    return EXIT_SUCCESS;
}

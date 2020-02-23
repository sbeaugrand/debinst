/******************************************************************************!
 * \file test-rand.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main(int argc, char* argv[])
{
    char line[256];
    FILE* f;
    long ref;
    long cur;
    long pre;
    int cnt;
    int err;

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <.mp3rand-file>\n", argv[0]);
        return EXIT_FAILURE;
    }

    f = fopen(argv[1], "r");
    if (f == NULL) {
        return EXIT_FAILURE;
    }

    ref = 0;
    cnt = 0;
    err = 0;
    while (++cnt, fgets(line, 256, f) != NULL) {
        if (ref == 0) {
            ref = atol(line);
            srand(ref);
        } else {
            pre = ref;
            ref = atol(line);
            cur = rand();
            if (cur != ref) {
                srand(pre);
                cur = rand();
                if (cur != ref) {
                    fprintf(stderr,
                            "error: line %d (%ld != %ld)\n", cnt, cur, ref);
                    ++err;
                }
            }
        }
    }

    fclose(f);

    if (err) {
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}

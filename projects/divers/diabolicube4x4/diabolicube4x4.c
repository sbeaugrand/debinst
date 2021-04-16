/******************************************************************************!
 * \file diabolicube4x4.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note gcc -Wall -Wextra -O3 -o diabolicube4x4 diabolicube4x4.c
 *       ./diabolicube4x4 | tee diabolicube4x4.log
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

#define min(a, b) ((a < b) ? a : b)
#define max(a, b) ((a < b) ? b : a)

int dirs[64] = {
    0, 1, 0, 0, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 0, 1,
    1, 0, 0, 1, 1, 1, 1, 0,
    0, 1, 0, 1, 1, 1, 1, 1,
    1, 0, 1, 0, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 0, 1, 1,
    0, 1, 1, 0, 1, 1, 0, 0,
    1, 1, 1, 0, 1, 1, 0, 0
};

struct piece {
    int rot;
    int dir;
    int x;
    int y;
    int z;
};

struct piece piece[64];
int cube[8 * 8 * 8] = {
    0
};
long iter = 0;
int pos;
int xmin;
int xmax;
int ymin;
int ymax;
int zmin;
int zmax;


/******************************************************************************!
 * \fn getX
 ******************************************************************************/
int getX(int dir)
{
    switch (dir) {
    case 0:
        return 1;
    case 1:
        return -1;
    default:
        return 0;
    }
}

/******************************************************************************!
 * \fn getY
 ******************************************************************************/
int getY(int dir)
{
    switch (dir) {
    case 2:
        return 1;
    case 3:
        return -1;
    default:
        return 0;
    }
}

/******************************************************************************!
 * \fn getZ
 ******************************************************************************/
int getZ(int dir)
{
    switch (dir) {
    case 4:
        return 1;
    case 5:
        return -1;
    default:
        return 0;
    }
}

/******************************************************************************!
 * \fn printCube
 ******************************************************************************/
void printCube(int pos)
{
    int i;

    fprintf(stdout, "iter = %ld\n", iter);
    for (i = 0; i <= pos; ++i) {
        fprintf(stdout,
                "%d %d %d %d %d\n",
                piece[i].rot,
                piece[i].dir,
                piece[i].x,
                piece[i].y,
                piece[i].z);
    }
    fflush(stdout);
}

/******************************************************************************!
 * \fn controlC
 ******************************************************************************/
void controlC(int sig)
{
    if (sig == SIGINT) {
        printCube(min(pos, 63));
        exit(EXIT_FAILURE);
    }
}

/******************************************************************************!
 * \fn minmax
 ******************************************************************************/
void minmax(int pos)
{
    int i;

    xmin = 3;
    xmax = 3;
    ymin = 3;
    ymax = 3;
    zmin = 3;
    zmax = 3;
    for (i = 0; i <= pos; ++i) {
        xmin = min(xmin, piece[i].x);
        xmax = max(xmax, piece[i].x);
        ymin = min(ymin, piece[i].y);
        ymax = max(ymax, piece[i].y);
        zmin = min(zmin, piece[i].z);
        zmax = max(zmax, piece[i].z);
    }
}

/******************************************************************************!
 * \fn dirxyz
 ******************************************************************************/
void dirxyz(int pos)
{
    //if (dirs[pos + 1]) {
    if (dirs[63 - pos - 1]) {
        if (piece[pos + 1].rot == 0) {
            switch (piece[pos].dir) {
            case 0: piece[pos + 1].dir = 2; break;
            case 1: piece[pos + 1].dir = 3; break;
            case 2: piece[pos + 1].dir = 4; break;
            case 3: piece[pos + 1].dir = 5; break;
            case 4: piece[pos + 1].dir = 0; break;
            case 5: piece[pos + 1].dir = 1; break;
            }
        } else if (piece[pos + 1].rot == 1)   {
            switch (piece[pos].dir) {
            case 0: piece[pos + 1].dir = 3; break;
            case 1: piece[pos + 1].dir = 4; break;
            case 2: piece[pos + 1].dir = 5; break;
            case 3: piece[pos + 1].dir = 0; break;
            case 4: piece[pos + 1].dir = 1; break;
            case 5: piece[pos + 1].dir = 2; break;
            }
        } else if (piece[pos + 1].rot == 2)   {
            switch (piece[pos].dir) {
            case 0: piece[pos + 1].dir = 4; break;
            case 1: piece[pos + 1].dir = 5; break;
            case 2: piece[pos + 1].dir = 0; break;
            case 3: piece[pos + 1].dir = 1; break;
            case 4: piece[pos + 1].dir = 2; break;
            case 5: piece[pos + 1].dir = 3; break;
            }
        } else if (piece[pos + 1].rot == 3)   {
            switch (piece[pos].dir) {
            case 0: piece[pos + 1].dir = 5; break;
            case 1: piece[pos + 1].dir = 2; break;
            case 2: piece[pos + 1].dir = 1; break;
            case 3: piece[pos + 1].dir = 4; break;
            case 4: piece[pos + 1].dir = 3; break;
            case 5: piece[pos + 1].dir = 0; break;
            }
        } else {
            fprintf(stdout, "error: rot=%d\n", piece[pos + 1].rot);
            controlC(SIGINT);
        }
        piece[pos + 1].x = piece[pos].x + getX(piece[pos].dir);
        piece[pos + 1].y = piece[pos].y + getY(piece[pos].dir);
        piece[pos + 1].z = piece[pos].z + getZ(piece[pos].dir);
    } else {
        piece[pos + 1].rot = 0;
        piece[pos + 1].dir = piece[pos].dir;
        piece[pos + 1].x = piece[pos].x + getX(piece[pos].dir);
        piece[pos + 1].y = piece[pos].y + getY(piece[pos].dir);
        piece[pos + 1].z = piece[pos].z + getZ(piece[pos].dir);
    }
}

/******************************************************************************!
 * \fn retour
 ******************************************************************************/
void retour()
{
    int cubepos;

    //while ((dirs[pos] && piece[pos].rot == 3) ||
    //       (dirs[pos] == 0)) {
    while ((dirs[63 - pos] && piece[pos].rot == 3) ||
           (dirs[63 - pos] == 0)) {
        piece[pos].rot = 0;
        cubepos = piece[pos].x + (piece[pos].y << 3) + (piece[pos].z << 6);
        cube[cubepos] = 0;
        --pos;
        if (pos == 0) {
            fprintf(stdout, "error: 1\n");
            controlC(SIGINT);
        }
    }
    piece[pos].rot++;
    dirxyz(pos - 1);
    minmax(pos);
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main()
{
    int cubepos;

    if (signal(SIGINT, controlC) == SIG_ERR) {
        return EXIT_FAILURE;
    }

    for (pos = 0; pos < 64; ++pos) {
        piece[pos].rot = 0;
    }
    pos = 0;

    piece[pos].rot = 0;
    piece[pos].dir = 0;
    piece[pos].x = 3;
    piece[pos].y = 3;
    piece[pos].z = 3;
    cubepos = piece[pos].x + (piece[pos].y << 3) + (piece[pos].z << 6);
    cube[cubepos] = 1;
    xmin = 3;
    xmax = 3;
    ymin = 3;
    ymax = 3;
    zmin = 3;
    zmax = 3;
    while (pos < 63) {
        dirxyz(pos);
        if (abs(piece[pos + 1].x - xmin) >= 4 ||
            abs(piece[pos + 1].x - xmax) >= 4 ||
            abs(piece[pos + 1].y - ymin) >= 4 ||
            abs(piece[pos + 1].y - ymax) >= 4 ||
            abs(piece[pos + 1].z - zmin) >= 4 ||
            abs(piece[pos + 1].z - zmax) >= 4) {
            retour();
        } else {
            cubepos = piece[pos + 1].x + (piece[pos + 1].y << 3) +
                (piece[pos + 1].z << 6);
            if (cube[cubepos]) {
                retour();
            } else {
                cube[cubepos] = 1;
                if (pos < 62) {
                    ++pos;
                    xmin = min(xmin, piece[pos].x);
                    xmax = max(xmax, piece[pos].x);
                    ymin = min(ymin, piece[pos].y);
                    ymax = max(ymax, piece[pos].y);
                    zmin = min(zmin, piece[pos].z);
                    zmax = max(zmax, piece[pos].z);
                } else {
                    printCube(63);
                    retour();
                }
            }
        }
        ++iter;
    }

    controlC(SIGINT);

    return EXIT_SUCCESS;
}
/*
iter = 2609725230
0 0 3 3 3
0 2 4 3 3
0 2 4 4 3
0 2 4 5 3
3 1 4 6 3
1 4 3 6 3
0 0 3 6 4
1 3 4 6 4
2 1 4 5 4
2 5 3 5 4
2 3 3 5 3
3 4 3 4 3
3 3 3 4 4
1 0 3 3 4
0 0 4 3 4
3 5 5 3 4
1 2 5 3 3
0 2 5 4 3
0 2 5 5 3
0 4 5 6 3
0 0 5 6 4
3 5 6 6 4
2 3 6 6 3
0 3 6 5 3
0 3 6 4 3
3 4 6 3 3
0 4 6 3 4
2 2 6 3 5
1 5 6 4 5
1 2 6 4 4
3 1 6 5 4
1 4 5 5 4
1 1 5 5 5
0 1 4 5 5
0 3 3 5 5
0 3 3 4 5
3 4 3 3 5
0 0 3 3 6
3 5 4 3 6
3 0 4 3 5
2 4 5 3 5
0 0 5 3 6
0 2 6 3 6
3 1 6 4 6
2 5 5 4 6
0 5 5 4 5
0 1 5 4 4
1 4 4 4 4
0 4 4 4 5
1 1 4 4 6
3 2 3 4 6
0 2 3 5 6
1 5 3 6 6
3 0 3 6 5
0 0 4 6 5
0 0 5 6 5
1 3 6 6 5
3 4 6 5 5
1 1 6 5 6
0 1 5 5 6
3 2 4 5 6
2 0 4 6 6
0 0 5 6 6
0 0 6 6 6
iter = 2641456934
0 0 3 3 3
0 2 4 3 3
0 2 4 4 3
0 2 4 5 3
3 1 4 6 3
1 4 3 6 3
0 0 3 6 4
2 4 4 6 4
1 1 4 6 5
0 3 3 6 5
2 1 3 5 5
2 5 2 5 5
0 1 2 5 4
1 4 1 5 4
0 4 1 5 5
2 2 1 5 6
1 5 1 6 6
0 5 1 6 5
0 5 1 6 4
2 3 1 6 3
1 0 1 5 3
0 2 2 5 3
0 4 2 6 3
0 4 2 6 4
0 4 2 6 5
0 0 2 6 6
0 0 3 6 6
1 3 4 6 6
0 5 4 5 6
2 3 4 5 5
3 4 4 4 5
3 3 4 4 6
0 5 4 3 6
0 5 4 3 5
1 2 4 3 4
0 2 4 4 4
3 1 4 5 4
2 5 3 5 4
2 3 3 5 3
3 4 3 4 3
3 3 3 4 4
3 4 3 3 4
2 2 3 3 5
3 1 3 4 5
2 5 2 4 5
0 5 2 4 4
2 3 2 4 3
3 4 2 3 3
0 4 2 3 4
1 1 2 3 5
2 5 1 3 5
0 5 1 3 4
1 2 1 3 3
0 4 1 4 3
0 4 1 4 4
0 4 1 4 5
3 3 1 4 6
1 0 1 3 6
0 2 2 3 6
0 2 2 4 6
2 0 2 5 6
1 3 3 5 6
0 3 3 4 6
0 3 3 3 6
iter = 2913612187
0 0 3 3 3
0 2 4 3 3
0 2 4 4 3
0 2 4 5 3
3 1 4 6 3
2 5 3 6 3
2 3 3 6 2
2 1 3 5 2
0 3 2 5 2
1 0 2 4 2
2 4 3 4 2
2 2 3 4 3
3 1 3 5 3
0 3 2 5 3
0 3 2 4 3
2 1 2 3 3
3 2 1 3 3
0 2 1 4 3
0 2 1 5 3
2 0 1 6 3
3 5 2 6 3
0 1 2 6 2
0 3 1 6 2
0 3 1 5 2
0 3 1 4 2
0 5 1 3 2
0 5 1 3 1
1 2 1 3 0
0 4 1 4 0
0 0 1 4 1
3 5 2 4 1
2 3 2 4 0
3 4 2 3 0
0 4 2 3 1
0 0 2 3 2
0 0 3 3 2
3 5 4 3 2
0 1 4 3 1
2 5 3 3 1
3 0 3 3 0
0 2 4 3 0
3 1 4 4 0
1 4 3 4 0
2 2 3 4 1
3 1 3 5 1
0 1 2 5 1
3 2 1 5 1
2 0 1 6 1
0 0 2 6 1
3 5 3 6 1
0 1 3 6 0
0 1 2 6 0
0 3 1 6 0
1 0 1 5 0
0 0 2 5 0
0 0 3 5 0
0 2 4 5 0
0 4 4 6 0
3 3 4 6 1
0 3 4 5 1
3 4 4 4 1
2 2 4 4 2
0 2 4 5 2
0 2 4 6 2
iter = 4337191849
0 0 3 3 3
1 3 4 3 3
0 3 4 2 3
0 3 4 1 3
2 1 4 0 3
2 5 3 0 3
1 2 3 0 2
0 4 3 1 2
2 2 3 1 3
1 5 3 2 3
0 1 3 2 2
0 3 2 2 2
3 4 2 1 2
2 2 2 1 3
0 2 2 2 3
3 1 2 3 3
0 3 1 3 3
0 3 1 2 3
0 3 1 1 3
1 0 1 0 3
3 5 2 0 3
0 1 2 0 2
3 2 1 0 2
0 2 1 1 2
0 2 1 2 2
1 5 1 3 2
0 5 1 3 1
2 3 1 3 0
3 4 1 2 0
0 0 1 2 1
3 5 2 2 1
1 2 2 2 0
0 4 2 3 0
0 4 2 3 1
0 0 2 3 2
0 0 3 3 2
3 5 4 3 2
0 1 4 3 1
2 5 3 3 1
3 0 3 3 0
1 3 4 3 0
2 1 4 2 0
1 4 3 2 0
3 3 3 2 1
2 1 3 1 1
0 1 2 1 1
0 3 1 1 1
1 0 1 0 1
0 0 2 0 1
3 5 3 0 1
0 1 3 0 0
0 1 2 0 0
3 2 1 0 0
2 0 1 1 0
0 0 2 1 0
0 0 3 1 0
1 3 4 1 0
3 4 4 0 0
2 2 4 0 1
0 2 4 1 1
0 4 4 2 1
3 3 4 2 2
0 3 4 1 2
0 3 4 0 2
iter = 7594227440
*/

/*
iter = 709880268
0 0 3 3 3
0 0 4 3 3
0 2 5 3 3
3 1 5 4 3
0 1 4 4 3
1 4 3 4 3
3 3 3 4 4
1 0 3 3 4
0 0 4 3 4
0 0 5 3 4
3 5 6 3 4
1 2 6 3 3
0 2 6 4 3
3 1 6 5 3
1 4 5 5 3
0 4 5 5 4
1 1 5 5 5
2 5 4 5 5
0 5 4 5 4
0 1 4 5 3
3 2 3 5 3
2 0 3 6 3
2 4 4 6 3
0 0 4 6 4
3 5 5 6 4
3 0 5 6 3
2 4 6 6 3
3 3 6 6 4
0 3 6 5 4
2 1 6 4 4
0 1 5 4 4
1 4 4 4 4
1 1 4 4 5
3 2 3 4 5
1 5 3 5 5
1 2 3 5 4
0 4 3 6 4
0 4 3 6 5
3 3 3 6 6
0 3 3 5 6
0 3 3 4 6
0 5 3 3 6
3 0 3 3 5
2 4 4 3 5
2 2 4 3 6
0 2 4 4 6
0 2 4 5 6
1 5 4 6 6
3 0 4 6 5
0 0 5 6 5
1 3 6 6 5
3 4 6 5 5
3 3 6 5 6
0 5 6 4 6
0 1 6 4 5
0 3 5 4 5
1 0 5 3 5
2 4 6 3 5
1 1 6 3 6
3 2 5 3 6
0 2 5 4 6
0 2 5 5 6
2 0 5 6 6
0 0 6 6 6
iter = 815290103
0 0 3 3 3
0 0 4 3 3
0 2 5 3 3
3 1 5 4 3
0 1 4 4 3
2 5 3 4 3
2 3 3 4 2
1 0 3 3 2
0 0 4 3 2
0 0 5 3 2
2 4 6 3 2
2 2 6 3 3
0 2 6 4 3
3 1 6 5 3
2 5 5 5 3
0 5 5 5 2
0 1 5 5 1
1 4 4 5 1
0 4 4 5 2
1 1 4 5 3
3 2 3 5 3
2 0 3 6 3
3 5 4 6 3
3 0 4 6 2
2 4 5 6 2
0 0 5 6 3
3 5 6 6 3
2 3 6 6 2
0 3 6 5 2
2 1 6 4 2
0 1 5 4 2
2 5 4 4 2
0 1 4 4 1
3 2 3 4 1
0 4 3 5 1
2 2 3 5 2
1 5 3 6 2
0 5 3 6 1
2 3 3 6 0
0 3 3 5 0
0 3 3 4 0
3 4 3 3 0
0 0 3 3 1
3 5 4 3 1
1 2 4 3 0
0 2 4 4 0
0 2 4 5 0
0 4 4 6 0
0 0 4 6 1
0 0 5 6 1
1 3 6 6 1
0 5 6 5 1
2 3 6 5 0
3 4 6 4 0
1 1 6 4 1
0 3 5 4 1
1 0 5 3 1
3 5 6 3 1
0 1 6 3 0
3 2 5 3 0
0 2 5 4 0
0 2 5 5 0
2 0 5 6 0
0 0 6 6 0
iter = 982796476
0 0 3 3 3
0 0 4 3 3
0 2 5 3 3
3 1 5 4 3
0 1 4 4 3
3 2 3 4 3
2 0 3 5 3
2 4 4 5 3
0 4 4 5 4
0 4 4 5 5
1 1 4 5 6
2 5 3 5 6
0 5 3 5 5
2 3 3 5 4
3 4 3 4 4
0 4 3 4 5
0 0 3 4 6
3 5 4 4 6
0 5 4 4 5
2 3 4 4 4
2 1 4 3 4
1 4 3 3 4
0 0 3 3 5
2 4 4 3 5
0 0 4 3 6
3 5 5 3 6
2 3 5 3 5
2 1 5 2 5
0 1 4 2 5
2 5 3 2 5
0 5 3 2 4
3 0 3 2 3
2 4 4 2 3
0 0 4 2 4
3 5 5 2 4
3 0 5 2 3
0 2 6 2 3
0 2 6 3 3
0 4 6 4 3
0 4 6 4 4
0 4 6 4 5
1 1 6 4 6
3 2 5 4 6
2 0 5 5 6
3 5 6 5 6
0 5 6 5 5
0 5 6 5 4
0 1 6 5 3
1 4 5 5 3
0 4 5 5 4
3 3 5 5 5
0 5 5 4 5
2 3 5 4 4
1 0 5 3 4
1 3 6 3 4
3 4 6 2 4
2 2 6 2 5
0 4 6 3 5
3 3 6 3 6
2 1 6 2 6
0 1 5 2 6
0 1 4 2 6
3 2 3 2 6
0 2 3 3 6
iter = 1003757368
0 0 3 3 3
0 0 4 3 3
0 2 5 3 3
3 1 5 4 3
0 1 4 4 3
3 2 3 4 3
2 0 3 5 3
3 5 4 5 3
0 5 4 5 2
0 5 4 5 1
0 1 4 5 0
1 4 3 5 0
0 4 3 5 1
3 3 3 5 2
0 5 3 4 2
0 5 3 4 1
3 0 3 4 0
2 4 4 4 0
0 4 4 4 1
0 0 4 4 2
0 2 5 4 2
0 4 5 5 2
0 0 5 5 3
3 5 6 5 3
2 3 6 5 2
3 4 6 4 2
3 3 6 4 3
0 5 6 3 3
0 5 6 3 2
1 2 6 3 1
0 2 6 4 1
3 1 6 5 1
0 3 5 5 1
0 5 5 4 1
1 2 5 4 0
2 0 5 5 0
1 3 6 5 0
0 3 6 4 0
2 1 6 3 0
0 1 5 3 0
0 1 4 3 0
1 4 3 3 0
3 3 3 3 1
0 5 3 2 1
3 0 3 2 0
0 0 4 2 0
0 0 5 2 0
2 4 6 2 0
1 1 6 2 1
0 1 5 2 1
1 4 4 2 1
0 0 4 2 2
0 2 5 2 2
1 5 5 3 2
0 1 5 3 1
1 4 4 3 1
1 1 4 3 2
0 3 3 3 2
3 4 3 2 2
0 0 3 2 3
0 0 4 2 3
0 0 5 2 3
3 5 6 2 3
0 5 6 2 2
iter = 2013249651
0 0 3 3 3
0 0 4 3 3
2 4 5 3 3
1 1 5 3 4
0 1 4 3 4
1 4 3 3 4
0 0 3 3 5
0 2 4 3 5
0 2 4 4 5
0 2 4 5 5
3 1 4 6 5
0 3 3 6 5
0 3 3 5 5
0 5 3 4 5
1 2 3 4 4
0 2 3 5 4
2 0 3 6 4
1 3 4 6 4
0 3 4 5 4
0 5 4 4 4
0 1 4 4 3
3 2 3 4 3
2 0 3 5 3
0 2 4 5 3
2 0 4 6 3
1 3 5 6 3
0 5 5 5 3
0 1 5 5 2
0 1 4 5 2
0 3 3 5 2
0 3 3 4 2
1 0 3 3 2
0 2 4 3 2
2 0 4 4 2
1 3 5 4 2
1 0 5 3 2
2 4 6 3 2
0 4 6 3 3
2 2 6 3 4
0 2 6 4 4
0 2 6 5 4
3 1 6 6 4
1 4 5 6 4
0 0 5 6 5
1 3 6 6 5
0 3 6 5 5
0 3 6 4 5
2 1 6 3 5
3 2 5 3 5
0 2 5 4 5
1 5 5 5 5
2 3 5 5 4
0 5 5 4 4
3 0 5 4 3
3 5 6 4 3
1 2 6 4 2
0 4 6 5 2
2 2 6 5 3
1 5 6 6 3
0 1 6 6 2
0 1 5 6 2
0 1 4 6 2
1 4 3 6 2
0 4 3 6 3
iter = 3288446352
*/

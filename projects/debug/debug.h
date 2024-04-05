/******************************************************************************!
 * \file debug.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#if ! defined(NERROR) || ! defined(NDEBUG)
# include <stdio.h>
#endif

#ifdef DEBUG_WITH_TIMESTAMP

#ifndef NERROR
# define ERROR(f, ...) fprintf(stderr, "[%s] error: %s: "f "\n", \
                               getTimestamp(), __func__, ## __VA_ARGS__)
# ifndef NERRNO
#  include <errno.h>
#  include <string.h>
#  define ERRNO(f, ...) fprintf(stderr, \
                                "[%s] error: %s: "f " (%d: %s)\n", \
                                getTimestamp(), \
                                __func__, \
                                ## __VA_ARGS__, \
                                errno, \
                                strerror(errno))
# else
#  define ERRNO(f, ...) fprintf(stderr, "error: "f "\n", ## __VA_ARGS__)
# endif
# define ERROR_UNUSED
#else
# define ERROR(f, ...)
# define ERROR_UNUSED __attribute__((__unused__))
# define ERRNO(f, ...)
# define ERRNO_UNUSED __attribute__((__unused__))
#endif
#ifndef NDEBUG
# define DEBUG(f, ...) fprintf(stderr, "[%s] debug: %s: "f "\n", \
                               getTimestamp(), __func__, ## __VA_ARGS__)
# define DEBUG_UNUSED
#else
# define DEBUG(f, ...)
# define DEBUG_UNUSED __attribute__((__unused__))
#endif
const char* getTimestamp();
/* Example
 #include <time.h>
   const char* getTimestamp()
   {
    static char timestamp[20];
    time_t t;
    struct tm* l;

    t = time(NULL);
    l = localtime(&t);
    strftime(timestamp, sizeof(timestamp), "%F %T", l);

    return timestamp;
   }
 */

#else

#ifndef NERROR
# define ERROR(f, ...) fprintf(stderr, "error: "f "\n", ## __VA_ARGS__)
# ifndef NERRNO
#  include <errno.h>
#  include <string.h>
#  define ERRNO(f, ...) fprintf(stderr, "error: "f " (%d: %s)\n", \
                                ## __VA_ARGS__, errno, strerror(errno))
# else
#  define ERRNO(f, ...) fprintf(stderr, "error: "f "\n", ## __VA_ARGS__)
# endif
# define ERROR_UNUSED
#else
# define ERROR(f, ...)
# define ERROR_UNUSED __attribute__((__unused__))
# define ERRNO(f, ...)
# define ERRNO_UNUSED __attribute__((__unused__))
#endif

#ifndef NDEBUG
# define DEBUG(f, ...) fprintf(stderr, "debug: "f "\n", ## __VA_ARGS__)
# define DEBUG_UNUSED
#else
# define DEBUG(f, ...)
# define DEBUG_UNUSED __attribute__((__unused__))
#endif

#endif

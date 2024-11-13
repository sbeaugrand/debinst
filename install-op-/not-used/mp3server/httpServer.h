/******************************************************************************!
 * \file httpServer.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef HTTPSERVER_H
#define HTTPSERVER_H
#include "common.h"

enum tFormat {
    RAW,
    HTML
};

void httpInit();
void httpAddResource(const char* name, void* func);
unsigned int
httpSendResource(int sockClient, const char* resourceName,
                 struct Buffer* buffer, enum tFormat format);
const char* getResourceName(const char* buffer);
const char* getResourceParam(const char* buffer, const char* param);
void httpRunServer(struct Buffer* buffer);
const char* httpGetHttpOk();
size_t httpGetHttpOkSize();
void httpQuit();

#endif

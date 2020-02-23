/******************************************************************************!
 * \file html.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef HTML_H
#define HTML_H

#define DIR_PAGE_NB 3

const char* htmlGetBegin();
const char* htmlGetEnd();
const char* htmlGetEmpty();
const char* htmlGetTableBegin();
const char* htmlGetTableNewTd();
const char* htmlGetTableEnd();
const char* htmlGetHrefDir();
const char* htmlGetHrefAlbum();

#endif

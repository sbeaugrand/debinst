/******************************************************************************!
 * \file html.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
const int DIR_PAGE_NB = 3;

/******************************************************************************!
 * \fn htmlGetBegin
 ******************************************************************************/
const char* htmlGetBegin()
{
    static const char* r =
        "<html><head><title>RPI</title>"
        "<link rel=\"icon\" href=\"data:;base64,=\"></head>"
        "<body text=#ffffff bgcolor=#000000"
        " link=#00ffff vlink=#00ffff alink=#ff0000>"
        "<table><tr><td>"
        "<a href=/list?format=html>list</a>"
        "</td><td>&nbsp;</td><td>"
        "<a href=/play?format=html>play</a>"
        "</td><td width=100% align=right>"
        "<a href=/halt?format=html>halt</a>"
        "</td></tr><tr><td>"
        "<a href=/rand?format=html>rand</a>"
        "</td><td></td><td>"
        "<a href=/pause?format=html>pause</a>"
        "</td><td align=right>"
        "<a href=/kill?format=html>kill</a>"
        "</td></tr><tr><td>"
        "<a href=/info?format=html>info</a>"
        "</td><td></td><td>"
        "<a href=/stop?format=html>stop</a>"
        "</td><td align=right>"
        "<a href=/date?format=html>date</a>"
        "</td></tr><tr><td>"
        "<a href=/dir/>dir</a>"
        "</td><td></td><td>"
        "<a href=/resume?format=html>resume</a>"
        "</td><td align=right>"
        "<a href=/last?format=html>last</a>"
        "</td></tr><tr><td>"
        "</td><td></td><td>"
        "</td><td align=right>"
        "<a href=/log?format=html>log</a>"
        "</td></tr></table>"
        "<pre>";
    return r;
}

/******************************************************************************!
 * \fn htmlGetHtmlEnd
 ******************************************************************************/
const char* htmlGetEnd()
{
    static const char* r = "</pre></body></html>";
    return r;
}

/******************************************************************************!
 * \fn htmlGetEmpty
 ******************************************************************************/
const char* htmlGetEmpty()
{
    static const char* r =
        "<html><head><title>RPI</title></head>"
        "<body bgcolor=\"#000000\"><pre>";
    return r;
}

/******************************************************************************!
 * \fn htmlGetTableBegin
 ******************************************************************************/
const char* htmlGetTableBegin()
{
    static const char* r = "<table><tr><td valign=\"top\">";
    return r;
}

/******************************************************************************!
 * \fn htmlGetTableNewTd
 ******************************************************************************/
const char* htmlGetTableNewTd()
{
    static const char* r = "</td><td valign=\"top\">";
    return r;
}

/******************************************************************************!
 * \fn htmlGetTableEnd
 ******************************************************************************/
const char* htmlGetTableEnd()
{
    static const char* r = "</td></tr></table>";
    return r;
}

/******************************************************************************!
 * \fn htmlGetHrefDir
 ******************************************************************************/
const char* htmlGetHrefDir()
{
    static const char* r = "<a href=\"/dir/";
    return r;
}

/******************************************************************************!
 * \fn htmlGetHrefAlbum
 ******************************************************************************/
const char* htmlGetHrefAlbum()
{
    static const char* r = "<a href=\"/album/";
    return r;
}

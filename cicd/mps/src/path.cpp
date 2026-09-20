/******************************************************************************!
 * \file path.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "path.h"

/******************************************************************************!
 * \fn splitPath
 ******************************************************************************/
std::tuple<std::string, std::string, std::string>
splitPath(const std::string& path)
{
    auto pos4 = path.rfind('/');
    auto pos1 = path.rfind('/', pos4 - 1) + 1;
    auto pos2 = path.find(" - ", pos1);
    auto arti = path.substr(pos1, pos2 - pos1);
    pos2 += 3;
    auto pos3 = path.find(" - ", pos2);
    auto date = path.substr(pos2, pos3 - pos2);
    pos3 += 3;
    auto albu = path.substr(pos3, pos4 - pos3);
    return { arti, date, albu };
}

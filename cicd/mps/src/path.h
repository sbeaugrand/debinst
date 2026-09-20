/******************************************************************************!
 * \file path.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#pragma once
#include <string>
#include <tuple>

std::tuple<std::string, std::string, std::string>
splitPath(const std::string& path);

/******************************************************************************!
 * \file log.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#pragma once
#if ! defined(NERROR) || ! defined(NDEBUG)
# include <iostream>
#endif

consteval std::string_view
method_name(const char* s)
{
    std::string_view prettyFunction(s);
    size_t bracket = prettyFunction.rfind("(");
    size_t space = prettyFunction.rfind(" ", bracket) + 1;
    return prettyFunction.substr(space, bracket - space);
}
#define __METHOD__ method_name(__PRETTY_FUNCTION__)

#ifndef NERROR
# define ERROR(s) std::cerr << "error: " << __METHOD__ << " " << s << std::endl
#endif
#ifndef NDEBUG
# define DEBUG(s) std::cout << "debug: " << __METHOD__ << " " << s << std::endl
#endif

/******************************************************************************!
 * \file Terminal.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#pragma once
#include <iostream>

namespace mraa {
typedef enum {
    SUCCESS = 0
} Result;
}

/******************************************************************************!
 * \class Terminal
 ******************************************************************************/
class Terminal
{
public:
    Terminal() {}
    ~Terminal() {}
    mraa::Result setCursor(int, int) { return mraa::SUCCESS; }
    void write(std::string_view line) { std::cout << line << std::endl; }
    void clear() {}
    void dim(bool) {}
};

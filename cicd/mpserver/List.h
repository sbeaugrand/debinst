/******************************************************************************!
 * \file List.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <string>
#include <list>

/******************************************************************************!
 * \class List
 ******************************************************************************/
class List
{
public:
    struct Part {
        std::string name;
        int weight;
        int size;
        std::list<std::string> list;
    };
    List(const std::string& path);
    std::string rand() const;
    int readResumeTime() const;
    void writeResumeTime(int ms) const;
private:
    void push(const std::string& path);

    std::string mPath;
    std::list<Part> mList;
    int mWeightSum = 0;
};

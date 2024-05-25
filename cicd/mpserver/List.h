/******************************************************************************!
 * \file List.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <string>
#include <list>
#include <tuple>

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
        std::string abrev;
    };
    explicit List(std::string_view path);
    std::tuple<std::string, std::string, int> rand() const;
    int readResumeTime() const;
    void writeResumeTime(int ms) const;
    void writeLog(std::string_view album) const;
private:
    void push(const std::string& path);
    void readLog();
    int timediff(std::string_view line) const;

    std::string mPath;
    std::list<Part> mList;
    int mWeightSum = 0;
};

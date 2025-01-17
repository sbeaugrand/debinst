/******************************************************************************!
 * \file List.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#pragma once
#include <string>
#include <list>
#include <tuple>
#include <jsoncpp/json/value.h>

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
    Json::Value artist(const std::string& artist,
                       const std::string& album) const;
    std::tuple<std::string, std::string> album(const std::string& search,
                                               int pos) const;
    int readResumeTime() const;
    void writeResumeTime(int ms) const;
    void writeLog(std::string_view album) const;
    Json::Value dir(const std::string& path) const;
private:
    void push(const std::string& path);
    void readList();
    void readWeights();
    void readAbrev();
    void readLog();
    int timediff(std::string_view line) const;

    std::string mPath;
    std::list<Part> mList;
    int mWeightSum = 0;
};

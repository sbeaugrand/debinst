/******************************************************************************!
 * \file List.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <filesystem>
#include <fstream>
#include <chrono>
#include <algorithm>
#include <iostream>
#include <cstdlib>
#include <ctime>
#include "List.h"
#include "log.h"

/******************************************************************************!
 * \fn List
 ******************************************************************************/
List::List(const std::string& path)
    : mPath(path)
{
    if (std::filesystem::exists(path + "/mps.list")) {
        std::ifstream file(path + "/mps.list");
        std::string line;
        while (file) {
            std::getline(file, line);
            if (! line.empty()) {
                this->push(line);
            }
        }
    } else {
        int pathSize = path.size() + 1;
        std::filesystem::recursive_directory_iterator dir(path);
        while (dir != std::filesystem::end(dir)) {
            if (dir->path().extension() == ".m3u") {
                this->push(dir->path().string().substr(pathSize));
            }
            ++dir;
        }
        mList.sort([](const List::Part& a,
                      const List::Part& b) {
            return a.name < b.name;
        });
        std::ofstream file(path + "/list");
        for (auto it : mList) {
            it.list.sort();
            for (auto al : it.list) {
                file << it.name << '/' << al << std::endl;
            }
        }
    }
    if (std::filesystem::exists(path + "/mps.weights")) {
        std::ifstream file(path + "/mps.weights");
        while (file) {
            std::string name;
            std::string weight;
            std::getline(file, name);
            std::getline(file, weight);
            for (auto& it : mList) {
                if (it.name == name) {
                    it.weight = std::stoi(weight);
                    mWeightSum += it.weight;
                }
            }
        }
    } else {
        std::ofstream file(path + "/mps.weights");
        for (auto it : mList) {
            file << it.name << std::endl;
            file << 1 << std::endl;
            mWeightSum += 1;
        }
    }
    this->readLog();
}

/******************************************************************************!
 * \fn rand
 ******************************************************************************/
std::string
List::rand() const
{
    static int r = -1;
    if (r < 0) {
        std::srand(std::time(nullptr));
    }
    r = std::rand() / ((RAND_MAX / mWeightSum) + 1);

    int max = 0;
    for (auto it : mList) {
        max += it.weight;
        if (max > r) {
            r = std::rand() / ((RAND_MAX / it.size) + 1);
            for (auto al : it.list) {
                if (r == 0) {
                    return it.name + '/' + al.substr(11);
                }
                --r;
            }
        }
    }
    return "error";
}

/******************************************************************************!
 * \fn readResumeTime
 ******************************************************************************/
int
List::readResumeTime() const
{
    if (std::filesystem::exists(mPath + "/mps.resume")) {
        std::ifstream file(mPath + "/mps.resume");
        int ms;
        file >> ms;
        return ms;
    }
    return 0;
}

/******************************************************************************!
 * \fn writeResumeTime
 ******************************************************************************/
void
List::writeResumeTime(int ms) const
{
    std::ofstream file(mPath + "/mps.resume");
    file << ms;
}

/******************************************************************************!
 * \fn writeLog
 ******************************************************************************/
void
List::writeLog(std::string_view album) const
{
    if (std::filesystem::exists(mPath + "/mps.last")) {
        std::ifstream input(mPath + "/mps.last");
        std::string line;
        std::getline(input, line);
        //std::chrono::sys_seconds tp;
        //std::chrono::from_stream(input, "%F %T ", tp);  // c++20
        std::tm timeinfo{};
        std::istringstream ss(line);
        ss >> std::get_time(&timeinfo, "%Y-%m-%d %T ");
        const std::time_t tt = std::mktime(&timeinfo) + timezone;
        const auto tp = std::chrono::system_clock::from_time_t(tt);
        const auto now = std::chrono::system_clock::now();
        const std::chrono::duration<double> diff = now - tp;
        DEBUG("last " << diff.count());  // << std::ctime(&tt);
        if (diff.count() > 300) {
            std::ofstream output{ mPath + "/mps.log", std::ios_base::app };
            output << line << std::endl;
        }
    }
    std::ofstream file(mPath + "/mps.last");
    std::time_t time = std::time({});
    char timeString[std::size("yyyy-mm-dd hh:mm:ss ")];
    std::strftime(std::data(timeString), std::size(timeString),
                  "%F %T ", std::localtime(&time));
    file << timeString << album << std::endl;
}

/******************************************************************************!
 * \fn push
 ******************************************************************************/
void
List::push(const std::string& path)
{
    auto pos = path.find('/');
    auto search = path.substr(0, pos);
    auto album = std::string("           ") + path.substr(pos + 1);
    if (auto it = std::find_if(std::begin(mList), std::end(mList),
                               [&search](const Part& part) {
        return part.name == search;
    });
        it != std::end(mList)) {
        it->list.push_back(album);
        ++it->size;
        return;
    }
    mList.push_back(Part{ search, 1, 1, { album } });
}

/******************************************************************************!
 * \fn readLog
 ******************************************************************************/
void
List::readLog()
{
    if (! std::filesystem::exists(mPath + "/mps.log")) {
        return;
    }
    std::ifstream file(mPath + "/mps.log");
    std::string line;
    while (file) {
        std::getline(file, line);
        if (line.empty()) {
            continue;
        }
        auto date = line.substr(0, 11);
        auto path = line.substr(20);
        auto pos = path.find('/');
        auto search = path.substr(0, pos);
        auto album = path.substr(pos + 1);
        if (auto it = std::find_if(std::begin(mList), std::end(mList),
                                   [&search](const Part& part) {
            return part.name == search;
        });
            it != std::end(mList)) {
            for (auto& al : it->list) {
                if (al.substr(11) == album) {
                    al = date + al.substr(11);
                }
            }
        }
    }
}

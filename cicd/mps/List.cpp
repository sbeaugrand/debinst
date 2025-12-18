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
#include "path.h"
#include "log.h"

/******************************************************************************!
 * \fn List
 ******************************************************************************/
List::List(std::string_view path)
    : mPath(path)
{
    this->readList();
    this->readWeights();
    this->readAbrev();
    this->readLog();
}

/******************************************************************************!
 * \fn timediff
 ******************************************************************************/
int
List::timediff(std::string_view line) const
{
    if (line.substr(0, 11) == "           ") {
        return -86400;
    }
    std::tm timeinfo{};
    std::istringstream ss(line.data());
    ss >> std::get_time(&timeinfo, "%Y-%m-%d %T ");
    const std::time_t tt = std::mktime(&timeinfo) + timezone;
    const auto tp = std::chrono::system_clock::from_time_t(tt);
    const auto now = std::chrono::system_clock::now();
    const std::chrono::duration<double> diff = now - tp;
    DEBUG(diff.count() << " seconds");
    return diff.count();
}

/******************************************************************************!
 * \fn rand
 ******************************************************************************/
std::tuple<std::string, std::string, int>
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
            for (const auto& al : it.list) {
                if (r == 0) {
                    return {
                        it.name + '/' + al.substr(11),
                        it.abrev,
                        this->timediff(al) / 86400
                    };
                }
                --r;
            }
        }
    }
    return { "error", "XX", -1 };
}

/******************************************************************************!
 * \fn artist
 ******************************************************************************/
Json::Value
List::artist(const std::string& artist,
             const std::string& album) const
{
    Json::Value r;
    std::string search;
    std::string current;

    if (artist.empty()) {
        if (! std::filesystem::exists(mPath + "/mps.last")) {
            return r;
        }
        std::ifstream input(mPath + "/mps.last");
        std::string line;
        std::getline(input, line);
        if (line.empty()) {
            return r;
        }
        std::string date;
        std::tie(search, date, current) = ::splitPath(line.substr(20));
    } else {
        search = artist;
        current = album;
    }

    int count = 0;
    r["artist"] = search;
    for (const auto& it : mList) {
        for (const auto& al : it.list) {
            auto path = al.substr(11);
            if (path.starts_with(search + " - ")) {
                const auto [arti, date, albu] = ::splitPath(path);
                r["album"].append(date + "  " + albu);
                if (albu == current) {
                    r["pos"] = count;
                    DEBUG("pos " << count);
                }
                ++count;
            }
        }
    }
    return r;
}

/******************************************************************************!
 * \fn album
 ******************************************************************************/
std::tuple<std::string, std::string>
List::album(const std::string& search, int pos) const
{
    if (pos < 0) {
        for (const auto& it : mList) {
            for (const auto& al : it.list) {
                const auto [arti, date, albu] = ::splitPath(al.substr(11));
                auto count = search.size();
                std::string str;
                for (const auto c : arti) {
                    if (c != ' ') {
                        str.push_back(::toupper(c));
                        if (--count == 0) {
                            break;
                        }
                    }
                }
                if (str == search) {
                    return { it.name + '/' + al.substr(11), it.abrev };
                }
            }
        }
    } else {
        int count = 0;
        for (const auto& it : mList) {
            for (const auto& al : it.list) {
                auto path = al.substr(11);
                if (path.starts_with(search + " - ")) {
                    const auto [arti, date, albu] = ::splitPath(path);
                    if (arti == search) {
                        if (count == pos) {
                            return { it.name + '/' + al.substr(11), it.abrev };
                        }
                        ++count;
                    }
                }
            }
        }
    }
    ERROR(search);
    return { "", "" };
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
        if (this->timediff(line) > 300) {
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
 * \fn dir
 ******************************************************************************/
Json::Value
List::dir(const std::string& path) const
{
    Json::Value result;
    std::list<std::string> list;
    try {
        std::filesystem::directory_iterator d(mPath + '/' + path);
        while (d != std::filesystem::end(d)) {
            if (d->is_directory()) {
                if (path.empty()) {
                    list.push_back(d->path().filename().string());
                } else {
                    list.push_back(path + '/' +
                                   d->path().filename().string());
                }
            }
            ++d;
        }
    } catch (const std::filesystem::filesystem_error& e) {
        ERROR(e.what());
    }
    list.sort();
    for (const auto& d : list) {
        result["dir"].append(d);
    }
    return result;
}

/******************************************************************************!
 * \fn push
 ******************************************************************************/
void
List::push(const std::string& path)
{
    auto pos = path.find('/');
    auto search = path.substr(0, pos);
    auto al = std::string("           ") + path.substr(pos + 1);
    if (auto it = std::find_if(std::begin(mList), std::end(mList),
                               [&search](const Part& part) {
        return part.name == search;
    });
        it != std::end(mList)) {
        it->list.push_back(al);
        ++it->size;
        return;
    }
    mList.push_back(Part{ search, 1, 1, { al }, "XX" });
}

/******************************************************************************!
 * \fn readList
 ******************************************************************************/
void
List::readList()
{
    if (std::filesystem::exists(mPath + "/mps.list")) {
        std::ifstream file(mPath + "/mps.list");
        std::string line;
        while (file) {
            std::getline(file, line);
            if (! line.empty()) {
                this->push(line);
            }
        }
    } else {
        int pathSize = mPath.size() + 1;
        std::filesystem::recursive_directory_iterator d(mPath);
        while (d != std::filesystem::end(d)) {
            if (d->path().extension() == ".m3u") {
                this->push(d->path().string().substr(pathSize));
            }
            ++d;
        }
        mList.sort([](const List::Part& a,
                      const List::Part& b) {
            return a.name < b.name;
        });
        std::ofstream file(mPath + "/mps.list");
        for (auto& it : mList) {
            it.list.sort();
            for (const auto& al : it.list) {
                file << it.name << '/' << al.substr(11) << std::endl;
            }
        }
    }
}

/******************************************************************************!
 * \fn readWeights
 ******************************************************************************/
void
List::readWeights()
{
    if (std::filesystem::exists(mPath + "/mps.weights")) {
        std::ifstream file(mPath + "/mps.weights");
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
        std::ofstream file(mPath + "/mps.weights");
        for (const auto& it : mList) {
            file << it.name << std::endl;
            file << 1 << std::endl;
            mWeightSum += 1;
        }
    }
}

/******************************************************************************!
 * \fn readAbrev
 ******************************************************************************/
void
List::readAbrev()
{
    if (std::filesystem::exists(mPath + "/mps.abrev")) {
        std::ifstream file(mPath + "/mps.abrev");
        auto it = mList.begin();
        while (file && it != mList.end()) {
            file >> it->abrev;
            ++it;
        }
    } else {
        std::ofstream file(mPath + "/mps.abrev");
        for (unsigned int i = 0; i < mList.size(); ++i) {
            file << "XX" << std::endl;
        }
    }
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
        auto albu = path.substr(pos + 1);
        if (const auto& it = std::find_if(std::begin(mList), std::end(mList),
                                          [&search](const Part& part) {
            return part.name == search;
        });
            it != std::end(mList)) {
            for (auto& al : it->list) {
                if (al.substr(11) == albu) {
                    al = date + al.substr(11);
                }
            }
        }
    }
}

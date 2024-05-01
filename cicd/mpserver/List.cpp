/******************************************************************************!
 * \file List.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <filesystem>
#include <fstream>
#include <iostream>
#include <cstdlib>
#include <ctime>
#include "List.h"

/******************************************************************************!
 * \fn List
 ******************************************************************************/
List::List(const std::string& path)
    : mPath(path)
{
    if (std::filesystem::exists(path + "/mp3.list")) {
        std::ifstream file(path + "/mp3.list");
        std::string line;
        while (file) {
            std::getline(file, line);
            if (! line.empty()) {
                this->push(line);
            }
        }
    } else {
        int pathSize = path.size() + 1;
        std::filesystem::recursive_directory_iterator it(path);
        while (it != std::filesystem::end(it)) {
            if (it->path().extension() == ".m3u") {
                this->push(it->path().string().substr(pathSize));
            }
            ++it;
        }
        mList.sort([](const List::Part& a,
                      const List::Part& b) {
            return a.name < b.name;
        });
        std::ofstream file(path + "/mp3.list");
        for (auto it : mList) {
            it.list.sort();
            for (auto al : it.list) {
                file << it.name << '/' << al << std::endl;
            }
        }
    }
    if (std::filesystem::exists(path + "/mp3.weights")) {
        std::ifstream file(path + "/mp3.weights");
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
        std::ofstream file(path + "/mp3.weights");
        for (auto it : mList) {
            file << it.name << std::endl;
            file << 1 << std::endl;
            mWeightSum += 1;
        }
    }
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
                    return it.name + '/' + al;
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
    if (std::filesystem::exists(mPath + "/resume")) {
        std::ifstream file(mPath + "/resume");
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
    std::ofstream file(mPath + "/resume");
    file << ms;
}

/******************************************************************************!
 * \fn push
 ******************************************************************************/
void
List::push(const std::string& path)
{
    auto pos = path.find('/');
    auto part = path.substr(0, pos);
    auto album = path.substr(pos + 1);
    for (auto& it : mList) {
        if (it.name == part) {
            it.list.push_back(album);
            ++it.size;
            return;
        }
    }
    mList.push_back(Part{ part, 1, 1, { album } });
}



//
//  friends.h
//
//  Created by js2Model on 2015-02-23.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#include <string>
#include <unordered_map>
#include <vector>
#include "document.h"


#pragma once

namespace tr {
namespace models {

class friends  {

public:
    std::string mName;
    int mId;

public:

    friends() = default;
    friends(const friends &other) = default;
    friends(const rapidjson::Value &value);

}; // class friends

std::string to_string(const friends &val, std::string indent = "", std::string pretty_print = "");

friends friendsFromData(const char * jsonData);
friends friendsFromFile(std::string filename);
std::vector<friends> friendsArrayFromData(const char *jsonData, size_t len);


} // namespace models
} // namespace tr

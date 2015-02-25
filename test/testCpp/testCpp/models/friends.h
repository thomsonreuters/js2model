


//
//  friends.h
//
//  Created by js2Model on 2015-02-24.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#include <string>
#include <unordered_map>
#include <vector>
#include "document.h"


#pragma once

namespace tr {
namespace models {

class friends_t  {

public:
    std::string name;
    int id;

public:

    friends_t() = default;
    friends_t(const friends_t &other) = default;
    friends_t(const rapidjson::Value &value);

}; // class friends_t

std::string to_string(const friends_t &val, std::string indent = "", std::string pretty_print = "");

friends_t friendsFromData(const char * jsonData);
friends_t friendsFromFile(std::string filename);
std::vector<friends_t> friendsArrayFromData(const char *jsonData, size_t len);


} // namespace models
} // namespace tr

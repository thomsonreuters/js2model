


//
//  name.h
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

class name_t  {

public:
    std::string last;
    std::string first;

public:

    name_t() = default;
    name_t(const name_t &other) = default;
    name_t(const rapidjson::Value &value);

}; // class name_t

std::string to_string(const name_t &val, std::string indent = "", std::string pretty_print = "");

name_t nameFromData(const char * jsonData);
name_t nameFromFile(std::string filename);
std::vector<name_t> nameArrayFromData(const char *jsonData, size_t len);


} // namespace models
} // namespace tr

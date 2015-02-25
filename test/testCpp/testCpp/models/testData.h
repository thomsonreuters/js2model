


//
//  testData.h
//
//  Created by js2Model on 2015-02-24.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#include <string>
#include <unordered_map>
#include <vector>
#include "name.h"
#include "friends.h"
#include "document.h"


#pragma once

namespace tr {
namespace models {

class testData_t  {

public:
    std::string guid;
    int index;
    std::string favoriteFruit;
    float latitude;
    std::string email;
    std::string picture;
    std::vector<std::string> tags;
    std::string company;
    std::string eyeColor;
    std::string phone;
    std::string address;
    std::vector<friends_t> friends;
    bool isActive;
    std::string about;
    std::string balance;
    name_t name;
    int age;
    std::string registered;
    std::string greeting;
    float longitude;
    std::vector<int> range;
    std::string Id;

public:

    testData_t() = default;
    testData_t(const testData_t &other) = default;
    testData_t(const rapidjson::Value &value);

}; // class testData_t

std::string to_string(const testData_t &val, std::string indent = "", std::string pretty_print = "");

testData_t testDataFromData(const char * jsonData);
testData_t testDataFromFile(std::string filename);
std::vector<testData_t> testDataArrayFromData(const char *jsonData, size_t len);


} // namespace models
} // namespace tr

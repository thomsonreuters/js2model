

//
//  testData.h
//
//  Created by js2Model on 2015-02-23.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#include <string>
#include <unordered_map>
#include <vector>
#include "friends.h"
#include "name.h"
#include "document.h"


#pragma once

namespace tr {
namespace models {

class testData  {

public:
    std::string mGuid;
    int mIndex;
    std::string mFavoriteFruit;
    float mLatitude;
    std::string mEmail;
    std::string mPicture;
    std::vector<std::string> mTags;
    std::string mCompany;
    std::string mEyeColor;
    std::string mPhone;
    std::string mAddress;
    std::vector<friends> mFriends;
    bool mIsActive;
    std::string mAbout;
    std::string mBalance;
    name mName;
    int mAge;
    std::string mRegistered;
    std::string mGreeting;
    float mLongitude;
    std::vector<int> mRange;
    std::string mId;

public:

    testData() = default;
    testData(const testData &other) = default;
    testData(const rapidjson::Value &value);

}; // class testData

std::string to_string(const testData &val, std::string indent = "", std::string pretty_print = "");

testData testDataFromData(const char * jsonData);
testData testDataFromFile(std::string filename);
std::vector<testData> testDataArrayFromData(const char *jsonData, size_t len);


} // namespace models
} // namespace tr

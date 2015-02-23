

//
//  testData.cpp
//
//  Created by js2Model on 2015-02-23.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#include "testData.h"
#include <vector>
#include <fstream>
#include <sstream>

using namespace std;
using namespace rapidjson;

namespace tr {
namespace models {

testData::testData(const rapidjson::Value &json_value) {

    auto guid_iter = json_value.FindMember("guid");
    if ( guid_iter != json_value.MemberEnd() ) {

        assert(guid_iter->value.IsString());
        mGuid = guid_iter->value.GetString();
    }

    auto index_iter = json_value.FindMember("index");
    if ( index_iter != json_value.MemberEnd() ) {

        assert(index_iter->value.IsInt());
        mIndex = index_iter->value.GetInt();
    }

    auto favoriteFruit_iter = json_value.FindMember("favoriteFruit");
    if ( favoriteFruit_iter != json_value.MemberEnd() ) {

        assert(favoriteFruit_iter->value.IsString());
        mFavoriteFruit = favoriteFruit_iter->value.GetString();
    }

    auto latitude_iter = json_value.FindMember("latitude");
    if ( latitude_iter != json_value.MemberEnd() ) {

    }

    auto email_iter = json_value.FindMember("email");
    if ( email_iter != json_value.MemberEnd() ) {

        assert(email_iter->value.IsString());
        mEmail = email_iter->value.GetString();
    }

    auto picture_iter = json_value.FindMember("picture");
    if ( picture_iter != json_value.MemberEnd() ) {

        assert(picture_iter->value.IsString());
        mPicture = picture_iter->value.GetString();
    }

    auto tags_iter = json_value.FindMember("tags");
    if ( tags_iter != json_value.MemberEnd() ) {

        for( auto array_item = tags_iter->value.Begin(); array_item != tags_iter->value.End(); array_item++  ) {

            assert(array_item->IsString());
            mTags.push_back(array_item->GetString());
        }
    }

    auto company_iter = json_value.FindMember("company");
    if ( company_iter != json_value.MemberEnd() ) {

        assert(company_iter->value.IsString());
        mCompany = company_iter->value.GetString();
    }

    auto eyeColor_iter = json_value.FindMember("eyeColor");
    if ( eyeColor_iter != json_value.MemberEnd() ) {

        assert(eyeColor_iter->value.IsString());
        mEyeColor = eyeColor_iter->value.GetString();
    }

    auto phone_iter = json_value.FindMember("phone");
    if ( phone_iter != json_value.MemberEnd() ) {

        assert(phone_iter->value.IsString());
        mPhone = phone_iter->value.GetString();
    }

    auto address_iter = json_value.FindMember("address");
    if ( address_iter != json_value.MemberEnd() ) {

        assert(address_iter->value.IsString());
        mAddress = address_iter->value.GetString();
    }

    auto friends_iter = json_value.FindMember("friends");
    if ( friends_iter != json_value.MemberEnd() ) {

        for( auto array_item = friends_iter->value.Begin(); array_item != friends_iter->value.End(); array_item++  ) {

            assert(array_item->IsObject());
            mFriends.push_back(friends(*array_item));
        }
    }

    auto isActive_iter = json_value.FindMember("isActive");
    if ( isActive_iter != json_value.MemberEnd() ) {

        assert(isActive_iter->value.IsBool());
        mIsActive = isActive_iter->value.GetBool();
    }

    auto about_iter = json_value.FindMember("about");
    if ( about_iter != json_value.MemberEnd() ) {

        assert(about_iter->value.IsString());
        mAbout = about_iter->value.GetString();
    }

    auto balance_iter = json_value.FindMember("balance");
    if ( balance_iter != json_value.MemberEnd() ) {

        assert(balance_iter->value.IsString());
        mBalance = balance_iter->value.GetString();
    }

    auto name_iter = json_value.FindMember("name");
    if ( name_iter != json_value.MemberEnd() ) {

        assert(name_iter->value.IsObject());
        mName = name(name_iter->value);
    }

    auto age_iter = json_value.FindMember("age");
    if ( age_iter != json_value.MemberEnd() ) {

        assert(age_iter->value.IsInt());
        mAge = age_iter->value.GetInt();
    }

    auto registered_iter = json_value.FindMember("registered");
    if ( registered_iter != json_value.MemberEnd() ) {

        assert(registered_iter->value.IsString());
        mRegistered = registered_iter->value.GetString();
    }

    auto greeting_iter = json_value.FindMember("greeting");
    if ( greeting_iter != json_value.MemberEnd() ) {

        assert(greeting_iter->value.IsString());
        mGreeting = greeting_iter->value.GetString();
    }

    auto longitude_iter = json_value.FindMember("longitude");
    if ( longitude_iter != json_value.MemberEnd() ) {

    }

    auto range_iter = json_value.FindMember("range");
    if ( range_iter != json_value.MemberEnd() ) {

        for( auto array_item = range_iter->value.Begin(); array_item != range_iter->value.End(); array_item++  ) {

            assert(array_item->IsInt());
            mRange.push_back(array_item->GetInt());
        }
    }

    auto Id_iter = json_value.FindMember("_id");
    if ( Id_iter != json_value.MemberEnd() ) {

        assert(Id_iter->value.IsString());
        mId = Id_iter->value.GetString();
    }

}

string to_string(const testData &val, std::string indent/* = "" */, std::string pretty_print/* = "" */) {

    ostringstream os;

    os << indent << "{" << endl;
    os << indent << pretty_print << "\"guid\": \"" << val.mGuid << "\"," << endl;
    os << indent << pretty_print << "\"index\": " << val.mIndex << "," << endl;
    os << indent << pretty_print << "\"favoriteFruit\": \"" << val.mFavoriteFruit << "\"," << endl;
    os << indent << pretty_print << "\"email\": \"" << val.mEmail << "\"," << endl;
    os << indent << pretty_print << "\"picture\": \"" << val.mPicture << "\"," << endl;
    os << indent << pretty_print << "\"tags\": [";
    for( auto &array_item : val.mTags ) {

        os << "\"" << array_item << "\",";
    }
    os << indent << pretty_print << "]," << endl;
    os << indent << pretty_print << "\"company\": \"" << val.mCompany << "\"," << endl;
    os << indent << pretty_print << "\"eyeColor\": \"" << val.mEyeColor << "\"," << endl;
    os << indent << pretty_print << "\"phone\": \"" << val.mPhone << "\"," << endl;
    os << indent << pretty_print << "\"address\": \"" << val.mAddress << "\"," << endl;
    os << indent << pretty_print << "\"friends\": [";
    for( auto &array_item : val.mFriends ) {

        os << endl << to_string(array_item, indent + pretty_print + pretty_print, pretty_print) << "," << endl;
    }
    os << indent << pretty_print << "]," << endl;
    os << indent << pretty_print << "\"isActive\": " << (val.mIsActive ? "true" : "false") << "," << endl;
    os << indent << pretty_print << "\"about\": \"" << val.mAbout << "\"," << endl;
    os << indent << pretty_print << "\"balance\": \"" << val.mBalance << "\"," << endl;
    os << indent << pretty_print << "\"name\": " << to_string(val.mName, indent + pretty_print, pretty_print) << "," << endl;
    os << indent << pretty_print << "\"age\": " << val.mAge << "," << endl;
    os << indent << pretty_print << "\"registered\": \"" << val.mRegistered << "\"," << endl;
    os << indent << pretty_print << "\"greeting\": \"" << val.mGreeting << "\"," << endl;
    os << indent << pretty_print << "\"range\": [";
    for( auto &array_item : val.mRange ) {

        os << array_item << ",";
    }
    os << indent << pretty_print << "]," << endl;
    os << indent << pretty_print << "\"Id\": \"" << val.mId << "\"," << endl;
    os << indent << "}";

    return os.str();
}


testData testDataFromJsonData(const char *data, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], data, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    return testData(doc);
}

testData testDataFromFile(string filename) {

    ifstream is;

    stringstream buffer;

    is.open(filename);
    buffer << is.rdbuf();

    testData instance = testDataFromJsonData(buffer.str().c_str(), buffer.str().length());

    return instance;
}

std::vector<testData> testDataArrayFromData(const char *jsonData, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], jsonData, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    assert(doc.IsArray());

    std::vector<testData> testDataArray(doc.Size());

    for( auto array_item = doc.Begin(); array_item != doc.End(); array_item++  ) {

        testData instance = testData(*array_item);
        testDataArray.push_back(instance);
    }

    return testDataArray;
}

} // namespace models
} // namespace tr


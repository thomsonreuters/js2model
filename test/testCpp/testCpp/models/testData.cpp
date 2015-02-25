


//
//  testData.cpp
//
//  Created by js2Model on 2015-02-24.
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

testData_t::testData_t(const rapidjson::Value &json_value) {

    auto guid_iter = json_value.FindMember("guid");
    if ( guid_iter != json_value.MemberEnd() ) {

        assert(guid_iter->value.IsString());
        guid = guid_iter->value.GetString();
    }

    auto index_iter = json_value.FindMember("index");
    if ( index_iter != json_value.MemberEnd() ) {

        assert(index_iter->value.IsInt());
        index = index_iter->value.GetInt();
    }

    auto favoriteFruit_iter = json_value.FindMember("favoriteFruit");
    if ( favoriteFruit_iter != json_value.MemberEnd() ) {

        assert(favoriteFruit_iter->value.IsString());
        favoriteFruit = favoriteFruit_iter->value.GetString();
    }

    auto latitude_iter = json_value.FindMember("latitude");
    if ( latitude_iter != json_value.MemberEnd() ) {

    }

    auto email_iter = json_value.FindMember("email");
    if ( email_iter != json_value.MemberEnd() ) {

        assert(email_iter->value.IsString());
        email = email_iter->value.GetString();
    }

    auto picture_iter = json_value.FindMember("picture");
    if ( picture_iter != json_value.MemberEnd() ) {

        assert(picture_iter->value.IsString());
        picture = picture_iter->value.GetString();
    }

    auto tags_iter = json_value.FindMember("tags");
    if ( tags_iter != json_value.MemberEnd() ) {

        for( auto array_item = tags_iter->value.Begin(); array_item != tags_iter->value.End(); array_item++  ) {

            assert(array_item->IsString());
            tags.push_back(array_item->GetString());
        }
    }

    auto company_iter = json_value.FindMember("company");
    if ( company_iter != json_value.MemberEnd() ) {

        assert(company_iter->value.IsString());
        company = company_iter->value.GetString();
    }

    auto eyeColor_iter = json_value.FindMember("eyeColor");
    if ( eyeColor_iter != json_value.MemberEnd() ) {

        assert(eyeColor_iter->value.IsString());
        eyeColor = eyeColor_iter->value.GetString();
    }

    auto phone_iter = json_value.FindMember("phone");
    if ( phone_iter != json_value.MemberEnd() ) {

        assert(phone_iter->value.IsString());
        phone = phone_iter->value.GetString();
    }

    auto address_iter = json_value.FindMember("address");
    if ( address_iter != json_value.MemberEnd() ) {

        assert(address_iter->value.IsString());
        address = address_iter->value.GetString();
    }

    auto friends_iter = json_value.FindMember("friends");
    if ( friends_iter != json_value.MemberEnd() ) {

        for( auto array_item = friends_iter->value.Begin(); array_item != friends_iter->value.End(); array_item++  ) {

            assert(array_item->IsObject());
            friends.push_back(friends_t(*array_item));
        }
    }

    auto isActive_iter = json_value.FindMember("isActive");
    if ( isActive_iter != json_value.MemberEnd() ) {

        assert(isActive_iter->value.IsBool());
        isActive = isActive_iter->value.GetBool();
    }

    auto about_iter = json_value.FindMember("about");
    if ( about_iter != json_value.MemberEnd() ) {

        assert(about_iter->value.IsString());
        about = about_iter->value.GetString();
    }

    auto balance_iter = json_value.FindMember("balance");
    if ( balance_iter != json_value.MemberEnd() ) {

        assert(balance_iter->value.IsString());
        balance = balance_iter->value.GetString();
    }

    auto name_iter = json_value.FindMember("name");
    if ( name_iter != json_value.MemberEnd() ) {

        assert(name_iter->value.IsObject());
        name = name_t(name_iter->value);
    }

    auto age_iter = json_value.FindMember("age");
    if ( age_iter != json_value.MemberEnd() ) {

        assert(age_iter->value.IsInt());
        age = age_iter->value.GetInt();
    }

    auto registered_iter = json_value.FindMember("registered");
    if ( registered_iter != json_value.MemberEnd() ) {

        assert(registered_iter->value.IsString());
        registered = registered_iter->value.GetString();
    }

    auto greeting_iter = json_value.FindMember("greeting");
    if ( greeting_iter != json_value.MemberEnd() ) {

        assert(greeting_iter->value.IsString());
        greeting = greeting_iter->value.GetString();
    }

    auto longitude_iter = json_value.FindMember("longitude");
    if ( longitude_iter != json_value.MemberEnd() ) {

    }

    auto range_iter = json_value.FindMember("range");
    if ( range_iter != json_value.MemberEnd() ) {

        for( auto array_item = range_iter->value.Begin(); array_item != range_iter->value.End(); array_item++  ) {

            assert(array_item->IsInt());
            range.push_back(array_item->GetInt());
        }
    }

    auto Id_iter = json_value.FindMember("_id");
    if ( Id_iter != json_value.MemberEnd() ) {

        assert(Id_iter->value.IsString());
        Id = Id_iter->value.GetString();
    }

}

string to_string(const testData_t &val, std::string indent/* = "" */, std::string pretty_print/* = "" */) {

    ostringstream os;

    os << indent << "{" << endl;
    os << indent << pretty_print << "\"guid\": \"" << val.guid << "\"," << endl;
    os << indent << pretty_print << "\"index\": " << val.index << "," << endl;
    os << indent << pretty_print << "\"favoriteFruit\": \"" << val.favoriteFruit << "\"," << endl;
    os << indent << pretty_print << "\"email\": \"" << val.email << "\"," << endl;
    os << indent << pretty_print << "\"picture\": \"" << val.picture << "\"," << endl;
    os << indent << pretty_print << "\"tags\": [";
    for( auto &array_item : val.tags ) {

        os << "\"" << array_item << "\",";
    }
    os << indent << pretty_print << "]," << endl;
    os << indent << pretty_print << "\"company\": \"" << val.company << "\"," << endl;
    os << indent << pretty_print << "\"eyeColor\": \"" << val.eyeColor << "\"," << endl;
    os << indent << pretty_print << "\"phone\": \"" << val.phone << "\"," << endl;
    os << indent << pretty_print << "\"address\": \"" << val.address << "\"," << endl;
    os << indent << pretty_print << "\"friends\": [";
    for( auto &array_item : val.friends ) {

        os << endl << to_string(array_item, indent + pretty_print + pretty_print, pretty_print) << "," << endl;
    }
    os << indent << pretty_print << "]," << endl;
    os << indent << pretty_print << "\"isActive\": " << (val.isActive ? "true" : "false") << "," << endl;
    os << indent << pretty_print << "\"about\": \"" << val.about << "\"," << endl;
    os << indent << pretty_print << "\"balance\": \"" << val.balance << "\"," << endl;
    os << indent << pretty_print << "\"name\": " << to_string(val.name, indent + pretty_print, pretty_print) << "," << endl;
    os << indent << pretty_print << "\"age\": " << val.age << "," << endl;
    os << indent << pretty_print << "\"registered\": \"" << val.registered << "\"," << endl;
    os << indent << pretty_print << "\"greeting\": \"" << val.greeting << "\"," << endl;
    os << indent << pretty_print << "\"range\": [";
    for( auto &array_item : val.range ) {

        os << array_item << ",";
    }
    os << indent << pretty_print << "]," << endl;
    os << indent << pretty_print << "\"Id\": \"" << val.Id << "\"," << endl;
    os << indent << "}";

    return os.str();
}


testData_t testDataFromJsonData(const char *data, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], data, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    return testData_t(doc);
}

testData_t testDataFromFile(string filename) {

    ifstream is;

    stringstream buffer;

    is.open(filename);
    buffer << is.rdbuf();

    testData_t instance = testDataFromJsonData(buffer.str().c_str(), buffer.str().length());

    return instance;
}

std::vector<testData_t> testDataArrayFromData(const char *jsonData, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], jsonData, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    assert(doc.IsArray());

    std::vector<testData_t> testDataArray;
    testDataArray.reserve(doc.Size());

    for( auto array_item = doc.Begin(); array_item != doc.End(); array_item++  ) {

        testData_t instance = testData_t(*array_item);
        testDataArray.push_back(instance);
    }

    return testDataArray;
}

} // namespace models
} // namespace tr


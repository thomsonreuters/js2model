

//
//  friends.cpp
//
//  Created by js2Model on 2015-02-23.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#include "friends.h"
#include <vector>
#include <fstream>
#include <sstream>

using namespace std;
using namespace rapidjson;

namespace tr {
namespace models {

friends::friends(const rapidjson::Value &json_value) {

    auto name_iter = json_value.FindMember("name");
    if ( name_iter != json_value.MemberEnd() ) {

        assert(name_iter->value.IsString());
        mName = name_iter->value.GetString();
    }

    auto id_iter = json_value.FindMember("id");
    if ( id_iter != json_value.MemberEnd() ) {

        assert(id_iter->value.IsInt());
        mId = id_iter->value.GetInt();
    }

}

string to_string(const friends &val, std::string indent/* = "" */, std::string pretty_print/* = "" */) {

    ostringstream os;

    os << indent << "{" << endl;
    os << indent << pretty_print << "\"name\": \"" << val.mName << "\"," << endl;
    os << indent << pretty_print << "\"id\": " << val.mId << "," << endl;
    os << indent << "}";

    return os.str();
}


friends friendsFromJsonData(const char *data, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], data, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    return friends(doc);
}

friends friendsFromFile(string filename) {

    ifstream is;

    stringstream buffer;

    is.open(filename);
    buffer << is.rdbuf();

    friends instance = friendsFromJsonData(buffer.str().c_str(), buffer.str().length());

    return instance;
}

std::vector<friends> friendsArrayFromData(const char *jsonData, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], jsonData, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    assert(doc.IsArray());

    std::vector<friends> friendsArray(doc.MemberCount());

    for( auto array_item = doc.Begin(); array_item != doc.End(); array_item++  ) {

        friends instance = friends(*array_item);
        friendsArray.push_back(instance);
    }

    return friendsArray;
}

} // namespace models
} // namespace tr


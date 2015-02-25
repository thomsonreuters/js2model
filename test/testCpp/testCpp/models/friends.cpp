


//
//  friends.cpp
//
//  Created by js2Model on 2015-02-24.
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

friends_t::friends_t(const rapidjson::Value &json_value) {

    auto name_iter = json_value.FindMember("name");
    if ( name_iter != json_value.MemberEnd() ) {

        assert(name_iter->value.IsString());
        name = name_iter->value.GetString();
    }

    auto id_iter = json_value.FindMember("id");
    if ( id_iter != json_value.MemberEnd() ) {

        assert(id_iter->value.IsInt());
        id = id_iter->value.GetInt();
    }

}

string to_string(const friends_t &val, std::string indent/* = "" */, std::string pretty_print/* = "" */) {

    ostringstream os;

    os << indent << "{" << endl;
    os << indent << pretty_print << "\"name\": \"" << val.name << "\"," << endl;
    os << indent << pretty_print << "\"id\": " << val.id << "," << endl;
    os << indent << "}";

    return os.str();
}


friends_t friendsFromJsonData(const char *data, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], data, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    return friends_t(doc);
}

friends_t friendsFromFile(string filename) {

    ifstream is;

    stringstream buffer;

    is.open(filename);
    buffer << is.rdbuf();

    friends_t instance = friendsFromJsonData(buffer.str().c_str(), buffer.str().length());

    return instance;
}

std::vector<friends_t> friendsArrayFromData(const char *jsonData, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], jsonData, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    assert(doc.IsArray());

    std::vector<friends_t> friendsArray;
    friendsArray.reserve(doc.Size());

    for( auto array_item = doc.Begin(); array_item != doc.End(); array_item++  ) {

        friends_t instance = friends_t(*array_item);
        friendsArray.push_back(instance);
    }

    return friendsArray;
}

} // namespace models
} // namespace tr


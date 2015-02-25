


//
//  name.cpp
//
//  Created by js2Model on 2015-02-24.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#include "name.h"
#include <vector>
#include <fstream>
#include <sstream>

using namespace std;
using namespace rapidjson;

namespace tr {
namespace models {

name_t::name_t(const rapidjson::Value &json_value) {

    auto last_iter = json_value.FindMember("last");
    if ( last_iter != json_value.MemberEnd() ) {

        assert(last_iter->value.IsString());
        last = last_iter->value.GetString();
    }

    auto first_iter = json_value.FindMember("first");
    if ( first_iter != json_value.MemberEnd() ) {

        assert(first_iter->value.IsString());
        first = first_iter->value.GetString();
    }

}

string to_string(const name_t &val, std::string indent/* = "" */, std::string pretty_print/* = "" */) {

    ostringstream os;

    os << indent << "{" << endl;
    os << indent << pretty_print << "\"last\": \"" << val.last << "\"," << endl;
    os << indent << pretty_print << "\"first\": \"" << val.first << "\"," << endl;
    os << indent << "}";

    return os.str();
}


name_t nameFromJsonData(const char *data, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], data, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    return name_t(doc);
}

name_t nameFromFile(string filename) {

    ifstream is;

    stringstream buffer;

    is.open(filename);
    buffer << is.rdbuf();

    name_t instance = nameFromJsonData(buffer.str().c_str(), buffer.str().length());

    return instance;
}

std::vector<name_t> nameArrayFromData(const char *jsonData, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], jsonData, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    assert(doc.IsArray());

    std::vector<name_t> nameArray;
    nameArray.reserve(doc.Size());

    for( auto array_item = doc.Begin(); array_item != doc.End(); array_item++  ) {

        name_t instance = name_t(*array_item);
        nameArray.push_back(instance);
    }

    return nameArray;
}

} // namespace models
} // namespace tr


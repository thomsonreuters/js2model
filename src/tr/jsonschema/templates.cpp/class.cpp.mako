<%inherit file="base.mako" />
<%namespace name="base" file="base.mako" />
<%block name="code">
#include "${classDef.decl_name}"
#include <vector>
#include <fstream>
#include <sstream>

using namespace std;
using namespace rapidjson;

namespace ${namespace} {
namespace models {

${classDef.name}::${classDef.name}(const rapidjson::Value &json_value) {

    % for v in classDef.variable_defs:
<%
    var_iter = v.name + '_iter'
    inst_name = base.attr.inst_name(v.name)
%>\
    auto ${var_iter} = json_value.FindMember("${v.json_name}");
    if ( ${var_iter} != json_value.MemberEnd() ) {

        %if v.isArray:
        for( auto array_item = ${var_iter}->value.Begin(); array_item != ${var_iter}->value.End(); array_item++  ) {

            % if v.schema_type == 'string':
            assert(array_item->IsString());
            ${inst_name}.push_back(array_item->GetString());
            %elif v.schema_type == 'integer':
            assert(array_item->IsInt());
            ${inst_name}.push_back(array_item->GetInt());
            %elif v.schema_type == 'boolean':
            assert(array_item->IsBool());
            ${inst_name}.push_back(array_item->GetBool());
            %elif v.schema_type == 'object':
            assert(array_item->IsObject());
            ${inst_name}.push_back(${v.type}(*array_item));
            %elif v.schema_type == 'array':
            ## TODO: probably need to recursively handle arrays of arrays
            assert(array_item->IsArray());
            vector<${v.type}> item_array;
            ${inst_name}.push_back(${v.type}(item_array));
            %endif
        }
        %else:
        % if v.schema_type == 'string':
        assert(${var_iter}->value.IsString());
        ${inst_name} = ${var_iter}->value.GetString();
        %elif v.schema_type == 'integer':
        assert(${var_iter}->value.IsInt());
        ${inst_name} = ${var_iter}->value.GetInt();
        %elif v.schema_type == 'boolean':
        assert(${var_iter}->value.IsBool());
        ${inst_name} = ${var_iter}->value.GetBool();
        %elif v.schema_type == 'object':
        assert(${var_iter}->value.IsObject());
        ${inst_name} = ${v.type}(${var_iter}->value);
        %endif
        %endif
    }

    % endfor
}

string to_string(const ${classDef.name} &val, std::string indent/* = "" */, std::string pretty_print/* = "" */) {

    ostringstream os;

    os << indent << "{" << endl;
    % for v in classDef.variable_defs:
<%
    inst_name = base.attr.inst_name(v.name)
%>\
    %if v.isArray:
    os << indent << pretty_print << "\"${v.name}\": [";
    for( auto &array_item : val.${inst_name} ) {

        % if v.schema_type == 'string':
        os << "\"" << array_item << "\",";
        %elif v.schema_type == 'integer':
        os << array_item << ",";
        %elif v.schema_type == 'boolean':
        os << (array_item ? "true" : "false") << ",";
        %elif v.schema_type == 'object':
        os << endl << to_string(array_item, indent + pretty_print + pretty_print, pretty_print) << "," << endl;
##        %elif v.schema_type == 'array':
##        ## TODO: probably need to recursively handle arrays of arrays
##        assert(array_item->IsArray());
##        vector<${v.type}> item_array;
##        ${inst_name}.push_back(${v.type}(item_array));
        %endif
    }
    os << indent << pretty_print << "]," << endl;
    %else:
    % if v.schema_type == 'string':
    os << indent << pretty_print << "\"${v.name}\": \"" << val.${inst_name} << "\"," << endl;
    %elif v.schema_type == 'integer':
    os << indent << pretty_print << "\"${v.name}\": " << val.${inst_name} << "," << endl;
    %elif v.schema_type == 'boolean':
    os << indent << pretty_print << "\"${v.name}\": " << (val.${inst_name} ? "true" : "false") << "," << endl;
    %elif v.schema_type == 'object':
    os << indent << pretty_print << "\"${v.name}\": " << to_string(val.${inst_name}, indent + pretty_print, pretty_print) << "," << endl;
    %endif
    %endif
    % endfor
    os << indent << "}";

    return os.str();
}


<%
staticInitName = classDef.name_sans_prefix
%>\
${classDef.name} ${staticInitName}FromJsonData(const char *data, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], data, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    return ${classDef.name}(doc);
}

${classDef.name} ${staticInitName}FromFile(string filename) {

    ifstream is;

    stringstream buffer;

    is.open(filename);
    buffer << is.rdbuf();

    ${classDef.name} instance = ${staticInitName}FromJsonData(buffer.str().c_str(), buffer.str().length());

    return instance;
}

std::vector<${classDef.name}> ${staticInitName}ArrayFromData(const char *jsonData, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], jsonData, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    assert(doc.IsArray());

    std::vector<${classDef.name}> ${staticInitName}Array(doc.MemberCount());

    for( auto array_item = doc.Begin(); array_item != doc.End(); array_item++  ) {

        ${classDef.name} instance = ${classDef.name}(*array_item);
        ${staticInitName}Array.push_back(instance);
    }

    return ${staticInitName}Array;
}

} // namespace models
} // namespace ${namespace}

</%block>
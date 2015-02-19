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
        %elif v.schema_type == 'object':
        assert(${var_iter}->value.IsObject());
        ${inst_name} = ${v.type}(${var_iter}->value);
        %endif
        %endif
    }

    % endfor
}

string to_string(const ${classDef.name} &val, std::string indent/* = "" */) {

    ostringstream os;

    os << indent << "{" << ios::end;
    % for v in classDef.variable_defs:
<%
    inst_name = base.attr.inst_name(v.name)
%>\
    %if v.isArray:
    os << indent << indent << "\"${v.name}\": [";
    for( auto &array_item : val.${inst_name} ) {

        % if v.schema_type == 'string':
        os << "\"" << array_item << "\",";
        %elif v.schema_type == 'integer':
        os << array_item << ",";
        %elif v.schema_type == 'object':
        os << to_string(array_item, indent + indent);
##        %elif v.schema_type == 'array':
##        ## TODO: probably need to recursively handle arrays of arrays
##        assert(array_item->IsArray());
##        vector<${v.type}> item_array;
##        ${inst_name}.push_back(${v.type}(item_array));
        %endif
    }
    os << indent << indent << "]," << ios::end;
    %else:
    % if v.schema_type == 'string':
    os << indent << indent << "\"${v.name}\": \"" << val.${inst_name} << "\","<< ios::end;
    %elif v.schema_type == 'integer':
    os << indent << indent << "\"${v.name}\": " << val.${inst_name} << "," << ios::end;
    %elif v.schema_type == 'object':
    os << indent << indent << "\"${v.name}\": " << to_string(val.${inst_name}, indent + indent) << "," << ios::end;
    %endif
    %endif
    % endfor
    os << indent << "}" << ios::end;

    return os.str();
}


<%
staticInitName = classDef.name_sans_prefix
%>\
${classDef.name} *${staticInitName}FromJsonData(const char *data, size_t len) {

    std::vector<char> buffer(len + 1);

    std::memcpy(&buffer[0], data, len);

    Document doc;

    doc.ParseInsitu(&buffer[0]);

    return new ${classDef.name}(doc);
}

${classDef.name} *${staticInitName}FromFile(string filename) {

    ifstream is;

    stringstream buffer;

    is.open(filename);
    buffer << is.rdbuf();

    ${classDef.name} *instance = ${staticInitName}FromJsonData(buffer.str().c_str(), buffer.str().length());

    return instance;
}

} // namespace models
} // namespace ${namespace}

</%block>
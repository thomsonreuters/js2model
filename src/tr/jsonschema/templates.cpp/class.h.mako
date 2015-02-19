<%inherit file="base.mako" />
<%namespace name="base" file="base.mako" />
<%block name="code">
#include <string>
#include <unordered_map>
#include <vector>
% if classDef.dependencies:
% for dep in classDef.dependencies:
#include "${dep}.h"
% endfor
% endif
#include "document.h"
% if import_files:
% for import_file in import_files:
#import <${import_file}>
% endfor
% endif
% if classDef.super_types:
% for dep in classDef.super_types:
#import "${dep}.h"
% endfor
% endif

<%def name='propertyDecl(variableDef, usePrimitives=False)'>\
<%
    (varType, isRef, itemsType) = base.attr.convertType(variableDef, usePrimitives)
%>\
    ${varType} ${base.attr.inst_name(variableDef.name)};\
</%def>\

#pragma once

namespace ${namespace} {
namespace models {
<%
    superClass = classDef.superClasses[0] if len(classDef.superClasses) else None
%>
class ${classDef.name} ${(': protected ' + superClass) if superClass else ''} {

public:
% for v in classDef.variable_defs:
${propertyDecl(v)}
% endfor
% if include_additional_properties:
    std::unordered_map<std::string, std::string> additionalProperties;
% endif

public:

    ${classDef.name}() = default;
    ${classDef.name}(const ${classDef.name} &other) = default;
    ${classDef.name}(const rapidjson::Value &value);

}; // class ${classDef.name}

std::string to_string(const ${classDef.name} &val, std::string indent = "");

<%
staticInitName = classDef.name_sans_prefix
%>\
${classDef.name} *${staticInitName}FromData(const char * jsonData);
${classDef.name} *${staticInitName}FromFile(std::string filename);


} // namespace models
} // namespace ${namespace}
</%block>
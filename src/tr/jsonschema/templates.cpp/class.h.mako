<%inherit file="base.mako" />
<%namespace name="base" file="base.mako" />
<%block name="code">
#include <string>
#include <unordered_map>
#include "jsonModelSchema.h"
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
% if classDef.dependencies:
% for dep in classDef.dependencies:
@class ${dep}; \
% endfor
% endif

namespace ${namespace} {
namespace models {
% if not skip_deserialization:
<%
    schemaSuperClass = "%sSchema" % (classDef.superClasses[0] if len(classDef.superClasses) else 'JSONModel')
%>
class ${classDef.name}Schema : protected ${schemaSuperClass} {
}
% endif
<%
    superClass = classDef.superClasses[0] if len(classDef.superClasses) else 'NSObject'
    protocols =  '<JSONModelSerialize' + ( (',' + classDef.interfaces|join(', ')) if classDef.interfaces else '') + '>'
%>
class ${classDef.name} : protected ${superClass} {

public:
% for v in classDef.variable_defs:
${base.propertyDecl(v)}
% endfor
% if include_additional_properties:
    std::unordered_map<std::string, std::string> additionalProperties;
% endif

% if not skip_deserialization:
<%
staticInitName = classDef.name_sans_prefix
%>\

public:
    static artwork * ${staticInitName}FromData(const unsigned char * jsonData);
    static artwork * ${staticInitName}FromFile(std::string filename);
% endif

}; // class ${classDef.name}

} // namespace models
} // namespace ${namespace}
</%block>
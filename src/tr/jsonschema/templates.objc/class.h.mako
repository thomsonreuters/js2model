<%inherit file="base.mako" />
<%namespace name="base" file="base.mako" />
<%block name="code">
#import <Foundation/Foundation.h>
#import "JSONModelSchema.h"
% if importFiles:
% for importFile in importFiles:
#import <${importFile}>
% endfor
% endif
% if classDef.superTypes:
% for dep in classDef.superTypes:
#import "${dep}.h"
% endfor
% endif
% if classDef.dependencies:
% for dep in classDef.dependencies:
@class ${dep}; \
% endfor
% endif
<%
    schemaSuperClass = "%sSchema" % (classDef.superClasses[0] if len(classDef.superClasses) else 'JSONModel')
%>
@interface ${classDef.name}Schema : ${schemaSuperClass}
@end
<%
    superClass = classDef.superClasses[0] if len(classDef.superClasses) else 'NSObject'
    protocols =  '<JSONModelSerialize' + ( (',' + classDef.interfaces|join(', ')) if classDef.interfaces else '') + '>'
%>
@interface ${classDef.name} : ${superClass} ${protocols}

% for v in classDef.variable_defs:
${base.propertyDecl(v)}
% endfor

@end
</%block>
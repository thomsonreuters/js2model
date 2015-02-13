<%inherit file="base.mako" />
<%namespace name="base" file="base.mako" />
<%block name="code">
#import <Foundation/Foundation.h>
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
<%
    superClass = classDef.superClasses[0] if len(classDef.superClasses) else 'NSObject'
    if len(classDef.interfaces):
        protocols =  '<' + ( (classDef.interfaces|join(', ')) if classDef.interfaces else '') + '>'
    else:
        protocols = ''
%>
@interface ${classDef.name} : ${superClass} ${protocols}

% for v in classDef.variable_defs:
${base.propertyDecl(v)}
% endfor
% if not skip_deserialization:
<%
staticInitName = classDef.name_sans_prefix
%>\

-(instancetype) initWithDict:(NSDictionary *)dict;

-(instancetype) initWithJSONData:(NSData *)data
                            error:(NSError* __autoreleasing *)error;

-(instancetype) initWithJSONFromFileNamed:(NSString *)filename
                                     error:(NSError* __autoreleasing *)error;

+(instancetype) ${staticInitName}WithDict:(NSDictionary *)dict;

+(instancetype) ${staticInitName}WithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error;

+(instancetype) ${staticInitName}WithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error;

+(NSArray*) ${staticInitName}ArrayWithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error;

+(NSArray*) ${staticInitName}ArrayWithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error;

% endif
@end
</%block>
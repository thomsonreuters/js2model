<%doc>
Copyright (c) 2015 Thomson Reuters

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
</%doc>
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
#import "${dep}"
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
staticInitName = classDef.plain_name
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

-(NSDictionary*)JSONObject;
-(NSData*)JSONData;

% endif
@end
</%block>
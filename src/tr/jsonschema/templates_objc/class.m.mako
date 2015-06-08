<%doc>\
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
</%doc>\
<%inherit file="base.mako" /> \
<%namespace name="base" file="base.mako" /> \
<%block name="code">
#import "${classDef.header_file}"
% if classDef.dependencies:
% for dep in classDef.dependencies:
#import "${dep}"
% endfor
% endif

@implementation ${classDef.name}{
##    % if include_additional_properties:
##    NSMutableDictionary *_additionalProperties;
##    % endif
}

% if classDef.has_var_defaults:
- (instancetype)init
{
    self = [super init];
    if (self) {
    	// custom intialization code
##        % if include_additional_properties:
##        _additionalProperties = [NSMutableDictionary new];
##        % endif

% for v in classDef.variable_defs:
${ base.initVarToDefault(v) }\
% endfor
    }
    return self;
}
% endif

-(instancetype)initWithDict:(NSDictionary *)dict {
    self = [self init];
    if (self) {
% for v in classDef.variable_defs:

<%
propName = base.attr.normalize_prop_name(v.name)
%>\
        % if v.isArray:
<%
    (varType, isRef, itemsType) = base.attr.convertType(v)
%>\
        %if v.schema_type == "object":
        [dict[@"${v.json_name}"] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            [self.${propName} addObject: [[${itemsType.replace(' *','')} alloc] initWithDict:obj]];
        }];
        %else:
        [dict[@"${v.json_name}"] enumerateObjectsUsingBlock:^(${itemsType} obj, NSUInteger idx, BOOL *stop) {
            [self.${propName} addObject:obj];
        }];
        %endif
        % elif v.schema_type == "object":
<%
    (varType, isRef, itemsType) = base.attr.convertType(v)
%>\
        self.${propName} = [[${ varType.replace(' *','') } alloc] initWithDict:dict[@"${v.json_name}"]];
        % else:
        self.${propName} = dict[@"${v.json_name}"];
        % endif
% endfor
    }
    return self;
}

% if not skip_deserialization:
- (instancetype) initWithJSONData:(NSData *)data
                            error:(NSError* __autoreleasing *)error {

    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];

    NSAssert(jsonObj, @"No instances found in JSON");
    NSAssert(!*error, @"Error parsing JSON: %@", *error);

    self = [self initWithDict:jsonObj];

    if (self) {
    }
    return self;
}

/** Parses JSON data and creates an Objective-C instance.

@param cls Class type of top-most instance.
@param filename Name of file with JSON data to be parsed.
@param error Non-nil if any parsings errors occured.
*/
- (instancetype) initWithJSONFromFileNamed:(NSString *)filename
                                     error:(NSError* __autoreleasing *)error {

    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    self = [self initWithJSONData:jsonData error:error];
    if (self) {
    }
    return self;
}
<%
staticInitName = classDef.plain_name
%>\
+(instancetype) ${staticInitName}WithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

+(instancetype) ${staticInitName}WithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error {

    return [[self alloc] initWithJSONData:data error:error];
}

+(instancetype) ${staticInitName}WithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error {

    return [[self alloc] initWithJSONFromFileNamed:filename error:error];
}

+(NSArray*) ${staticInitName}ArrayWithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error {

    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];

    NSAssert([jsonObj isKindOfClass:[NSArray class]], @"Expecting a [] as top level of the JSON data.");
    NSAssert(jsonObj, @"No instances found in JSON");
    NSAssert(!*error, @"Error parsing JSON: %@", *error);

    NSMutableArray *array = [NSMutableArray new];

    [jsonObj enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {

        ${classDef.name} *i = [self ${staticInitName}WithDict:obj];
        [array addObject:i];
    }];

    return array;
}

+(NSArray*) ${staticInitName}ArrayWithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error {

    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];

    return [self ${staticInitName}ArrayWithJSONData:jsonData error:error];
}
% endif
% for v in classDef.variable_defs:
${ base.lazyPropGetter(v) }\
% endfor

##-(NSMutableDictionary*)additionalProperties {
##% if include_additional_properties:
##    return _additionalProperties;
##% else:
##    [NSException raise:@"Method not implemented" format:@"additionalProperties is not implemented. Additional property support was disabled when generating this class."];
##    return nil;
##% endif
##}
\
##-(void)setValue:(id)value forAdditionalProperty:(NSString*)propertyName {
##% if include_additional_properties:
##    [_additionalProperties setObject:value forKey:propertyName];
##% else:
##    [NSException raise:@"Method not implemented" format:@"setValue:forAdditionalProperty: is not implemented. Additional property support was disabled when generating this class."];
##% endif
##}

##-(id)valueForAdditionalProperty:(NSString*)propertyName {
##% if include_additional_properties:
##    return [_additionalProperties valueForKey:propertyName];
##% else:
##    [NSException raise:@"Method not implemented" format:@"valueForAdditionalProperty is not implemented. Additional property support was disabled when generating this class."];
##    return nil;
##% endif
##}
\
-(NSDictionary*)JSONObject {

    NSMutableDictionary *jsonObj = [NSMutableDictionary new];

% for v in classDef.variable_defs:
\
<%
propName = base.attr.normalize_prop_name(v.name)
%>\
    % if v.isArray:
<%
    (varType, isRef, itemsType) = base.attr.convertType(v)
%>\
    __block NSMutableArray *${propName}JSONObjects = [NSMutableArray new];
    [self.${propName} enumerateObjectsUsingBlock:^(NSObject *obj, NSUInteger idx, BOOL *stop) {

        if ([obj respondsToSelector:@selector(JSONObject)]) {
            [${propName}JSONObjects addObject:[obj performSelector:@selector(JSONObject)]];
        }
        else {
            [${propName}JSONObjects addObject:obj];
        }
    }];
    jsonObj[@"${propName}"] = ${propName}JSONObjects;

    % elif v.schema_type == "object":
<%
    (varType, isRef, itemsType) = base.attr.convertType(v)
%>\
    if( !self.${propName} ) {
        jsonObj[@"${propName}"] = [NSNull null];
    }
    else {
        if ([self.${propName} respondsToSelector:@selector(JSONObject)]) {
            jsonObj[@"${propName}"] = [self.${propName} performSelector:@selector(JSONObject)];
        }
        else {
            jsonObj[@"${propName}"] = self.${propName};
        }
    }
    % else:
    jsonObj[@"${propName}"] = self.${propName} ? self.${propName} : [NSNull null];
    % endif
% endfor

    return jsonObj;
}

-(NSData*)JSONData {

    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:[self JSONObject] options:0 error:&error];

    if (error) {
        NSLog(@"%@", error);
        return nil;
    }

    return data;
}

-(NSString*)debugDescription {

    NSMutableString *dd = [NSMutableString new];

    [dd appendString:@"{"];

% for v in classDef.variable_defs:

<%
propName = base.attr.normalize_prop_name(v.name)
%>\
    % if v.isArray:
<%
    (varType, isRef, itemsType) = base.attr.convertType(v)
%>\
    [dd appendString:@"\n${propName}: ["];

    [self.${propName} enumerateObjectsUsingBlock:^(NSObject *obj, NSUInteger idx, BOOL *stop) {
        [dd appendFormat:@"%@,", obj.debugDescription];
    }];

    [dd appendString:@"]"];

    % elif v.schema_type == "object":
<%
    (varType, isRef, itemsType) = base.attr.convertType(v)
%>\
    [dd appendFormat:@"\n${propName}: %@", self.${propName}.debugDescription];
    % elif v.schema_type == "string":
    [dd appendFormat:@"\n${propName}: \"%@\"", self.${propName}];
    % else:
    [dd appendFormat:@"\n${propName}: %@", self.${propName}];
    % endif
% endfor
    [dd appendString:@"}"];

    return dd;
}


@end
</%block>
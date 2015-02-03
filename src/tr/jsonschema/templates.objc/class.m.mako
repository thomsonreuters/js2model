<%inherit file="base.mako" />
<%namespace name="base" file="base.mako" />
<%block name="code">
#import "${classDef.declName}"
% if classDef.dependencies:
% for dep in classDef.dependencies:
#import "${dep}.h"
% endfor
% endif
#import "TRJSONModelLoader.h"

#define valueWithSel(sel) [NSValue valueWithPointer: @selector(sel)]

% if not skip_deserialization:
<%
    metaClassName = classDef.name + "Schema"
    metaClassVar = classDef.name + "SchemaInstance" 
%>\
@implementation ${metaClassName}

- (instancetype)init
{
    self = [super init];
    if (self) {
<%doc>\
    Macro that renders code to add properties to the appropriate dictionary
</%doc>\
<%def name="metaProps(dictName, props)">\
    % if len(props):
        [self.${dictName} addEntriesFromDictionary: @{
        % for v in props:
        <%
        propName = base.attr.normalize_prop_name(v.name)
        setter = 'set' + base.attr.firstupper(propName)
        getter = propName
        %>\
        % if v.isArray:
        <%
            (varType, isRef, itemsType) = base.attr.convertType(v)
        %>\
        @"${v.name}": [JSONPropertyMeta initWithGetter:@selector(${getter})
                                                 setter:@selector(${setter}:)
                                                 type:[${ varType.replace(' *','') } class]
                                             itemType:[${ itemsType.replace(' *','') } class]],
        % elif v.schema_type == "object":
        <%
            (varType, isRef, itemsType) = base.attr.convertType(v)
        %>\
        @"${v.name}": [JSONPropertyMeta initWithGetter:@selector(${getter})
                                                 setter:@selector(${setter}:)
                                                   type:[${ varType.replace(' *','') } class]],
        % else:
        @"${v.name}": [JSONPropertyMeta initWithGetter:@selector(${getter})
                                                 setter:@selector(${setter}:)],
        % endif
        % endfor
        }];
    % endif
</%def>\
## {%- set objectVars = classDef.variable_defs|selectattr("schema_type", "equalto", "object")|rejectattr("isArray")|list -%}
${ metaProps("objects", [v for v in classDef.variable_defs if v.schema_type == 'object' and not v.isArray]) }
## {%- set arrayVars = classDef.variable_defs|selectattr("schema_type", "equalto", "object")|selectattr("isArray")|list -%}
${ metaProps("arrays", [v for v in classDef.variable_defs if  v.schema_type == 'object' and v.isArray]) }
## ${ metaProps("strings", classDef.variable_defs|selectattr("schema_type", "equalto", "string")|list) }
${ metaProps("strings", [v for v in classDef.variable_defs if v.schema_type == 'string']) }
## ${ metaProps("booleans", classDef.variable_defs|selectattr("schema_type", "equalto", "boolean")|list) }
${ metaProps("booleans", [v for v in classDef.variable_defs if v.schema_type == 'boolean']) }
## ${ metaProps("numbers", classDef.variable_defs|selectattr("schema_type", "equalto", "number")|list) }
${ metaProps("numbers", [v for v in classDef.variable_defs if v.schema_type == 'number']) }
## ${ metaProps("integers", classDef.variable_defs|selectattr("schema_type", "equalto", "number")|list) }
${ metaProps("integers", [v for v in classDef.variable_defs if v.schema_type == 'integer']) }
    }
    return self;
}
@end

static ${metaClassName} *${metaClassVar};
% endif

@implementation ${classDef.name}{
    % if include_additional_properties:
    NSMutableDictionary *_additionalProperties;
    % endif
}

% if not skip_deserialization:
+(void)initialize {

    if( self == [${classDef.name} class] )
    {
        ${metaClassVar} = [${metaClassName} new];
    }
}
% endif

% if classDef.hasVarDefaults:
- (instancetype)init
{
    self = [super init];
    if (self) {
    	// custom intialization code
        % if include_additional_properties:
        _additionalProperties = [NSMutableDictionary new];
        % endif

% for v in classDef.variable_defs:
${ base.initVarToDefault(v) }\
% endfor
    }
    return self;
}
% endif

% if not skip_deserialization:
- (instancetype) initWithJSONData:(NSData *)data
                            error:(NSError* __autoreleasing *)error {
    self = [self init];
    if (self) {
        [TRJSONModelLoader load:self withJSONData:data error:error];
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

    self = [self init];
    if (self) {
        [TRJSONModelLoader load:self withJSONFromFileNamed:filename error:error];
    }
    return self;
}
% endif
% for v in classDef.variable_defs:
${ base.lazyPropGetter(v) }\
% endfor
% if not skip_deserialization:
- (JSONInstanceMeta *)objectForPropertyNamed:(NSString *)propertyName {

    return [${metaClassVar} objectForPropertyNamed:propertyName forInstance:self];
}

- (JSONInstanceMeta *)arrayForPropertyNamed:(NSString *)propertyName {
    return [${metaClassVar} arrayForPropertyNamed:propertyName forInstance:self];
}

- (void)setString:(NSString *)val forProperty:(NSString *)propertyName {
    [${metaClassVar} setString:val forProperty:propertyName forInstance:self];
}

- (void)setNumber:(NSNumber *)val forProperty:(NSString *)propertyName {
    [${metaClassVar} setNumber:val forProperty:propertyName forInstance:self];
}

- (void)setInteger:(NSNumber *)val forProperty:(NSString *)propertyName {
    [${metaClassVar} setInteger:val forProperty:propertyName forInstance:self];
}

- (void)setBoolean:(NSNumber *)val forProperty:(NSString *)propertyName {
    [${metaClassVar} setBoolean:val forProperty:propertyName forInstance:self];
}

- (void)setNullForProperty:(NSString *)propertyName {
    [${metaClassVar} setNullForProperty:propertyName forInstance:self];
}

+(JSONModelSchema *)modelSchema {
    return ${metaClassVar} ;
}
% endif

-(NSMutableDictionary*)additionalProperties {
% if include_additional_properties:
    return _additionalProperties;
% else:
    [NSException raise:@"Method not implemented" format:@"additionalProperties is not implemented. Additional property support was disabled when generating this class."];
    return nil;
% endif
}

-(void)setValue:(id)value forAdditionalProperty:(NSString*)propertyName {
% if include_additional_properties:
    [_additionalProperties setObject:value forKey:propertyName];
% else:
    [NSException raise:@"Method not implemented" format:@"setValue:forAdditionalProperty: is not implemented. Additional property support was disabled when generating this class."];
% endif
}

-(id)valueForAdditionalProperty:(NSString*)propertyName {
% if include_additional_properties:
    return [_additionalProperties valueForKey:propertyName];
% else:
    [NSException raise:@"Method not implemented" format:@"valueForAdditionalProperty is not implemented. Additional property support was disabled when generating this class."];
    return nil;
% endif
}
@end
</%block>
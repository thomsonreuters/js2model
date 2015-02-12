<%inherit file="base.mako" />
<%namespace name="base" file="base.mako" />
<%block name="code">
#include "${classDef.decl_name}"
% if classDef.dependencies:
% for dep in classDef.dependencies:
#include "${dep}.h"
% endfor
% endif
#include "TRJSONModelLoader.h"

using namespace std;

namespace ${namespace} {
namespace models {

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
        @"${v.json_name}": [JSONPropertyMeta propertyMetaWithGetter:@selector(${getter})
                                                 setter:@selector(${setter}:)
                                                 type:[${ varType.replace(' *','') } class]
                                             itemType:[${ itemsType.replace(' *','') } class]],
        % elif v.effective_schema_type() == "object":
        <%
            (varType, isRef, itemsType) = base.attr.convertType(v)
        %>\
        @"${v.json_name}": [JSONPropertyMeta propertyMetaWithGetter:@selector(${getter})
                                                 setter:@selector(${setter}:)
                                                   type:[${ varType.replace(' *','') } class]],
        % else:
        @"${v.json_name}": [JSONPropertyMeta propertyMetaWithGetter:@selector(${getter})
                                                 setter:@selector(${setter}:)],
        % endif
        % endfor
        }];
    % endif
</%def>\
${ metaProps("objects", [v for v in classDef.variable_defs if (v.effective_schema_type() == 'object' and not v.isArray) or v.effective_schema_type() == 'null']) }
${ metaProps("arrays", [v for v in classDef.variable_defs if v.isArray]) }
${ metaProps("strings", [v for v in classDef.variable_defs if v.effective_schema_type() == 'string']) }
${ metaProps("booleans", [v for v in classDef.variable_defs if v.effective_schema_type() == 'boolean']) }
${ metaProps("numbers", [v for v in classDef.variable_defs if v.effective_schema_type() == 'number']) }
${ metaProps("integers", [v for v in classDef.variable_defs if v.effective_schema_type() == 'integer']) }
    }
    return self;
}
@end

static ${metaClassName} *${metaClassVar} = new ${metaClassName}();
% endif

% if classDef.has_var_defaults:
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
<%
staticInitName = classDef.name_sans_prefix
%>\
${classDef.name} *${classDef.name}::${staticInitName}FromData(const unsigned char *data) {

    //return [[self alloc] initWithJSONData:data error:error];
}

${classDef.name} *${classDef.name}::${staticInitName}FromFile(string filename) {

    //return [[self alloc] initWithJSONFromFileNamed:filename error:error];
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

} // namespace models
} // namespace ${namespace}

</%block>
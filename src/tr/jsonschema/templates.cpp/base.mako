<%doc>
Utility functions
</%doc>\
<%!
def firstlower(value):
  return value[0].lower() + value[1:]
##
##    equalto = lambda value, other: value == other

def firstupper(value):
    return value[0].upper() + value[1:]
%>\
<%doc>
Maps for mapping JSON types to Obj C types.
</%doc>\
<%!
    typeMap = {
        'string':  'string',
        'dict':    'std::unordered_map',
        'integer': 'int',
        'number':  'float',
        'boolean': 'bool',
        'null':	   'void *',
        'any':	   'void *'
    }

    primitivesTypeMap = {
        'string':  'string',
        'dict':    'std::unordered_map',
        'integer': 'int',
        'number':  'float',
        'boolean': 'bool',
        'null':	   'void *',
        'any':	   'void *'
    }

    primitivesTypeIsRef = {
        'string':  True,
        'dict':    True,
        'integer': False,
        'number':  False,
        'boolean': False,
        'null':	   True,
        'any':	   True
    }
%>\
<%doc>
Make sure property names are valid per C++ rules.
</%doc>
<%!
    def normalize_prop_name(propName):
        #return "id_" if propName == "id" else  propName
        return propName
%>\
##<%!
##    def convertJsTypeToObjc(jsType, usePrimitives=False):
##
##        if usePrimitives:
##            if jsType in primitivesTypeMap:
##                varType = primitivesTypeMap[jsType]
##                isRef = primitivesTypeIsRef[jsType]
##            else:
##                varType = variableDef.type + ' *'
##                isRef = True
##        else:
##            varType = jsType + ' *' if not jsType in typeMap else typeMap[jsType]
##            isRef = True
##
##        return (varType, isRef)
##%>
<%doc>
Convert a JSON type to an Objective C type.
</%doc>
<%!
    def convertType(variableDef, usePrimitives=False):

        if usePrimitives:
            if variableDef.type in primitivesTypeMap:
                cppType = primitivesTypeMap[variableDef.type]
                isRef = primitivesTypeIsRef[variableDef.type]
            else:
                cppType = variableDef.type
                isRef = True
        else:
            cppType = variableDef.type if not variableDef.type in typeMap else typeMap[variableDef.type]
            isRef = True

        if variableDef.isArray:
             varType = "std::vector<%s>" % cppType
             itemType = cppType
        else:
             varType = cppType
             itemType = None

        return (varType, isRef, itemType)
%>\
<%def name='propertyDecl(variableDef, usePrimitives=False)'>\
<%
    (varType, isRef, itemsType) = convertType(variableDef, usePrimitives)
%>\
    ${varType} ${normalize_prop_name(variableDef.name)};\
</%def>\
<%def name='lazyPropGetter(variableDef, usePrimitives=False)'>\
<%
(varType, isRef, itemsType) = convertType(variableDef, usePrimitives)
%>\
% if varType == "NSDictionary *" or varType == "NSMutableArray *":
<%
prop_name = variableDef.name
ivar_name = '_' + prop_name
prop_classname = varType.replace(' *','')
%>\
-(${varType}) ${prop_name} {

    if( ! ${ivar_name} ) {
        ${ivar_name} = [${prop_classname} new];
    }

    return ${ivar_name};
}
% endif
</%def>\
<%def name='initVarToDefault(variableDef, usePrimitives=False)'>\
    <%
    (varType, isRef, itemsType) = convertType(variableDef, usePrimitives)
    %>\
    % if not variableDef.default == None:
    <%
        propName = variableDef.name
        ivarName = '_' + propName
    %>\
        % if not isRef:
            ${ivarName} = ${variableDef.default};
        % elif varType == "NSNumber *":
            % if varDef.default == False:
                ${ivarName} = @NO;
            % elif varDef.default == True:
                ${ivarName} = @YES;
            % endif
        % endif
    % endif
</%def>\
//
//  ${file_name}
//
//  Created by js2Model on ${timestamp}.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//
<%block name="code" />
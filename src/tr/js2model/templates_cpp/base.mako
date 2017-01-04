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

def inst_name(value):
##    return 'm' + value[0].upper() + value[1:]
    return normalize_prop_name(value)
%>
<%
def normalize_class_name(value):
##    return 'm' + value[0].upper() + value[1:]
    return value
%>\
<%doc>
Maps for mapping JSON types to Obj C types.
</%doc>\
<%!
    typeMap = {
        'string':  'std::string',
        'dict':    'std::unordered_map',
        'integer': 'int',
        'number':  'float',
        'boolean': 'bool',
        'null':	   'void',
        'any':	   'void'
    }

    primitivesTypeMap = {
        'string':  'std::string',
        'dict':    'std::unordered_map',
        'integer': 'int',
        'number':  'float',
        'boolean': 'bool',
        'null':	   'void',
        'any':	   'void'
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
<%
def inst_name(value):
    #return 'm' + normalize_prop_name(value[0].upper() + value[1:])
    return normalize_prop_name(value)
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
//
<%block name="code" />
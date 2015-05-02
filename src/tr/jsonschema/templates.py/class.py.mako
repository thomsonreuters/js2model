<%
type_default_map = {
    'string':  None,
    'dict':    {},
    'integer': 0,
    'number':  0,
    'boolean': false,
    'null':	   None,
    'any':	   None
}

def default_value(var_def):

    if var_def.default:
        return var_def.default
    elif var_def.type in type_default_map:
        return type_default_map[var_def.type]
    else:
        return None
%>
import json
% for classDef in models:


class ${classDef.name}(object):

    def __init__(self):
        % for v in classDef.variable_defs:
        self.${v.name} = ${default_value(v)}
        % endfor

    @staticmethod
    def load_from_dict(data):

        instance = ${classDef.name}()

    % for v in classDef.variable_defs:
    % if v.schema_type == "object":

        ${v.name}_data = data.get("${v.json_name}", ${default_value(v)})
        instance.${v.name} = ${v.type}.load_from_dict(${v.name}_data) if ${v.name}_data else None
    % else:
        instance.${v.name} = data.get("${v.json_name}", ${default_value(v)})
    % endif
    % endfor

        return instance

    @staticmethod
    def load_from_json(json_string):

        return ${classDef.name}.load_from_dict(json.loads(json_string))

% endfor
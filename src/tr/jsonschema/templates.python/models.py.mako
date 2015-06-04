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

    if var_def.model_default:
        return var_def.model_default
    if var_def.default:
        return var_def.default
    elif var_def.model_type and var_def.model_type in type_default_map:
        return type_default_map[var_def.model_type]
    elif var_def.type in type_default_map:
        return type_default_map[var_def.type]
    else:
        return None
%>
import json

def to_int(str_val):
    try:
        return int(str_val)
    except:
        return 0
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
    % if v.isArray:
        % if v.schema_type == "object":
        instance.${v.name} = []
        ${v.name}_items = data.get("${v.json_name}", [])
        if isinstance(${v.name}_items, (list, tuple)):
            for ${v.name}_item_data in ${v.name}_items:
                ${v.name}_item = ${v.type}.load_from_dict(${v.name}_item_data)
                instance.${v.name}.append(${v.name}_item)
        else:
            instance.${v.name}.append(${v.type}.load_from_dict(${v.name}_items))
        % else:
        instance.${v.name}.append(d)
        % endif
    % elif v.schema_type == "object":

        ${v.name}_data = data.get("${v.json_name}", ${default_value(v)})
        instance.${v.name} = ${v.type}.load_from_dict(${v.name}_data) if ${v.name}_data else None
    % else:

        % if v.model_type == "integer" and v.type == "string":
        instance.${v.name} = to_int(data.get("${v.json_name}", ${default_value(v)}))
        % else:
        instance.${v.name} = data.get("${v.json_name}", ${default_value(v)})
        % endif
    % endif
    % endfor

        return instance

    @staticmethod
    def load_from_json(json_string):
        return ${classDef.name}.load_from_dict(json.loads(json_string))

    @staticmethod
    def load_from_file(file_path):
        with open(file_path) as f:
            return ${classDef.name}.load_from_dict(json.load(f))

% endfor
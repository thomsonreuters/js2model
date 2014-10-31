#!/usr/bin/env python

from __future__ import print_function, nested_scopes, generators, division, absolute_import, with_statement, \
    unicode_literals

import glob
import os
import datetime
import re
import jsonref
from jinja2 import PackageLoader, Environment
from jsonschema import Draft3Validator
from shutil import copytree, copy2, rmtree

__author__ = 'kevin zimmerman'


#
# Custom JSON loader to add custom meta data to schema's loaded from files
#
class JmgLoader(object):
    def __init__(self, store=(), cache_results=True):
        self.defaultLoader = jsonref.JsonLoader(store, cache_results)

    def __call__(self, uri, **kwargs):
        json = self.defaultLoader(uri, **kwargs)

        # keep track of URI that the schema was loaded from
        json['__uri__'] = uri

        return json


class JsonSchemaTypes(object):
    OBJECT = 'object'
    INTEGER = 'integer'
    STRING = 'string'
    NUMBER = 'number'
    BOOLEAN = 'boolean'
    ARRAY = 'array'
    DICT = 'dict'
    NULL = 'null'
    ANY = 'any'


class ClassDef(object):
    def __init__(self):
        self.name = None
        self.variable_defs = []
        self.superClasses = []
        self.interfaces = []
        self.package = None
        self.custom = {}

    @property
    def implName(self):
        return '%s.m' % self.name

    @property
    def declName(self):
        return '%s.h' % self.name

    @property
    def dependencies(self):
        dependencies = set()

        # for dep in [ivar.type for ivar in self.variable_defs if ivar.schemaType == JsonSchemaTypes.OBJECT]:
        # dependencies.add(dep)

        for varDef in self.variable_defs:
            if varDef.schema_type == JsonSchemaTypes.OBJECT:
                dependencies.add(varDef.type)

        return dependencies if len(dependencies) else None

    @property
    def superTypes(self):
        superTypes = set()

        for superClass in self.superClasses:
            superTypes.add(superClass)

        for interface in self.interfaces:
            superTypes.add(interface)

        return superTypes

    @property
    def hasVarDefaults(self):
        return True if len([d for d in self.variable_defs if not d.default is not None]) else False


class EnumDef(object):
    def __init__(self):
        self.name = None
        self.type = 'integer'
        self.values = []


class VariableDef(object):
    ACCESS_PUBLIC = "public"
    ACCESS_PRIVATE = "private"
    ACCESS_PROTECTED = "protected"

    STORAGE_STATIC = "static"
    STORAGE_IVAR = "ivar"

    def __init__(self, name):
        self.schema_type = JsonSchemaTypes.INTEGER
        self.type = JsonSchemaTypes.INTEGER
        self.name = name
        self.visibility = VariableDef.ACCESS_PROTECTED
        self.storage = VariableDef.STORAGE_IVAR
        self.default = None
        self.isArray = False
        self.isRequired = False
        self.uniqueItems = False
        self.maxItems = None
        self.minItems = None
        self.maximum = None
        self.minimum = None
        self.maxLength = None
        self.minLength = None
        self.title = None
        self.description = None
        self.format = None


def whiteSpaceToCamelCase(matched):
    if matched.lastindex == 1:
        return matched.group(1).upper()
    else:
        return ''

def firstUpperFilter(var):
    return var[0].upper() + var[1:]

class JsonSchema2Model(object):
    def __init__(self, outdir, import_files=None, super_classes=None, interfaces=None,
                 include_additional_properties=True,
                 lang='objc', prefix='TR', root_name=None):

        """

        :param outdir:
        :param import_files:
        :param super_classes:
        :param interfaces:
        :param include_additional_properties:
        :param lang:
        :param prefix:
        :param root_name:
        """
        self.outdir = outdir
        self.import_files = import_files
        self.super_classes = super_classes
        self.interfaces = interfaces
        self.include_additional_properties = include_additional_properties
        self.lang = lang
        self.prefix = prefix
        self.root_name = root_name

        self.jinja_env = Environment(loader=PackageLoader('tr.jsonschema.jsonschema2model', 'templates'))
        self.jinja_env.filters['firstupper'] = lambda value:  value[0].upper() + value[1:]
        self.jinja_env.filters['firstlower'] = lambda value:  value[0].lower() + value[1:]
        self.jinja_env.tests['equalto'] = lambda value, other: value == other

        self.models = {}
        self.enums = {}

    def renderModels(self):

        if not os.path.exists(self.outdir):
            os.makedirs(self.outdir)

        for classDef in self.models.values():
            self.renderModelToFile(classDef, 'objc.h.jinja')
            self.renderModelToFile(classDef, 'objc.m.jinja')

    def renderModelToFile(self, class_def, templ_name):

        # remove '.jinja', then use extension from the template name
        outfile_name = os.path.join(self.outdir, class_def.name + os.path.splitext(templ_name.replace('.jinja', ''))[1])

        decl_template = self.jinja_env.get_template(templ_name)

        with open(outfile_name, 'w') as f:
            f.write(decl_template.render(classDef=class_def, importFiles=self.import_files,
                                         timestamp=str(datetime.date.today())))

    def includeSupportFiles(self):
        support_path = os.path.join(os.path.dirname(__file__), 'templates', 'supportFiles')
        self.copyFiles(support_path, self.outdir)

    @staticmethod
    def copyFiles(src, dest):
        """


        :param src:
        :param dest:
        :rtype : object
        """
        src_files = os.listdir(src)
        for file_name in src_files:
            full_file_name = os.path.join(src, file_name)
            if os.path.isfile(full_file_name):
                copy2(full_file_name, dest)
            else:
                full_dest_path = os.path.join(dest, file_name)
                if os.path.exists(full_dest_path):
                    rmtree(full_dest_path)

                copytree(full_file_name, full_dest_path)

    def createModel(self, schema_object, scope):
        """

        :rtype : VariableDef
        """
        # $ref's should have already been resolved

        assert isinstance(schema_object, dict)

        assert 'type' in schema_object

        name = self.makVarName(scope[-1])

        schema_type = schema_object['type']

        var_def = VariableDef(name)
        var_def.schema_type = schema_type

        if 'required' in schema_object:
            var_def.isRequired = schema_object['required']

        if 'uniqueItems' in schema_object:
            var_def.uniqueItems = schema_object['uniqueItems']

        if 'maxItems' in schema_object:
            var_def.maxItems = schema_object['maxItems']

        if 'minItems' in schema_object:
            var_def.minItems = schema_object['minItems']

        if 'maximum' in schema_object:
            var_def.maximum = schema_object['maximum']

        if 'minimum' in schema_object:
            var_def.minimum = schema_object['minimum']

        if 'maxLength' in schema_object:
            var_def.maxLength = schema_object['maxLength']

        if 'minLength' in schema_object:
            var_def.minLength = schema_object['minLength']

        if 'default' in schema_object:
            var_def.default = schema_object['default']

        if 'title' in schema_object:
            var_def.title = schema_object['title']

        if 'description' in schema_object:
            var_def.description = schema_object['description']

        if 'format' in schema_object:
            var_def.format = schema_object['format']

        if schema_type == JsonSchemaTypes.OBJECT:

            class_def = ClassDef()

            # print("schema object:", schema_object)

            # set class name to typeName value it it exists, else use the current scope
            if 'typeName' in schema_object:
                class_name = schema_object['typeName']
            elif '__uri__' in schema_object:
                base_name = os.path.basename(schema_object['__uri__'])
                class_name = os.path.splitext(base_name)[0]
            else:
                class_name = scope[-1]

            class_def.name = self.makClassName(class_name)

            # TODO: should I check to see if the class is already in the models dict?

            # set super class, in increasing precendence
            extended = False
            if 'extends' in schema_object:
                prop_var_def = self.createModel(schema_object['extends'], scope)
                class_def.superClasses = [prop_var_def.type]
                extended = True

            elif '#superclass' in schema_object:
                class_def.superClasses = schema_object['#superclass'].split(',')

            elif len(self.super_classes):
                class_def.superClasses = self.super_classes

            if len(self.interfaces):
                class_def.interfaces = self.interfaces

            self.models[class_def.name] = class_def

            if 'properties' in schema_object:

                properties = schema_object['properties']

                for prop in properties.keys():
                    scope.append(prop)

                    prop_var_def = self.createModel(properties[prop], scope)
                    class_def.variable_defs.append(prop_var_def)

                    scope.pop()

            #
            # support for additionalProperties
            #
            include_additional_properties = self.include_additional_properties if not extended else False

            if 'additionalProperties' in schema_object:

                additional_properties = schema_object['additionalProperties']

                if type(additional_properties) is int and not additional_properties:
                    include_additional_properties = False
                else:
                    include_additional_properties = True

            if include_additional_properties:
                add_prop_var_def = VariableDef('additionalProperties')
                add_prop_var_def.type = JsonSchemaTypes.DICT
                class_def.variable_defs.append(add_prop_var_def)

            # add custom keywords
            class_def.custom = {k: v for k, v in schema_object.items() if k.startswith('#')}

            var_def.type = class_def.name

        elif schema_type == JsonSchemaTypes.ARRAY:

            assert 'items' in schema_object

            items = schema_object['items']

            var_def = self.createModel(items, scope)
            var_def.isArray = True

        elif 'enum' in schema_object:

            enum_def = EnumDef()
            enum_def.name = self.makClassName(schema_object['typeName'] if 'typeName' in schema_object else scope[-1])

            # TODO: should I check to see if the enum is already in the models dict?

            enum_def.type = schema_type
            enum_def.values = schema_type['enum']

            self.enums[enum_def.name] = enum_def

            var_def.type = enum_def.name
        else:
            var_def.type = schema_type

        return var_def

    def makVarName(self, name):
        var_name = re.sub('[ _-]+([a-z])?', whiteSpaceToCamelCase, name)
        var_name = re.sub('[^\w]', '', var_name)
        return var_name


    def makClassName(self, name):
        class_name = self.makVarName(name)
        class_name = class_name[:1].upper() + class_name[1:]

        if self.lang == 'objc' and self.prefix is not None:
            class_name = self.prefix + class_name

        return class_name

    def generateModels(self, files, include_support_files=False):

        loader = JmgLoader()

        for f in [file for fileGlob in files for file in glob.glob(fileGlob)]:

            if self.root_name:
                scope = [self.root_name]
            else:
                base_name = os.path.basename(f)
                base_uri = os.path.splitext(base_name)[0]
                scope = [base_uri]

            with open(f) as jsonFile:

                # root_schema = json.load(jsonFile)
                # base_uri = 'file://' + os.path.split(os.path.realpath(f))[0]
                base_uri = 'file://' + os.path.realpath(f)
                root_schema = jsonref.load(jsonFile, base_uri=base_uri, jsonschema=True, loader=loader)

                #TODO: Add exception handling
                Draft3Validator.check_schema(root_schema)

                assert isinstance(root_schema, dict)

                self.createModel(root_schema, scope)

        self.renderModels()

        if include_support_files:
            self.includeSupportFiles()
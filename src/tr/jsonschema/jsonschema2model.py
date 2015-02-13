#!/usr/bin/env python

from __future__ import print_function, nested_scopes, generators, division, absolute_import, with_statement, \
    unicode_literals

import glob
import os
import datetime
import re
import jsonref
import logging
import pkg_resources
from mako.lookup import TemplateLookup
from mako import exceptions

from jsonschema import Draft4Validator
from jsonschema.exceptions import SchemaError
from shutil import copytree, copy2, rmtree
from collections import namedtuple

__author__ = 'kevin zimmerman'

# create logger with 'spam_application'
logger = logging.getLogger('tr.jsonschema.JsonSchema2Model')
logger.setLevel(logging.DEBUG)

# create console handler with a higher log level
ch = logging.StreamHandler()
ch.setLevel(logging.WARNING)

# create formatter and add it to the handlers
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
ch.setFormatter(formatter)

# add the handlers to the logger
logger.addHandler(ch)


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
        self.name_sans_prefix = None
        self.variable_defs = []
        self.superClasses = []
        self.interfaces = []
        self.package = None
        self.custom = {}

    @property
    def impl_name(self):
        return '%s.m' % self.name

    @property
    def decl_name(self):
        return '%s.h' % self.name

    @property
    def dependencies(self):
        dependencies = set()

        # for dep in [ivar.type for ivar in self.variable_defs if ivar.schemaType == JsonSchemaTypes.OBJECT]:
        # dependencies.add(dep)

        for varDef in self.variable_defs:
            if varDef.schema_type == JsonSchemaTypes.OBJECT or varDef.isEnum:
                dependencies.add(varDef.type)

        return dependencies if len(dependencies) else None

    @property
    def super_types(self):
        supertypes = set()

        for superClass in self.superClasses:
            supertypes.add(superClass)

        for interface in self.interfaces:
            supertypes.add(interface)

        return supertypes

    @property
    def has_var_defaults(self):
        return True if len([d for d in self.variable_defs if d.default is not None]) else False


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

    def __init__(self, name, json_name=None):
        self.schema_type = JsonSchemaTypes.STRING
        self.type = JsonSchemaTypes.INTEGER
        self.name = name
        self.json_name = json_name if json_name else name
        self.visibility = VariableDef.ACCESS_PROTECTED
        self.storage = VariableDef.STORAGE_IVAR
        self.default = None
        self.isArray = False
        self.isEnum = False
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

    def effective_schema_type(self):
        if isinstance(self.schema_type, list) and \
                        len(self.schema_type) == 2 and \
                        JsonSchemaTypes.NULL in self.schema_type:

            return [t for t in self.schema_type if t != JsonSchemaTypes.NULL][0]
        else:
            return self.schema_type


def whitespace_to_camel_case(matched):
    if matched.lastindex == 1:
        return matched.group(1).upper()
    else:
        return ''


# def firstUpperFilter(var):
# return var[0].upper() + var[1:]

LangTemplates = namedtuple('LangTemplates', ['class_templates', 'enum_template', 'global_templates'])
LangConventions = namedtuple('LangConventions', ['cap_class_name'])

class TemplateManager(object):
    def __init__(self):
        self.lang_templates = {
            'objc': LangTemplates(["class.h.mako", "class.m.mako"], 'enum.h.mako', ["global.h.mako"]),
            'cpp': LangTemplates(["class.h.mako", "class.cpp.mako"], 'enum.h.mako', ["global.h.mako"]),
        }

        self.lang_conventions = {
            'objc': LangConventions(cap_class_name=True),
            'cpp': LangConventions(cap_class_name=False),
        }

    def get_template_lookup(self, language):
        template_dir = pkg_resources.resource_filename(__name__, 'templates.' + language)
        return TemplateLookup(directories=[template_dir])

    def get_template_files(self, lang):

        templs = self.lang_templates[lang]

        if not templs:
            logger.warning('No templates found for %s', lang)
            return None
        else:
            return templs

    def get_conventions(self, lang):

        conventions = self.lang_conventions[lang]

        if not conventions:
            logger.warning('No conventions found for %s', lang)
            return None
        else:
            return conventions

class JsonSchema2Model(object):
    SCHEMA_URI = '__uri__'

    def __init__(self, outdir, import_files=None, super_classes=None, interfaces=None,
                 include_additional_properties=True,
                 lang='objc', prefix='TR', namespace='tr', root_name=None, validate=True, verbose=False,
                 skip_deserialization=False, include_dependencies=True, template_manager=TemplateManager()):

        """

        :param outdir:
        :param import_files:
        :param super_classes:
        :param interfaces:
        :param include_additional_properties:
        :param lang:
        :param prefix:
        :param root_name:
        :param validate:
        :param verbose:
        :param skip_deserialization:
        """
        self.validate = validate
        self.outdir = outdir
        self.import_files = import_files
        self.super_classes = super_classes
        self.interfaces = interfaces
        self.include_additional_properties = include_additional_properties
        self.lang = lang
        self.prefix = prefix
        self.namespace = namespace
        self.root_name = root_name
        self.verbose = verbose
        self.skip_deserialization = skip_deserialization
        self.include_dependencies = include_dependencies

        self.models = {}
        self.enums = {}
        self.class_defs = {}
        self.template_manager = template_manager

        self.makolookup = template_manager.get_template_lookup(lang)

    def verbose_output(self, message):
        if self.verbose:
            print(message)

    def render_models(self):

        if not os.path.exists(self.outdir):
            os.makedirs(self.outdir)

        template_files = self.template_manager.get_template_files(self.lang)

        for classDef in self.models.values():

            for class_template in template_files.class_templates:
                self.render_model_to_file(classDef, class_template)

        if template_files.enum_template:
            for enumDef in self.enums.values():
                self.render_enum_to_file(enumDef, template_files.enum_template)

        for global_template in template_files.global_templates:
            self.render_global_header(self.models.values(), global_template)

    def render_model_to_file(self, class_def, templ_name):

        # remove '.jinja', then use extension from the template name
        src_file_name = class_def.name + os.path.splitext(templ_name.replace('.mako', ''))[1]
        outfile_name = os.path.join(self.outdir, src_file_name)

        decl_template = self.makolookup.get_template(templ_name)

        with open(outfile_name, 'w') as f:

            try:
                self.verbose_output("Writing %s" % outfile_name)
                f.write(decl_template.render(classDef=class_def, import_files=self.import_files,
                                             namespace=self.namespace,
                                             include_additional_properties=self.include_additional_properties,
                                             timestamp=str(datetime.date.today()), file_name=src_file_name,
                                             skip_deserialization=self.skip_deserialization))
            except:
                print(exceptions.text_error_template().render())

    def render_enum_to_file(self, enum_def, templ_name):

        # remove '.jinja', then use extension from the template name
        src_file_name = enum_def.name + os.path.splitext(templ_name.replace('.mako', ''))[1]
        outfile_name = os.path.join(self.outdir, src_file_name)

        decl_template = self.makolookup.get_template(templ_name)

        with open(outfile_name, 'w') as f:

            try:
                self.verbose_output("Writing %s" % outfile_name)
                f.write(decl_template.render(enumDef=enum_def, import_files=self.import_files,
                                             namespace=self.namespace,
                                             timestamp=str(datetime.date.today()), file_name=src_file_name,
                                             include_additional_properties=self.include_additional_properties))
            except:
                print(exceptions.text_error_template().render())

    def render_global_header(self, models, templ_name):

        # remove '.jinja', then use extension from the template name
        src_file_name = self.prefix + "Models" + os.path.splitext(templ_name.replace('.mako', ''))[1]
        outfile_name = os.path.join(self.outdir, src_file_name)

        decl_template = self.makolookup.get_template(templ_name)

        with open(outfile_name, 'w') as f:
            try:
                self.verbose_output("Writing %s" % outfile_name)
                f.write(decl_template.render(models=models, timestamp=str(datetime.date.today()),
                                             namespace=self.namespace,
                                             include_additional_properties=self.include_additional_properties,
                                             file_name=src_file_name))
            except:
                print(exceptions.text_error_template().render())

    def copy_dependencies(self):
        support_path = os.path.join(os.path.dirname(__file__), 'templates.' + self.lang, 'dependencies')
        self.copy_files(support_path, os.path.join(self.outdir, 'dependencies'))

    def copy_static_files(self):
        support_path = os.path.join(os.path.dirname(__file__), 'templates.' + self.lang, 'static')
        self.copy_files(support_path, self.outdir)

    @staticmethod
    def copy_files(src, dest):
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

    def get_schema_id(self, schema_object, scope):

        if 'id' in schema_object:
            return schema_object['id']
        elif JsonSchema2Model.SCHEMA_URI in schema_object:
            return schema_object[JsonSchema2Model.SCHEMA_URI]
        elif 'typeName' in schema_object:
            return schema_object['typeName']
        else:
            assert len(scope)
            return self.mk_class_name(scope[-1])

    def create_class_def(self, schema_object, scope):

        assert 'type' in schema_object and schema_object['type'] == JsonSchemaTypes.OBJECT

        class_id = self.get_schema_id(schema_object, scope)

        # if class already exists, use it
        if class_id in self.class_defs:

            return self.class_defs[class_id]

        else:

            class_def = ClassDef()

            self.class_defs[class_id] = class_def

            # print("schema object:", schema_object)

            # set class name to typeName value it it exists, else use the current scope
            if 'typeName' in schema_object:
                class_name = schema_object['typeName']
            elif JsonSchema2Model.SCHEMA_URI in schema_object:
                base_name = os.path.basename(schema_object[JsonSchema2Model.SCHEMA_URI])
                class_name = os.path.splitext(base_name)[0]
                class_name = class_name.replace('.schema', '')
            else:
                class_name = scope[-1]

            class_def.name = self.mk_class_name(class_name)
            class_def.name_sans_prefix = self.mk_var_name(class_name)

            # set super class, in increasing precendence
            extended = False
            if 'extends' in schema_object:
                prop_var_def = self.create_model(schema_object['extends'], scope)
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

                    prop_var_def = self.create_model(properties[prop], scope)
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

            return class_def

    def create_model(self, schema_object, scope):
        """

        :rtype : VariableDef
        """
        # $ref's should have already been resolved

        assert isinstance(schema_object, dict)

        json_name = scope[-1]
        name = self.mk_var_name(json_name)
        var_def = VariableDef(name, json_name)

        if 'title' in schema_object:
            var_def.title = schema_object['title']

        if 'description' in schema_object:
            var_def.description = schema_object['description']

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

        if 'format' in schema_object:
            var_def.format = schema_object['format']

        if 'type' in schema_object:

            schema_type = schema_object['type']

            var_def.schema_type = schema_type

            if schema_type == JsonSchemaTypes.OBJECT:

                class_def = self.create_class_def(schema_object, scope)
                var_def.type = class_def.name

            elif schema_type == JsonSchemaTypes.ARRAY:

                assert 'items' in schema_object

                items = schema_object['items']

                #
                # If *items* is a dict, then there is only a single item schema
                # for the array.
                #
                if isinstance(items, dict):
                    items_schema = items
                elif isinstance(items, list) and len(items):
                    items_schema = items[0]
                else:
                    # TODO: handle this case
                    logger.warning("Unexpected schema structure for 'items': %s", items)

                var_def = self.create_model(items_schema, scope)
                var_def.isArray = True

            elif isinstance(schema_type, basestring):
                var_def.type = schema_type

            elif isinstance(schema_type, list) and len(schema_type) == 2 and JsonSchemaTypes.NULL in schema_type:
                var_def.type = [t for t in schema_type if t != JsonSchemaTypes.NULL][0]
                logger.warning("Schema using '%s' from %s for 'type' of variable '%s'.",
                               var_def.effective_schema_type(), schema_type, name)

            else:
                # TODO: handle this case
                logger.warning("Union types not currently supported")

        elif 'enum' in schema_object:

            enum_def = EnumDef()
            enum_def.name = self.mk_class_name(schema_object['typeName'] if 'typeName' in schema_object else scope[-1])

            # TODO: should I check to see if the enum is already in the models dict?

            enum_def.type = 'int'
            enum_def.values = schema_object['enum']

            self.enums[enum_def.name] = enum_def

            var_def.type = enum_def.name
            var_def.isEnum = True
        else:
            logger.warning("Unknown schema type in %s", schema_object)

        return var_def

    @staticmethod
    def mk_var_name(name):
        var_name = re.sub('[ _-]+([a-z])?', whitespace_to_camel_case, name)
        var_name = re.sub('[^\w]', '', var_name)
        return var_name

    def mk_class_name(self, name):

        lang_conventions = self.template_manager.get_conventions(self.lang)
        class_name = self.mk_var_name(name)

        if lang_conventions.cap_class_name:
            class_name = class_name[:1].upper() + class_name[1:]
        else:
            class_name = class_name[:1].lower() + class_name[1:]

        if self.prefix is not None:
            class_name = "%s%s" % (self.prefix, class_name)

        return class_name

    def generate_models(self, files):

        loader = JmgLoader()

        for fname in (f for fileGlob in files for f in glob.glob(fileGlob)):

            if self.root_name:
                scope = [self.root_name]
            else:
                base_name = os.path.basename(fname)
                base_uri = os.path.splitext(base_name)[0]
                base_uri = base_uri.replace('.schema', '')
                scope = [base_uri]

            with open(fname) as jsonFile:

                # root_schema = json.load(jsonFile)
                # base_uri = 'file://' + os.path.split(os.path.realpath(f))[0]
                base_uri = 'file://' + os.path.realpath(fname)
                root_schema = jsonref.load(jsonFile, base_uri=base_uri, jsonschema=True, loader=loader)

                if self.validate:
                    # TODO: Add exception handling
                    try:
                        Draft4Validator.check_schema(root_schema)
                    except SchemaError as e:
                        print(e)

                assert isinstance(root_schema, dict)

                if JsonSchema2Model.SCHEMA_URI not in root_schema:
                    root_schema[JsonSchema2Model.SCHEMA_URI] = fname

                self.create_model(root_schema, scope)

        self.render_models()

        self.copy_static_files()

        if self.include_dependencies:
            self.copy_dependencies()
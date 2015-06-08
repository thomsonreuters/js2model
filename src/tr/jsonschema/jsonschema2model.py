#!/usr/bin/env python

# Copyright (c) 2015 Thomson Reuters
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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

#
# For  python 2/3 compatibility
#
try:
    basestring
except NameError:
    basestring = str

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

    def __setattr__(self, *_):
        raise ValueError("Trying to change a constant value", self)


class JsonSchemaKeywords(object):
    ITEMS = 'items'
    TITLE = 'title'
    DESCRIPTION = 'description'
    REQUIRED = 'required'
    UNIQUEITEMS = 'uniqueItems'
    MAXITEMS = 'maxItems'
    MINITEMS = 'minItems'
    MAXIMUM = 'maximum'
    MINIMUM = 'minimum'
    MAXLENGTH = 'maxLength'
    MINLENGTH = 'minLength'
    DEFAULT = 'default'
    FORMAT = 'format'
    TYPE = 'type'
    ENUM = 'enum'
    TYPENAME = 'typeName'
    ID = 'id'
    PROPERTIES = 'properties'
    EXTENDS = 'extends'
    ADDITIONAL_PROPERTIES = 'additionalProperties'

    # Extended keywords
    SUPERCLASS = '#superclass'
    MODEL_TYPE = '#modeltype'
    MODEL_DEFAULT = '#modeldefault'

    def __setattr__(self, *_):
        raise ValueError("Trying to change a constant value", self)


class ClassDef(object):
    def __init__(self):

        # Class name sans prefix/suffix
        self.plain_name = None

        # Class name
        self.name = None
        self.variable_defs = []
        self.superClasses = []
        self.interfaces = []
        self.package = None
        self.custom = {}
        self.header_file = None
        self.impl_file = None

    @property
    def dependencies(self):
        dependencies = set()

        # for dep in [ivar.type for ivar in self.variable_defs if ivar.schemaType == JsonSchemaTypes.OBJECT]:
        # dependencies.add(dep)

        for var_def in self.variable_defs:
            if var_def.header_file:
                dependencies.add(var_def.header_file)

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
        self.model_type = None
        self.name = name
        self.json_name = json_name if json_name else name
        self.header_file = None
        self.visibility = VariableDef.ACCESS_PROTECTED
        self.storage = VariableDef.STORAGE_IVAR
        self.default = None
        self.model_default = None
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


def whitespace_to_underbar(matched):
    if matched.lastindex == 1:
        return '_' + matched.group(1).lower()
    else:
        return '_'

# def firstUpperFilter(var):
# return var[0].upper() + var[1:]

LangTemplates = namedtuple('LangTemplates', ['class_templates', 'enum_template', 'global_templates'])


class LanguageTemplates(object):
    def __init__(self, header_template=None, impl_template=None, enum_template=None, global_templates=[]):
        self.header_template = header_template
        self.impl_template = impl_template
        self.enum_template = enum_template
        self.global_templates = global_templates


class LanguageConventions(object):

    NAME_CAMEL_CASE = 0
    NAME_UNDERBAR = 1

    def __init__(self, cap_class_name=True, use_prefix=True, type_suffix=None, ivar_name_convention=NAME_CAMEL_CASE,
                 class_name_convention=NAME_CAMEL_CASE):
        self.cap_class_name = cap_class_name
        self.use_prefix = use_prefix
        self.type_suffix = type_suffix
        self.ivar_name_convention = ivar_name_convention
        self.class_name_convention = class_name_convention


class TemplateManager(object):
    def __init__(self):
        self.lang_templates = {
            'objc': LanguageTemplates(header_template="class.h.mako", impl_template="class.m.mako",
                                      enum_template='enum.h.mako', global_templates=["models.h.mako"]),
            'cpp': LanguageTemplates(header_template="class.h.mako", impl_template="class.cpp.mako",
                                     enum_template='enum.h.mako', global_templates=["models.h.mako"]),
            'py': LanguageTemplates(global_templates=["models.py.mako"]),
        }

        self.lang_conventions = {
            'objc': LanguageConventions(),
            'cpp': LanguageConventions(cap_class_name=False, use_prefix=False, type_suffix='_t'),
            'py': LanguageConventions(use_prefix=False, ivar_name_convention=LanguageConventions.NAME_UNDERBAR),
        }

    def get_template_lookup(self, language):
        template_dir = pkg_resources.resource_filename(__name__, 'templates_' + language)
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
        conventions = self.template_manager.get_conventions(self.lang)

        for classDef in self.models.values():

            if template_files.header_template:
                self.render_model_to_file(classDef, classDef.header_file, template_files.header_template)

            if template_files.impl_template:
                self.render_model_to_file(classDef, classDef.impl_file, template_files.impl_template)

        if template_files.enum_template:
            for enumDef in self.enums.values():
                self.render_enum_to_file(enumDef, template_files.enum_template)

        for global_template in template_files.global_templates:
            self.render_global_template(self.models.values(), global_template)

    def render_model_to_file(self, class_def, src_file_name, templ_name):

        outfile_name = os.path.join(self.outdir, src_file_name)

        template = self.makolookup.get_template(templ_name)

        with open(outfile_name, 'w') as f:

            try:
                self.verbose_output("Writing %s" % outfile_name)
                f.write(template.render(classDef=class_def, import_files=self.import_files,
                                        namespace=self.namespace,
                                        include_additional_properties=self.include_additional_properties,
                                        timestamp=str(datetime.date.today()), file_name=src_file_name,
                                        skip_deserialization=self.skip_deserialization))
            except:
                print(exceptions.text_error_template().render())

    def render_enum_to_file(self, enum_def, templ_name):

        # remove '.jinja', then use extension from the template name
        src_file_name = self.mk_source_file_name(enum_def, templ_name)
        # src_file_name = enum_def.name + os.path.splitext(templ_name.replace('.mako', ''))[1]
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

    def render_global_template(self, models, templ_name):

        # remove '.mako', then use extension from the template name
        src_file_name = templ_name.replace('.mako', '')

        lang_conventions = self.template_manager.get_conventions(self.lang)

        if lang_conventions.use_prefix:
            src_file_name = self.prefix + src_file_name[0].upper() + src_file_name[1:]

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
        if os.path.exists(support_path):
            self.copy_files(support_path, os.path.join(self.outdir, 'dependencies'))

    def copy_static_files(self):
        support_path = os.path.join(os.path.dirname(__file__), 'templates.' + self.lang, 'static')
        if os.path.exists(support_path):
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

        if JsonSchemaKeywords.ID in schema_object:
            return schema_object[JsonSchemaKeywords.ID]
        elif JsonSchema2Model.SCHEMA_URI in schema_object:
            return schema_object[JsonSchema2Model.SCHEMA_URI]
        elif JsonSchemaKeywords.TYPENAME in schema_object:
            return schema_object[JsonSchemaKeywords.TYPENAME]
        else:
            assert len(scope)
            return self.mk_class_name(scope[-1])

    def create_class_def(self, schema_object, scope):

        assert JsonSchemaKeywords.TYPE in schema_object and schema_object[
                                                                JsonSchemaKeywords.TYPE] == JsonSchemaTypes.OBJECT

        class_id = self.get_schema_id(schema_object, scope)

        # if class already exists, use it
        if class_id in self.class_defs:

            return self.class_defs[class_id]

        else:

            class_def = ClassDef()

            self.class_defs[class_id] = class_def

            # print("schema object:", schema_object)

            # set class name to typeName value it it exists, else use the current scope
            if JsonSchemaKeywords.TYPENAME in schema_object:
                class_name = schema_object[JsonSchemaKeywords.TYPENAME]
            elif JsonSchema2Model.SCHEMA_URI in schema_object:
                base_name = os.path.basename(schema_object[JsonSchema2Model.SCHEMA_URI])
                class_name = os.path.splitext(base_name)[0]
                class_name = class_name.replace('.schema', '')
            else:
                class_name = scope[-1]

            lang_conventions = self.template_manager.get_conventions(self.lang)
            class_def.name = self.mk_class_name(class_name)
            class_def.plain_name = self.mk_var_name(class_name, lang_conventions.class_name_convention)

            # set super class, in increasing precendence
            extended = False
            if JsonSchemaKeywords.EXTENDS in schema_object:
                prop_var_def = self.create_model(schema_object[JsonSchemaKeywords.EXTENDS], scope)
                class_def.superClasses = [prop_var_def.type]
                extended = True

            elif JsonSchemaKeywords.SUPERCLASS in schema_object:
                class_def.superClasses = schema_object[JsonSchemaKeywords.SUPERCLASS].split(',')

            elif len(self.super_classes):
                class_def.superClasses = self.super_classes

            if len(self.interfaces):
                class_def.interfaces = self.interfaces

            self.models[class_def.name] = class_def

            if JsonSchemaKeywords.PROPERTIES in schema_object:

                properties = schema_object[JsonSchemaKeywords.PROPERTIES]

                for prop in properties.keys():
                    scope.append(prop)

                    prop_var_def = self.create_model(properties[prop], scope)
                    class_def.variable_defs.append(prop_var_def)

                    scope.pop()

            #
            # support for additionalProperties
            #
            # include_additional_properties = self.include_additional_properties if not extended else False

            # if JsonSchemaKeywords.ADDITIONAL_PROPERTIES in schema_object:
            #
            #     additional_properties = schema_object[JsonSchemaKeywords.ADDITIONAL_PROPERTIES]
            #
            #     if type(additional_properties) is int and not additional_properties:
            #         include_additional_properties = False
            #     else:
            #         include_additional_properties = True

            # if include_additional_properties:
            #     add_prop_var_def = VariableDef(JsonSchemaKeywords.ADDITIONAL_PROPERTIES)
            #     add_prop_var_def.type = JsonSchemaTypes.DICT
            #     class_def.variable_defs.append(add_prop_var_def)

            # add custom keywords
            class_def.custom = {k: v for k, v in schema_object.items() if k.startswith('#')}

            # Derive the source file names from the corresponding template names
            template_files = self.template_manager.get_template_files(self.lang)

            if template_files.header_template:
                class_def.header_file = self.mk_source_file_name(class_def, template_files.header_template)

            if template_files.impl_template:
                class_def.impl_file = self.mk_source_file_name(class_def, template_files.impl_template)

            return class_def

    def create_model(self, schema_object, scope):
        """

        :rtype : VariableDef
        """
        # $ref's should have already been resolved

        assert isinstance(schema_object, dict)

        json_name = scope[-1]
        lang_conventions = self.template_manager.get_conventions(self.lang)
        name = self.mk_var_name(json_name, lang_conventions.ivar_name_convention)
        var_def = VariableDef(name, json_name)

        if JsonSchemaKeywords.TITLE in schema_object:
            var_def.title = schema_object[JsonSchemaKeywords.TITLE]

        if JsonSchemaKeywords.DESCRIPTION in schema_object:
            var_def.description = schema_object[JsonSchemaKeywords.DESCRIPTION]

        if JsonSchemaKeywords.REQUIRED in schema_object:
            var_def.isRequired = schema_object[JsonSchemaKeywords.REQUIRED]

        if JsonSchemaKeywords.UNIQUEITEMS in schema_object:
            var_def.uniqueItems = schema_object[JsonSchemaKeywords.UNIQUEITEMS]

        if JsonSchemaKeywords.MAXITEMS in schema_object:
            var_def.maxItems = schema_object[JsonSchemaKeywords.MAXITEMS]

        if JsonSchemaKeywords.MINITEMS in schema_object:
            var_def.minItems = schema_object[JsonSchemaKeywords.MINITEMS]

        if JsonSchemaKeywords.MAXIMUM in schema_object:
            var_def.maximum = schema_object[JsonSchemaKeywords.MAXIMUM]

        if JsonSchemaKeywords.MINIMUM in schema_object:
            var_def.minimum = schema_object[JsonSchemaKeywords.MINIMUM]

        if JsonSchemaKeywords.MAXLENGTH in schema_object:
            var_def.maxLength = schema_object[JsonSchemaKeywords.MAXLENGTH]

        if JsonSchemaKeywords.MINLENGTH in schema_object:
            var_def.minLength = schema_object[JsonSchemaKeywords.MINLENGTH]

        if JsonSchemaKeywords.DEFAULT in schema_object:
            var_def.default = schema_object[JsonSchemaKeywords.DEFAULT]

        if JsonSchemaKeywords.MODEL_DEFAULT in schema_object:
            var_def.model_default = schema_object[JsonSchemaKeywords.MODEL_DEFAULT]

        if JsonSchemaKeywords.FORMAT in schema_object:
            var_def.format = schema_object[JsonSchemaKeywords.FORMAT]

        if JsonSchemaKeywords.TYPE in schema_object:

            schema_type = schema_object[JsonSchemaKeywords.TYPE]

            var_def.schema_type = schema_type

            if JsonSchemaKeywords.MODEL_TYPE in schema_object:
                var_def.model_type = schema_object[JsonSchemaKeywords.MODEL_TYPE]

            if schema_type == JsonSchemaTypes.OBJECT:

                class_def = self.create_class_def(schema_object, scope)
                var_def.type = class_def.name
                var_def.header_file = class_def.header_file

            elif schema_type == JsonSchemaTypes.ARRAY:

                assert JsonSchemaKeywords.ITEMS in schema_object

                items = schema_object[JsonSchemaKeywords.ITEMS]

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

            #
            # Union types
            #
            elif isinstance(schema_type, list):

                #
                # Special cases:
                #       1. has two items and one is NULL,
                #          then use the non-NULL type as the vartype.
                #
                #       2. has two items, one each of OBJECT and ARRAY,
                #          then use the OBJECT type as the vartype.
                #
                if len(schema_type) == 2:
                    if JsonSchemaTypes.NULL in schema_type:
                        var_def.type = [t for t in schema_type if t != JsonSchemaTypes.NULL][0]
                        logger.warning("Schema using '%s' from %s for 'type' of variable '%s'.",
                                       var_def.effective_schema_type(), schema_type, name)
                    # elif JsonSchemaTypes.OBJECT in schema_type and JsonSchemaTypes.ARRAY in schema_type:
                    #     var_def.type = [t for t in schema_type if t != JsonSchemaTypes.ARRAY][0]
                    #     logger.warning("Schema using '%s' from %s for 'type' of variable '%s'.",
                    #                    var_def.effective_schema_type(), schema_type, name)
                    else:
                        # TODO: handle this case
                        logger.warning("Complex union types not currently supported")
                else:
                    # TODO: handle this case
                    logger.warning("Complex union types not currently supported")

            else:
                # TODO: handle this case
                logger.warning("Unknown type definition")

        #
        # Enum types
        #
        elif JsonSchemaKeywords.ENUM in schema_object:

            enum_def = EnumDef()
            enum_def.name = self.mk_class_name(
                schema_object[JsonSchemaKeywords.TYPENAME] if JsonSchemaKeywords.TYPENAME in schema_object else scope[
                    -1])

            # TODO: should I check to see if the enum is already in the models dict?

            enum_def.type = 'int'
            enum_def.values = schema_object[JsonSchemaKeywords.ENUM]

            self.enums[enum_def.name] = enum_def

            var_def.type = enum_def.name
            var_def.isEnum = True
        else:
            logger.warning("Unknown schema type in %s", schema_object)

        return var_def

    def mk_var_name(self, name, conventions):

        var_name = re.sub('[ _-]+([A-Za-z])?',
                          whitespace_to_camel_case
                          if conventions == LanguageConventions.NAME_CAMEL_CASE
                          else whitespace_to_underbar, name)

        var_name = re.sub('[^\w]', '', var_name)
        return var_name

    def mk_class_name(self, name):

        lang_conventions = self.template_manager.get_conventions(self.lang)
        class_name = self.mk_var_name(name, lang_conventions.class_name_convention)

        if lang_conventions.cap_class_name:
            class_name = class_name[:1].upper() + class_name[1:]
        else:
            class_name = class_name[:1].lower() + class_name[1:]

        if self.prefix is not None and lang_conventions.use_prefix:
            class_name = "%s%s" % (self.prefix, class_name)

        if lang_conventions.type_suffix:
            class_name += lang_conventions.type_suffix

        return class_name

    def mk_source_file_name(self, class_def, templ_name):

        lang_conventions = self.template_manager.get_conventions(self.lang)

        # remove '.jinja', then use extension from the template name
        src_file_name = class_def.plain_name + os.path.splitext(templ_name.replace('.mako', ''))[1]

        if self.prefix is not None and lang_conventions and lang_conventions.use_prefix:
            src_file_name = self.prefix + src_file_name[0].upper() + src_file_name[1:]

        return src_file_name

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

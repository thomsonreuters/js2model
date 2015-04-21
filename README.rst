Overview
========

Js2model makes it easy to use JSON data as native class models.

JSON is ubiquitous and convenient, but parsing JSON into generic data
structures like dictionaries and arrays precludes the use of many native
language features. Js2model.py generates model classes
and custom deserialization code from JSON schema definitions.

Languages
=========

The script is designed to target multiple output languages. Currently, Objective-C and C++ are supported out of the box.
Future versions will add the ability to add your own language templates to support any language.

Documentation
=============

You can review the documentation `here <http://thomsonreuters.github.io/js2model/>`_

Usage
=====

::

    usage: js2model [-h] [-l LANG] [--prefix PREFIX] [--namespace NAMESPACE]
                    [--rootname ROOTNAME] [--novalidate] [-o OUTPUT]
                    [--implements IMPLEMENTS] [--super SUPER]
                    [--import IMPORT_FILES] [-v] [--no-deserialize]
                    [--no-dependencies]
                    FILES [FILES ...]

    Generate native data models from JSON Schema definitions.

    positional arguments:
        FILES                 JSON Schema files for model generation

    optional arguments:
        -h, --help            show this help message and exit
        -l LANG, --lang LANG  Target language. Supported values: objc, cpp (default:
                            objc)
        --prefix PREFIX       prefix for class names (default: TR)
        --namespace NAMESPACE
                            parent namespace for generated code (default: tr)
        --rootname ROOTNAME   Class name for root schema object (default: base name
                            of file)
        --novalidate          Skip schema validation
        -o OUTPUT, --output OUTPUT
                            Target directory of output files
        --implements IMPLEMENTS
                            Comma separated list of interface(s)|protocol(s)
                            supported by the generated classes
        --super SUPER         Comma separated list of super classes. Generated
                            classes inherit these
        --import IMPORT_FILES
                            Comma separated list of files to @import for Objective
                            C source files.
        -v, --verbose         Print actions to STDOUT.
        --no-deserialize      Do not generate deserialization code. Implies --no-
                            dependencies.
        --no-dependencies     Do not include dependencies in output.

Overview
========

Js2model makes it easy to use JSON data as plain old Objective C, C++, or Python objects.

JSON is as a data protocol is simple, convenient, ubiquitous. When working in Javascript, a valid JSON string can be
simply eval'ed to yield a native data instance. When working in other languages, things are not as simple. The usual
approach is to use a general language-specific JSON parser which yields a generalized data structure composed of
dictionaries, arrays, string and numbers. You can use these general structures, at the cost of decreased efficiency,
no type safety, harder code maintainability, etc. You can regain efficiency, type safety, etc by hand rolling some
post-processing logic to load the data into native, custom class instances - a task that is usually tedious,
bug prone, and hard to maintain.

Js2model addresses the aforementioned shortcomings of typical JSON deserialization approaches by automatically
generating model classes and serialization/deserialization code. Js2model uses the
`JSON Schema <http://tools.ietf.org/html/draft-zyp-json-schema-04>`_ definition of your JSON data to generate source
files which you include and build with the rest of your project.

Languages
=========

The script is designed to target multiple output languages. Objective-C and C++ are supported out of the box.
Future versions will add additional languages, as well as support for adding your own language templates.

Documentation
=============

You can review the documentation `here <http://thomsonreuters.github.io/js2model/>`_

JSON Schema
===========

Chances are you do not have existing JSON Schema definitions for your JSON data. Theoretically, creating a schema is
simply a matter of creating JSON file per the `JSON Schema specifications <http://tools.ietf.org/html/draft-zyp-json-schema-04>`_.
Realistically, creating a schema definition manually can be tedious and time intensive, depending on the complexity of your
data. Luckily, there is a better way. `GenSON <http://tools.ietf.org/html/draft-zyp-json-schema-04>`_ is a script that
will automatically generate JSON Schema from one or more JSON files. The resulting schema definitions may need some tweaking,
but GenSON will save you considerable time and effort.

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

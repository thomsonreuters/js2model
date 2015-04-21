#!/usr/bin/env python
__author__ = 'kevin'

import ez_setup
ez_setup.use_setuptools()

from setuptools import setup, find_packages

long_doc = '''
Overview
========

js2model makes it easy to use JSON data as native class models.

JSON is ubiquitous and convenient, but parsing JSON into generic data
structures like dictionaries and arrays precludes the use of many native
language features. Js2model.py generates model classes
and custom deserialization code from JSON schema definitions.

Languages
=========

The script is designed to target multiple output languages. Currently, Objective-C and C++ are supported out of the box.
Future enhancements will add the ability to add your own language templates to support any language.

Documentation
=============

You can review the documentation `here <http://thomsonreuters.github.io/js2model/>`_

'''

setup(
    name='js2model',
    version='0.2.dev7',
    packages=find_packages(),
    package_data={'tr.jsonschema': [
        'templates.objc/*.mako',
        'templates.objc/dependencies/*.h',
        'templates.objc/dependencies/*.c',
        'templates.objc/dependencies/*.m',
        'templates.objc/static/*.*',
        'templates.cpp/*.mako',
        'templates.cpp/dependencies/*.h',
        'templates.cpp/rapidjson/*.h',
        'templates.cpp/rapidjson/error/*.h',
        'templates.cpp/rapidjson/internal/*.h',
        'templates.cpp/rapidjson/msinttypes/*.h',
        'templates.cpp/static/*.*',
    ]},
    include_package_data=True,
    scripts=['js2model.py', 'js2model', 'ez_setup.py'],
    keywords=['json',
              'schema',
              'jsonschema',
              'json-schema',
              'json schema',
              'json object',
              'generate',
              'generator',
              'builder',
              'draft 4',
    ],
    license='BSD',
    author='Kevin Zimmerman',
    author_email="%s.%s@%s.%s"%('kevin', 'zimmerman', 'thomsonreuters', 'com'), # half hearted attempt to avoid spam
    description='A fine attempt to auto-generate source models + deserialization code from JSON schema definitions.',
    long_description=long_doc,
    zip_safe=False,
    platforms='any',
    install_requires=[
        'mako>=1.0.1',
        'jsonpointer>=1.4',
        'jsonref>=0.1',
        'jsonschema>=2.4',
    ],
    dependency_links = [
        'https://pypi.python.org/simple'
    ],
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Natural Language :: English',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.3',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Utilities',
],
)

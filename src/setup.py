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

import ez_setup

__author__ = 'Kevin Zimmerman'

ez_setup.use_setuptools()

from setuptools import setup, find_packages

setup(
    name='js2model',
    version='0.3.dev11',
    packages=find_packages(),
    package_data={'tr.js2model': [
        'templates_py/*.mako',
        'templates_objc/*.mako',
        'templates_objc/dependencies/*.h',
        'templates_objc/dependencies/*.c',
        'templates_objc/dependencies/*.m',
        'templates_objc/static/*.*',
        'templates_cpp/*.mako',
        'templates_cpp/dependencies/*.h',
        'templates_cpp/rapidjson/*.h',
        'templates_cpp/rapidjson/error/*.h',
        'templates_cpp/rapidjson/internal/*.h',
        'templates_cpp/rapidjson/msinttypes/*.h',
        'templates_cpp/static/*.*',
    ]},
    include_package_data=True,
    scripts=['ez_setup.py'],
    keywords=['json',
              'schema',
              'js2model',
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
    author_email="%s.%s@%s.%s" % ('kevin', 'zimmerman', 'thomsonreuters', 'com'),  # half hearted attempt to avoid spam
    description='Auto-generate plain old object models + custom JSON serialization/deserialization code from JSON schema definitions.',
    long_description=open('README.rst').read(),
    url='https://github.com/thomsonreuters/js2model',
    zip_safe=False,
    platforms='any',
    install_requires=[
        'mako>=1.0.1',
        'jsonpointer>=1.4',
        'jsonref>=0.1',
        'jsonschema>=2.5',
        'genson>=0.2.0',
        'click',
        'inflection>=0.3',

    ],
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Natural Language :: English',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Utilities',
    ],
    entry_points='''
        [console_scripts]
        js2model=tr.js2model.cli:main
    ''',

)

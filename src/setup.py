#!/usr/bin/env python
__author__ = 'kevin'

import ez_setup
ez_setup.use_setuptools()

from setuptools import setup

setup(
    name='js2model',
    version='0.1-dev',
    packages=['tr', 'tr.jsonschema'],
    package_data={'tr.jsonschema': [
        'templates.objc/*.jinja',
        'templates.objc/dependencies/*.h',
        'templates.objc/dependencies/*.c',
        'templates.objc/dependencies/*.m',
        'templates.objc/dependencies/api/*.h',
    ]},
    include_package_data=True,
    scripts=['js2model.py'],
    keywords=['Requires: jinja2'],
    license='BSD',
    author='Kevin Zimmerman',
    author_email='kevin.zimmerman@thomsonreuters.com',
    description='A fine attempt to auto-generate source models + deserialization code from JSON schema definitions.',
    long_description=__doc__,
    zip_safe=False,
    platforms='any',
    install_requires=[
        'Mako>=1.0.1',
        'jsonpointer>=1.4',
        'jsonref>=0.1',
        'jsonschema>=2.4',
    ],
    classifiers=[
        'Development Status :: 4 - Beta',
        'Environment :: Web Environment',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Topic :: Software Development :: Libraries ::JSON'
    ],
)

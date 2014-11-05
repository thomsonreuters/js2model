__author__ = 'kevin'

from distutils.core import setup

dependencies = [
          'jsonschema',
          'jinja2',
          'jsonref'
      ]

setup(name='js2model',
      version='0.1',
      packages=['tr', 'tr.jsonschema'],
      package_data={'tr.jsonschema': ['templates.objc/*']},
      scripts=['js2model.py'],
      keywords=['Requires: jinja2']
)

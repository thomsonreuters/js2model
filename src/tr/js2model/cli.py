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

from __future__ import print_function
from tr.js2model.jsonschema2model import JsonSchema2Model
import click

__author__ = 'kevin'


@click.command('js2model')
@click.option('-l', '--lang', default='objc', help='Target language. Supported values: objc, cpp, py (default: objc)')
@click.option('--prefix', default='TR', help='prefix for class names (default: TR)')
@click.option('--namespace', default='tr', help='parent namespace for generated code (default: tr)')
@click.option('--rootname', default=None, help='Class name for root schema object (default: base name of file)')
@click.option('--validate/--no-validate', default=True, help='Run schema validation. Default=True')
@click.option('-o', '--output', type=click.Path(exists=False,file_okay=False, writable=True, resolve_path=True), default='output', help='Target directory of output files')
@click.option('--implements', default=None, help='Comma separated list of interface(s)|protocol(s) supported by the generated classes')
@click.option('--super', 'super_classes', default=None, help='Comma separated list of super classes. Generated classes inherit these')
@click.option('--import', 'import_files', default=None, help='Comma separated list of files to @import for Objective C source files.')
@click.option('-v', '--verbose', is_flag=True, default=False, help='Print actions to STDOUT.')
@click.option('--deserialize/--no-deserialize', default=True, help='Generate deserialization code. Implies --no-dependencies.. Default=True')
@click.option('--dependencies/--no-dependencies', default=True, help='Include dependencies in output. Default=True')
@click.argument('files', nargs=-1, type=click.Path(exists=True, dir_okay=False, resolve_path=True))
def main(lang, prefix, namespace, rootname, validate, output, implements, super_classes, import_files, verbose, deserialize, dependencies, files):

    """
     Generates JSON models for JSON Schema FILES

    :param lang:
    :param prefix:
    :param namespace:
    :param rootname:
    :param validate:
    :param output:
    :param implements:
    :param super_classes:
    :param import_files:
    :param verbose:
    :param deserialize:
    :param dependencies:
    :param files:
    :return:
    """

    #
    # Assert arguments
    #
    # if not len(files):
    #     print("Missing file arguments", file=sys.stderr)
    #     parser.print_help(file=sys.stderr)
    #     return 1

    # files = [f for fileGlob in args.files for f in glob.glob(fileGlob)]
    # for f in files:
    #     if not os.path.exists(f):
    #         print("File cannot be read " + f, file=sys.stderr)
    #         return 1

    generator = JsonSchema2Model(outdir=output,
                                 lang=lang,
                                 prefix=prefix,
                                 namespace=namespace,
                                 root_name=rootname,
                                 import_files=import_files.split(',') if import_files else [],
                                 super_classes=super_classes.split(',') if super_classes else [],
                                 interfaces=implements.split(',') if implements else [],
                                 # include_additional_properties=additional,
                                 validate=validate,
                                 verbose=verbose,
                                 skip_deserialization=not deserialize,
                                 include_dependencies=dependencies)

    generator.generate_models(files)

    return 0


if __name__ == "__main__":
    exit(main())

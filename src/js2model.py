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

__author__ = 'kevin'
from tr.jsonschema.jsonschema2model import *
import sys
import glob
import argparse


def main():
    parser = argparse.ArgumentParser(description='Generate native data models from JSON Schema definitions.')

    parser.add_argument('-l', '--lang', default='objc', help='Target language. Supported values: objc, cpp, py (default: objc)')
    parser.add_argument('--prefix', default='TR', help='prefix for class names (default: TR)')
    parser.add_argument('--namespace', default='tr', help='parent namespace for generated code (default: tr)')
    parser.add_argument('--rootname', default=None,
                        help='Class name for root schema object (default: base name of file)')
    # parser.add_argument('-p', '--primitives', action='store_true', default=False,
    # help='Use primitive types in favor of object wrappers')
    # parser.add_argument('--additional', action='store_true', default=False,
    #                     help='Include additionalProperties in models')
    parser.add_argument('--novalidate', action='store_true', default=False, help='Skip schema validation')
    parser.add_argument('-o', '--output', default='output', help='Target directory of output files')
    parser.add_argument('--implements', default=None,
                        help='Comma separated list of interface(s)|protocol(s) supported by the generated classes')
    parser.add_argument('--super', default=None,
                        help='Comma separated list of super classes. Generated classes inherit these')
    parser.add_argument('--import', dest='import_files', default=None,
                        help='Comma separated list of files to @import for Objective C source files.')
    parser.add_argument('-v', '--verbose', dest='verbose', action='store_true', default=False,
                        help='Print actions to STDOUT.')
    parser.add_argument('--no-deserialize', dest='no_deserialize', action='store_true', default=False,
                        help='Do not generate deserialization code. Implies --no-dependencies.')
    parser.add_argument('--no-dependencies', dest='no_dependencies', action='store_true', default=False,
                        help='Do not include dependencies in output.')

    # LATER: I decided this might be too dangerously destructive if not done right. Needs more thought.
    # parser.add_argument('--purge', action='store_true', default=False,
    # help='Delete existing files from output directory')

    parser.add_argument('files', metavar='FILES', nargs="+", help="JSON Schema files for model generation")

    args = parser.parse_args()

    #
    # Assert arguments
    #
    if not len(args.files):
        print("Missing file arguments", file=sys.stderr)
        parser.print_help(file=sys.stderr)
        return 1

    files = [f for fileGlob in args.files for f in glob.glob(fileGlob)]
    for f in files:
        if not os.path.exists(f):
            print("File cannot be read " + f, file=sys.stderr)
            return 1

    generator = JsonSchema2Model(outdir=os.path.realpath(args.output),
                                 lang=args.lang,
                                 prefix=args.prefix,
                                 namespace=args.namespace,
                                 root_name=args.rootname,
                                 import_files=args.import_files.split(',') if args.import_files else [],
                                 super_classes=args.super.split(',') if args.super else [],
                                 interfaces=args.implements.split(',') if args.implements else [],
                                 # include_additional_properties=args.additional,
                                 validate=args.novalidate,
                                 verbose=args.verbose,
                                 skip_deserialization=args.no_deserialize,
                                 include_dependencies=not args.no_dependencies
    )

    generator.generate_models(files)

    return 0


if __name__ == "__main__":
    exit(main())

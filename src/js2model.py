#!/bin/bash python

from __future__ import print_function
__author__ = 'kevin'
from tr.jsonschema.jsonschema2model import *
import sys
import glob
import argparse

def main():
    parser = argparse.ArgumentParser(description='Generate native data models from JSON Schema definitions.')

    parser.add_argument('-l', '--lang', default='objc', help='language (default: objc)')
    parser.add_argument('--prefix', default='TR', help='prefix for class names (default: TR)')
    parser.add_argument('--rootname', default=None, help='Class name for root schema object (default: fileName)')
    parser.add_argument('-p', '--primitives', action='store_true', default=False,
                        help='Use primitive types in favor of object wrappers')
    parser.add_argument('-x', '--noadditional', action='store_false', default=True,
                        help='Do not include additionalProperties in models')
    parser.add_argument('-o', '--output', default='output', help='Target directory of output files')
    parser.add_argument('--implements', default=None,
                        help='Comma separated list of interface(s)|protocol(s) supported by the generated classes')
    parser.add_argument('--super', default=None, help='Comma separated list of super classes. Generated classes inherit these')
    parser.add_argument('--import', dest='importFiles', default=None, help='Comma separated list of files to @import ')

    # LATER: I decided this might be too dangerously destructive if not done right. Needs more thought.
    #parser.add_argument('--purge', action='store_true', default=False, help='Delete existing files from output directory')

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
                                 root_name=args.rootname,
                                 import_files=args.importFiles.split(',') if args.importFiles else [],
                                 super_classes=args.super.split(',') if args.super else [],
                                 interfaces=args.implements.split(',') if args.implements else [],
                                 include_additional_properties=not args.noadditional
    )

    generator.generateModels(files, include_support_files=True)

    return 0


if __name__ == "__main__":

    exit(main())

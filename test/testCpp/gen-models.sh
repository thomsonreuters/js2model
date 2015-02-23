#!/bin/bash
set -ex

CURDIR=$(pwd)
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
OUTDIR=$SCRIPTDIR/testCpp/models

if [ -e $OUTDIR ]; then
cd $OUTDIR
rm -rf *
fi

cd $CURDIR

${SCRIPTDIR}/../../src/js2model -l cpp --output $OUTDIR ${SCRIPTDIR}/../jsonSchema/test-data-array.schema.json

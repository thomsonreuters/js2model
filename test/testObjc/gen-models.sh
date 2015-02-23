#!/bin/bash
set -ex

CURDIR=$(pwd)
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
OUTDIR=$SCRIPTDIR/testObjc/models

if [ -e $OUTDIR ]; then
cd $OUTDIR
rm -rf *
fi

cd $CURDIR

${SCRIPTDIR}/../../src/js2model --output $OUTDIR ${SCRIPTDIR}/../jsonSchema/test-data-array.schema.json

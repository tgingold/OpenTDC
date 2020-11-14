#!/bin/sh
#
# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set -e

if [ $# -eq 0 ]; then
    files=*.def
else
    files=$*
fi

for f in $files; do
    export DESIGN_NAME=$(basename $f .def)
    echo $DESIGN_NAME
    mkdir $DESIGN_NAME
    cp config.tcl $DESIGN_NAME/
    /openLANE_flow/openlane/flow.tcl -it -file build.tcl
    cp $DESIGN_NAME/runs/user/results/magic/${DESIGN_NAME}.gds results/
    cp $DESIGN_NAME/runs/user/results/magic/${DESIGN_NAME}.lef results/
    rm -rf $DESIGN_NAME/
done

exit 0


cp runs/user/results/routing/$DESIGN_NAME.def .
cp runs/user/results/magic/$DESIGN_NAME.mag .
cp runs/user/results/magic/$DESIGN_NAME.drc.mag .
cp runs/user/logs/magic/magic.drc* .
cp runs/user/results/magic/$DESIGN_NAME.gds .
cp runs/user/results/magic/$DESIGN_NAME.lef .

if ! grep "COUNT: 0" runs/user/logs/magic/magic.drc.log; then
    echo "DRC failures"
    exit 1
fi

echo "Done"

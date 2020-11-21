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

unset TERM

for f in $files; do
    export DESIGN_NAME=$(basename $f .def)
    echo $DESIGN_NAME
    mkdir -p $DESIGN_NAME
    cp config.tcl $DESIGN_NAME/
    /openLANE_flow/openlane/flow.tcl -it -file build.tcl
    if ! grep "COUNT: 0" $DESIGN_NAME/runs/user/logs/magic/magic.drc.log; then
        echo "DRC failures"
        # exit 1
    fi
    if ! grep "Number of pins violated: 0" $DESIGN_NAME/runs/user/logs/routing/or_antenna.log; then
        echo "Antenna violations (pins)"
        exit 1
    fi
    if ! grep "Number of nets violated: 0" $DESIGN_NAME/runs/user/logs/routing/or_antenna.log; then
        echo "Antenna violations (nets)"
        exit 1
    fi

    cp $DESIGN_NAME/runs/user/results/magic/${DESIGN_NAME}.gds ../../gds
    cp $DESIGN_NAME/runs/user/results/magic/${DESIGN_NAME}.lef ../../lef
    cp $DESIGN_NAME/runs/user/results/magic/${DESIGN_NAME}.mag ../../mag
    cp $DESIGN_NAME/runs/user/results/routing/${DESIGN_NAME}.def ../../def
#    rm -rf $DESIGN_NAME/
done

exit 0



echo "Done"

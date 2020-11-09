#!/bin/sh
# To be executed in the openlane/ directory

length=""
for arg; do
    case $arg in
        --length=*)
            length=`echo $arg | sed -e s/--length=//`
            ;;
        --help)
            echo "usage: $0 --length=LEN"
            exit 0
            ;;
        *)
            echo "Unknown parameter.  Try $0 --help"
            exit 2
            ;;
    esac
done

if [ "$length" == "" ]; then
    echo "$0: missing --length parameter"
    exit 2
fi

set -e

export DESIGN_NAME=tapline_$length
python3 ../../tools/gen_tapline.py --length=$length --name=$DESIGN_NAME
mv $DESIGN_NAME.def tapline.placed.def

cd ..
/openLANE_flow/openlane/flow.tcl -it -file gentapline/build.tcl
cd gentapline

cp runs/user/results/magic/$DESIGN_NAME.gds .
cp runs/user/results/magic/$DESIGN_NAME.lef .

echo "Done"

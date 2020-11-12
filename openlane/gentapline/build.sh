#!/bin/sh
# To be executed in the openlane/ directory

length=""
geo="x1"

for opt; do
    arg=`echo $opt | sed -e 's/.*=//'`
    case $opt in
        --length=*)
            length=$arg
            ;;
        --geo=*)
            geo=$arg
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

export DESIGN_NAME=tapline_${geo}_${length}
python3 ../../tools/gen_tapline.py --length=$length --geo=$geo --name=$DESIGN_NAME
mv $DESIGN_NAME.def design.placed.def

rm -rf runs/user

cd ..
/openLANE_flow/openlane/flow.tcl -it -file gentapline/build.tcl
cd gentapline

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

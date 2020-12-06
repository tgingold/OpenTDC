#!/bin/sh
# Script to add power stripes to pin
#
# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

for f in $*; do
    b=`basename $f .lef`;
    echo "Copying $f as $f.orig"
    mv $f $f.orig
    echo "Fixing $f"
    PYTHONPATH=../../openlane/scripts/spef_extractor/ python3 ../tools/fix_power_pin.py --def_file=../def/$b.def --lef_file=$b.lef.orig --layer=met4 --pin VPWR VGND -o $f;
    echo "Diffs:"
    diff -w $f.orig $f || true
done

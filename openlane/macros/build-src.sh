#!/bin/sh
#
# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

# This script creates the initial .def (placed netlist) for all the taplines
# and delay lines of the design.

set -e

GEN_TAPLINE=../../tools/gen_tapline.py
L=200

GEN_DELAYLN=../../tools/gen_delayline.py

#POW="--power=VPWR --ground=VGND"

# Tech: fd_sc_hd
#$GEN_TAPLINE -n tapline_200_x1_hd              -l $L -g 1 -f 1
#$GEN_TAPLINE -n tapline_200_x1_hd_ref          -l $L -g 1 -r
#$GEN_TAPLINE -n tapline_200_x2_hd \
#             -l $L $POW -g 2
#$GEN_TAPLINE -n tapline_200_x2_hd_ref \
#             -l $L $POW -g 2 -r -f 8
#$GEN_TAPLINE -n tapline_200_x2_s1_cbuf1_hd_ref \
#             -l $L $POW -g 2 -r -c s1 -d cbuf_1

if false; then
$GEN_TAPLINE -n tapline_200_x2_s1_cbuf2_hd_ref -l $L -g 2 -r -c s1 -d cbuf_2
$GEN_TAPLINE -n tapline_200_x2_s1_cbuf4_hd_ref -l $L -g 2 -r -c s1 -d cbuf_4
$GEN_TAPLINE -n tapline_200_x2_s1_cdly18_hd_ref -l $L -g 2 -r -c s1 -d cdly18_1
$GEN_TAPLINE -n tapline_200_x2_s1_cdly25_hd_ref -l $L -g 2 -r -c s1 -d cdly25_1
$GEN_TAPLINE -n tapline_200_x2_s1_cdly50_hd_ref -l $L -g 2 -r -c s1 -d cdly50_1
$GEN_TAPLINE -n tapline_200_x4_s1_hd_ref       -l $L -g 4 -r -c s1
$GEN_TAPLINE -n tapline_200_x8_s1_hd_ref       -l $L -g 8 -r -c s1
$GEN_TAPLINE -n tapline_200_x8_s1_hd_ref       -l $L -g 8 -r -c s1
$GEN_TAPLINE -n tapline_200_x8_s1_hd_ref       -l $L -g 8 -r -c s1
fi

#$GEN_TAPLINE -n tapline_200_x2_s1_hd_ref \
#             -t fd_hd -l $L $POW -g 2 -r -c s1

if false; then
$GEN_TAPLINE -n tapline_200_x2_s1_dly4_hs_ref -t fd_hs -l $L -g 2 -r -c s1 -d dly4_1
$GEN_TAPLINE -n tapline_200_x2_s1_dly4_ms_ref -t fd_ms -l $L -g 2 -r -c s1 -d dly4_1
$GEN_TAPLINE -n tapline_200_x2_s1_dly4_ls_ref -t fd_ls -l $L -g 2 -r -c s1 -d dly4_1
fi

$GEN_DELAYLN -n delayline_9_hs -l 9 -t fd_hs -d dly4_1
$GEN_DELAYLN -n delayline_9_ms -l 9 -t fd_ms -d dly4_1
$GEN_DELAYLN -n delayline_9_hd -l 9

{
    sed -e '/^end/,$d' < opentdc_comps-tpl.vhdl
    for f in *_comp.vhdl; do
	cat $f
	echo
    done
    sed -n -e '/^end/,$p' < opentdc_comps-tpl.vhdl
} > opentdc_comps.vhdl

echo "Done."

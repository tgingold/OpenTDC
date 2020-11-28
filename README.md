<!--
< SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
< SPDX-License-Identifier: Apache-2.0
-->
# OpenTDC

## Intro

OpenTDC is a Time to Digital Converter (TDC) and a Fine Delay (FD) design.

The TDC can timestamp a pulse with a precision below 1 ns, while the
FD can generate a pulse with the same precision.

TDC could be used to measure distances using time-of-flight of laser
pulses.  It is also used to measure the time-of-flight of particules
in High Energy Physic experiments.  A TDC could also be used in LIDAR.

The first implementation aims at providing a very simple TDC+FD
implementation (based only on standard cells) and to test different
cell libraries, different delay elements and different layouts.
We will evaluate stability over time, power consumption and accuracy
(all of them are difficult to estimate using analog simulators).  This
first implementation could also be used by other people to (partially)
characterize the standard libraries.

It is forseen in a next implementation to add a FIFOs to handle pulse
bursts, add a logic to convert row results (number of taps) to a time
value and to be able to mesure pulse width.  It is also forseen to
improve handling to clock lines, and maybe to design a delay element.

You can also read the blog in the repository that tells about the
progress of this project.

Particularities of the design:
* Mixes different cell libraries (hd, hs)
* Tool generated macros
* Macros within macros
* mixed languages (VHDL and verilog)

## License

Apache 2.0

## Building

As most of the sources are in VHDL, you need to first synthesis them and generate very
simple verilog.  This verilog will be the source for OpenLANE.  This is done with
the [ghdl-yosys-plugin](https://github.com/ghdl/ghdl-yosys-plugin).

```bash
  make verilog
```

Start an OpenLANE docker shell and harden the design:

```bash
  make gds/user_project_wrapper.gds
```


## Testing

There are functional unit tests in `tb/`.

And a simple integration test with caraval in `tests/`.


## Global Architecture

Each TDC or FD is within a macro, which is connected to the wishbone bus either through
the main block [wb_interface](rtl/wb_interface.vhdl) or through an extender
[wb_extender](rtl/wb_extender.vhdl) (which is connected to the main block).

In addition, there is one TDC and one FD in the main block.

And finally, there is an independant [rescue block](rtl/rescue_top.vhdl) which contains one
TDC and one FD and connected to the logical analyzer interface.

## Register map

Not documented outside the source files!
But each device uses 8 words.  A device is either a TDC or a FD, except device 0 which is
a control device.  You can identify a device by reading at offset 0x1c.
See [tdc core](rtl/opentdc_core2.vhdl) and [fd core](rtl/openfd_core2.vhdl) source files
for the registers, and [wb_interface](rtl/wb_interface.vhdl) for the main controller.

## Contributing

Please use issues and pull-requests from github



# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-FileCopyrightText: (Based on caravel file by efabless)
# SPDX-License-Identifier: Apache-2.0

CARAVEL=../../caravel
CROSS=riscv32-elf-

FIRMWARE_PATH=$(CARAVEL)/verilog/dv/caravel

CC=$(CROSS)gcc

all: main.hex

RTL_PATH = ../../../../rtl
IP_PATH = ../../../../ip
BEHAVIOURAL_MODELS = ../../ 

.SUFFIXES:

functional/blackbox.v: ../src/user_project_wrapper_bb.v
#  Just keep the minimum (to speed up simulation)
	sed -e '/blackbox/d' -e '/module wb_interface/,/endmodule/d' \
	  -e '/module zero/,/endmodule/d' < $< > $@

functional.vvp: main_tb.v main.hex functional/blackbox.v
	iverilog -DSIM -DFUNCTIONAL -DSPOOF_FAST_FLASH=\"main.hex\" \
	-Ifunctional/ \
        -I $(CARAVEL)/verilog/rtl \
        -I $(CARAVEL)/verilog/dv/caravel \
	-I $(PDK_ROOT)/sky130A \
	$< -o $@

functional.out: functional.vvp
	vvp $< | tee $@

gl.vvp: main_tb.v main.hex gl/wb_interface.simple.v
	iverilog -DSIM -DFUNCTIONAL -DSPOOF_FAST_FLASH=\"main.hex\" \
	-DWRAPPER_USE_POWER_PINS \
	-Igl/ \
        -I $(CARAVEL)/verilog/rtl \
        -I $(CARAVEL)/verilog/dv/caravel \
	-I $(PDK_ROOT)/sky130A \
	$< -o $@

gl.i: main_tb.v main.hex gl/wb_interface.simple.v
	iverilog -E -DSIM -DFUNCTIONAL -DSPOOF_FAST_FLASH=\"main.hex\" \
	-Igl/ \
        -I $(CARAVEL)/verilog/rtl \
        -I $(CARAVEL)/verilog/dv/caravel \
	-I $(PDK_ROOT)/sky130A \
	$< -o $@

gl.out: gl.vvp
	vvp $< | tee $@

gl/wb_interface.simple.v: ../verilog/gl/wb_interface.lvs.powered.v
	yosys -p "read_verilog $<; \
	 delete t:sky130_fd_sc_hd__diode_2; \
	 delete t:sky130_fd_sc_hd__decap*; \
	 delete t:sky130_fd_sc_hd__fill*; \
	 delete t:sky130_fd_sc_hd__tapvpwrvgnd_1; \
	 write_verilog -noattr $@"

%.elf: %.c $(FIRMWARE_PATH)/sections.lds $(FIRMWARE_PATH)/start.s
	$(CC) -mabi=ilp32 -march=rv32imc -I$(FIRMWARE_PATH) -Wl,-Bstatic,-T,$(FIRMWARE_PATH)/sections.lds,--strip-debug -ffreestanding -nostdlib -o $@ $(FIRMWARE_PATH)/start.s $<

%.hex: %.elf
	$(CROSS)objcopy -O verilog $< $@ 
	# to fix flash base address
	sed -i 's/@10000000/@00000000/g' $@

# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd *.log

.PHONY: clean hex all

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

%.vvp: %_tb.v %.hex
	iverilog -DFUNCTIONAL -I $(CARAVEL)/verilog/rtl \
        -I $(CARAVEL)/verilog/dv/caravel \
	-I $(PDK_ROOT)/sky130A \
	$< -o $@

# 	-I $(PDK_PATH) -I $(IP_PATH) -I $(RTL_PATH) \

%.vcd: %.vvp
	vvp $<

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

/*
/ SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
/ SPDX-FileCopyrightText: (Based on caravel file by efabless)
/ SPDX-License-Identifier: Apache-2.0
*/

#include "defs.h"

#define USE_UART 0

#define PRJ_BASE ((volatile uint32_t*)0x30000000)
#define PRJ_BASE_8 ((volatile uint8_t*)0x30000000)

// --------------------------------------------------------

#if USE_UART
#define PUTC(c) reg_uart_data = c
#else
#define PUTC(c) reg_mprj_datal = (0xa1000000 | (c & 0xff))
#endif

static void putchar(int c)
{
	if (c == '\n')
		PUTC('\r');
        PUTC(c);
}

static void print(const char *p)
{
	while (*p)
		putchar(*(p++));
}
static void
configure_io(void)
{
  //  Configure I/O: bit 0-7 are used for character output
  //  bit 8 as status

    reg_mprj_io_0 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_1 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_2 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_3 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_4 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_5 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_6 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_7 = GPIO_MODE_MGMT_STD_OUTPUT;

    reg_mprj_io_8 = GPIO_MODE_MGMT_STD_OUTPUT;

    // Now, apply the configuration
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);
}

static void
puthex_nibble(unsigned v)
{
  putchar("0123456789abcdef"[v & 0x0f]);
}

static void
puthex4(unsigned v)
{
  int i;
  for (i = 0; i < 8; i++) {
    puthex_nibble(v >> 28);
    v <<= 4;
  }
}

void main()
{
    int j;

    configure_io();

    // Start test
    reg_mprj_datal = 0x101;

    PUTC('S');
    if (PRJ_BASE[0] != 0x54646301)
      goto error;
    PUTC('1');

    if (PRJ_BASE[6] != 0x10203040)
      goto error;
    PUTC('2');

    PRJ_BASE_8[6*4 + 1] = 0xd3;
    if (PRJ_BASE[6] != 0x1020d340)
      goto error;
    PUTC('3');

#if 0
    print("Id: ");
    puthex4(PRJ_BASE[0]);
    putchar('\n');
#endif

    PUTC('o');
    PUTC('k');
    reg_mprj_datal = 0x102;
    return;

 error:
    PUTC('X');
    reg_mprj_datal = 0x1ff;
}

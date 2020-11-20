#include "defs.h"

#define USE_UART 0

#define PRJ_BASE ((volatile uint32_t*)0x30000000)
#define PRJ_BASE_8 ((volatile uint8_t*)0x30000000)

// --------------------------------------------------------

#if USE_UART
#define PUTC(c) reg_uart_data = c
#else
#define PUTC(c) reg_mprj_datal = (0xa1000000 | ((c & 0xff) << 16))
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
    // Configure I/O:  High 16 bits of user area used for a 16-bit
    // word to write and be detected by the testbench verilog.
    // Only serial Tx line is used in this testbench.  It connects
    // to mprj_io[6].  Since all lines of the chip are input or
    // high impedence on startup, the I/O has to be configured
    // for output

    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;

    reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;

    reg_mprj_io_6 = GPIO_MODE_MGMT_STD_OUTPUT;

    // Set clock to 64 kbaud and enable the UART.  It is important to do this
    // before applying the configuration, or else the Tx line initializes as
    // zero, which indicates the start of a byte to the receiver.

    reg_uart_clkdiv = 625;
    reg_uart_enable = 1;

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
    reg_mprj_datal = 0xa0000000;

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
    reg_mprj_datal = 0xab000000;
    return;

 error:
    PUTC('X');
    reg_mprj_datal = 0xac000000;
}

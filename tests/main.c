/*
/ SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
/ SPDX-FileCopyrightText: (Based on caravel file by efabless)
/ SPDX-License-Identifier: Apache-2.0
*/

#include "defs.h"

#define RESCUE 1

struct dev0 {
  uint32_t id;
  uint32_t cur_cycles;
  uint32_t tdc_trig;
  uint32_t oen;
  
  uint32_t rst_time;
  uint32_t unused;
  uint32_t areg;
  uint32_t nfd_ntdc;
};

struct tdc_core {
  uint32_t status;
  uint32_t ref_time;
  uint32_t coarse;
  uint32_t fine;

  uint32_t scan_cnt;
  uint32_t scan_reg;
  uint32_t unused;
  uint32_t config;
};

struct fd_core {
  uint32_t status;
  uint32_t minitaps;
  uint32_t coarse;
  uint32_t fine;

  uint32_t rcoarse;
  uint32_t rfine;
  uint32_t tfine; // + tpulse - Read broken
  uint32_t config;
};

struct dev {
  /* wb_interface 0 & 1*/
  struct dev0 dev0;
  struct tdc_core tdc1; /* In:  31 (wb_interface) */
  struct tdc_core tdc2; /* In:  30 tdc_inline_1 */
  struct tdc_core tdc3; /* In:  29 tdc_inline_2 */
  struct fd_core fd4;   /* Out: 12 (wb_interface) */
  struct fd_core fd5;   /* Out: 13,14 fd_hd */
  struct fd_core fd6;   /* Out: 15,16 fd_hs */
  struct fd_core fd7;   /* Out: 17,18 fd_ms */

  /* wb_extender 2 */
  struct tdc_core tdc8; /* In:  28 tdc_inline_3 */
  struct tdc_core tdc9; /* In:  27 tdc_inline_3 */
  struct fd_core fd10;  /* Out: 19 fd_inline_1 */
  struct fd_core fd11;  /* Out: 20 fd_hd_25_1 */

  /* wb_extender 3 */
  struct tdc_core tdc12; /* In: 26 tdc_hd_cbuf2_x4 */
  struct tdc_core tdc13; /* In: 25 tdc_inline3 */
  struct fd_core  fd14;  /* Out: 21,22 fd_hs */
  struct fd_core  fd15;  /* Out: 23 fd_hd_25_1 */

  /* wb_extender 4 */
  struct tdc_core tdc16; /* In: 24, tdc_inline_2 */
  struct tdc_core tdc17; /* In: 23, tdc_hd_cbuf2_x4 */
  struct fd_core  fd18;  /* Out: 24, 25 fd_ms */
  struct fd_core  fd19;  /* Out: 26 fd_hd_25_1 */
};

#define USE_UART 0

#define PRJ_ADDR 0x30000000
#define PRJ_BASE ((volatile uint32_t*)PRJ_ADDR)
#define PRJ_BASE_8 ((volatile uint8_t*)PRJ_ADDR)

#define DEV ((volatile struct dev*)PRJ_ADDR)

// --------------------------------------------------------

#if USE_UART
#define PUTC(c) reg_uart_data = c
#else
#define PUTC(c) reg_mprj_datal = ((c & 0x7f) << 5)
#endif

static void print(const char *p)
{
  while (*p) {
    PUTC(0);
    PUTC(*(p++));
  }
}

static void
configure_io(void)
{
  //  Configure I/O: bit 5-11 are used for character output

    reg_mprj_io_5 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_6 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_7 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_8 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_9 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_10 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_11 = GPIO_MODE_MGMT_STD_OUTPUT;

    // FD 4
    reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;

    // TDC 1
    reg_mprj_io_31 = GPIO_MODE_USER_STD_INPUT_NOPULL;
        
    // FD 5
    reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;

    // TDC 2
    reg_mprj_io_30 = GPIO_MODE_USER_STD_INPUT_NOPULL;

    // TDC 3
    reg_mprj_io_29 = GPIO_MODE_USER_STD_INPUT_NOPULL;

    // FD 7
    reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT;
    
    // FD 10
    reg_mprj_io_19 = GPIO_MODE_USER_STD_OUTPUT;

    // TDC 8
    reg_mprj_io_28 = GPIO_MODE_USER_STD_INPUT_NOPULL;

    // FD 11
    reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT;

    // TDC 9
    reg_mprj_io_27 = GPIO_MODE_USER_STD_INPUT_NOPULL;

    // TDC 12
    reg_mprj_io_26 = GPIO_MODE_USER_STD_INPUT_NOPULL;

    // FD 15
    reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;

    // rst_time_n
    reg_mprj_io_37 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;

    if (RESCUE) {
      // Rescue: output 28 (like tdc8), input 12 (like fd4)
      reg_mprj_io_28 = GPIO_MODE_USER_STD_OUTPUT;
      reg_mprj_io_12 = GPIO_MODE_USER_STD_INPUT_NOPULL;
    }
    
    // Now, apply the configuration
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);
}

static const char hex[] = "0123456789abcdef";

static void
puthex4(unsigned v)
{
  int i;
  for (i = 0; i < 8; i++) {
    PUTC(0x00);
    PUTC(hex[v >> 28]);
    v <<= 4;
  }
}

static void
run_fd (const char *name, volatile struct fd_core *fd)
{
  unsigned cyc;
  unsigned config;
  
  print(name);
  print(": ");
  config = fd->config;
  puthex4(config);
  PUTC('\n');
  if (0) {
    print("st: ");
    puthex4(fd->status);
    PUTC('\n');
  }

  cyc = DEV->dev0.cur_cycles;
  fd->fine = 25;
  fd->coarse = cyc + 300;
  if (config & 4) {
    fd->rfine = 125;
    fd->rcoarse = cyc + 400;
  }
  print("st: ");
  puthex4(fd->status);
  PUTC('\n');
  print("co: ");
  puthex4(fd->coarse);
  PUTC('\n');
#if 0
  // Need timed simulation
  fd->tfine = 0x800000c4;
  print("ta: ");
  puthex4(fd->minitaps);
  PUTC('\n');
#endif
}

static void
disp_tdc (const char *name, volatile struct tdc_core *tdc)
{
  print(name);
  print(": ");
  puthex4(tdc->config);
  PUTC('\n');
  print("st: ");
  puthex4(tdc->status);
  PUTC('\n');
  print("co: ");
  puthex4(tdc->coarse);
  PUTC('\n');
  print("fi: ");
  puthex4(tdc->fine);
  PUTC('\n');
}

void main()
{
  unsigned cyc;

    int j;

    configure_io();

    // Start test
    reg_mprj_datal = 0x01 << 5;

    // Check wb_interface ID register
    PUTC('S');
    if (PRJ_BASE[0] != 0x54646301)
      goto error;
    PUTC('1');

    // Check areg
    if (PRJ_BASE[6] != 0x10203040)
      goto error;
    PUTC('2');

    PRJ_BASE_8[6*4 + 1] = 0xd3;
    if (PRJ_BASE[6] != 0x1020d340)
      goto error;
    PUTC('3');
    PUTC('\n');

    if (0) {
      register unsigned sp asm("sp");
      print("sp: ");
      puthex4(sp);
      PUTC('\n');
    }

    if (RESCUE) {
      /* rescue - need a special harness */
      reg_la3_ena = 0x00000200; /* 96-127 -> to rescue, 105 <- from rescue */
      reg_la2_ena = 0x00000000; /* 64-95  -> to rescue */
      reg_la1_ena = 0xffffffbf; /* 42: to rescue */
      reg_la0_ena = 0xffffffff; /* from rescue */
      reg_la0_data = 0x0;
      reg_la2_data = 0x0000034; /* fd: coarse */
      reg_la1_data = 0x40; /* Enable tdc */
      reg_la3_data = 0x80000412; /* fd: out of reset, start, out en. */
      print("rsc: ");
      puthex4(reg_la1_data);
      PUTC(',');
      puthex4(reg_la0_data);
      PUTC('\n');
    }
    
    if (0) {
      /* Disp dev0.  */
      print("Id: ");
      puthex4(DEV->dev0.id);
      PUTC('\n');
      print("tm: ");
      puthex4(DEV->dev0.cur_cycles);
      PUTC('\n');
      print("rg: ");
      puthex4(DEV->dev0.areg);
      PUTC('\n');
      print("cf: ");
      puthex4(DEV->dev0.nfd_ntdc);
      PUTC('\n');
    }

    if (0) {
      // Test TDC1 & FD4
      
      //  Enable TDC1 (detect on rising edge)
      DEV->tdc1.status = 0x10100;

      print("FD4: ");
      puthex4(DEV->fd4.config);
      PUTC('\n');
      print("st: ");
      puthex4(DEV->fd4.status);
      PUTC('\n');

      print("tm: ");
      puthex4(DEV->dev0.cur_cycles);
      PUTC('\n');

      // Setup FD4
      DEV->fd4.fine = 21;
      DEV->fd4.coarse = DEV->dev0.cur_cycles + 100;
      print("co: ");
      puthex4(DEV->fd4.coarse);
      PUTC('\n');
      print("st: ");
      puthex4(DEV->fd4.status);
      PUTC('\n');

      disp_tdc("TDC1", &DEV->tdc1);
    }

    if (0) {
      //  Test FD5, TDC2, TDC3

      //  Enable TDC2 & 4 (detect on rising edge)
      DEV->tdc2.status = 0x10000;
      DEV->tdc3.status = 0x10000;

      print("FD5: ");
      puthex4(DEV->fd5.config);
      PUTC('\n');
      print("st: ");
      puthex4(DEV->fd5.status);
      PUTC('\n');

      cyc = DEV->dev0.cur_cycles;
      DEV->fd5.fine = 25;
      DEV->fd5.coarse = cyc + 300;
      DEV->fd5.rfine = 125;
      DEV->fd5.rcoarse = cyc + 400;
      print("st: ");
      puthex4(DEV->fd5.status);
      PUTC('\n');
      print("co: ");
      puthex4(DEV->fd5.coarse);
      PUTC('\n');
      DEV->fd5.tfine = 0x800000c4;
      print("ta: ");
      puthex4(DEV->fd5.minitaps);
      PUTC('\n');

      disp_tdc("TDC2", &DEV->tdc2);
      disp_tdc("TDC3", &DEV->tdc3);
    }

    if (0) {
      //  Test FD7

      print("FD7: ");
      puthex4(DEV->fd7.config);
      PUTC('\n');
      print("st: ");
      puthex4(DEV->fd7.status);
      PUTC('\n');
      
      cyc = DEV->dev0.cur_cycles;
      DEV->fd7.fine = 25;
      DEV->fd7.coarse = cyc + 320;
      DEV->fd7.rfine = 125;
      DEV->fd7.rcoarse = cyc + 420;
      print("st: ");
      puthex4(DEV->fd7.status);
      PUTC('\n');
      print("co: ");
      puthex4(DEV->fd7.coarse);
      PUTC('\n');
    }

    if (0) {
      //  FD10 + TDC8

      // Trick to reset cycle counter
      DEV->dev0.rst_time = 1;
      (void)DEV->fd10.config;
      (void)DEV->tdc8.config;
      DEV->dev0.rst_time = 0;
      (void)DEV->tdc8.config;

      //  Enable TDC1 (detect on rising edge)
      DEV->tdc8.status = 0x10100;

      run_fd("FD10", &DEV->fd10);
      disp_tdc("TDC8", &DEV->tdc8);
    }
    
    if (0) {
      //  FD11 + TDC9

      // Trick to reset cycle counter
      DEV->dev0.rst_time = 1;
      (void)DEV->fd11.config;
      (void)DEV->tdc9.config;
      DEV->dev0.rst_time = 0;
      (void)DEV->tdc9.config;

      //  Enable TDC1 (detect on rising edge)
      DEV->tdc9.status = 0x10100;

      run_fd("FD11", &DEV->fd11);
      disp_tdc("TDC9", &DEV->tdc9);
    }
    
    if (0) {
      //  FD15 + TDC12

      // Trick to reset cycle counter
      DEV->dev0.rst_time = 1;
      (void)DEV->fd15.config;
      (void)DEV->tdc12.config;
      DEV->dev0.rst_time = 0;
      (void)DEV->tdc12.config;

      //  Enable TDC1 (detect on rising edge)
      DEV->tdc12.status = 0x10100;

      run_fd("FD15", &DEV->fd15);
      disp_tdc("TDC12", &DEV->tdc12);
    }
    
    PUTC('o');
    PUTC('k');
    reg_mprj_datal = 0x02 << 5;
    return;

 error:
    PUTC('X');
    reg_mprj_datal = 0x7f << 5;
}

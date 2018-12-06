//
//
//  HEX:  To turn off, write "1"
//        To turn on, write "0" 
//
//  LEDR, LEDG : To turn off, write "0"
//				 To turn on,  write "1"
//
//         _0_
//       5|_6_|1
//       4|___|2
//          3
//
//  KEY:  Push --> "0" 
//        Release --> "1"
//
//  SW:   Down (towards the edge of the board)  --> "0"
//        Up --> "1"
//
`timescale 1ns/1ps

module ARM_System(
  input CLOCK_27,
  input [3:0] KEY,
  input [17:0] SW,

  input         UART_RXD,
  output        UART_TXD,
  output [6:0]  HEX7,
  output [6:0]  HEX6,
  output [6:0]  HEX5,
  output [6:0]  HEX4,
  output [6:0]  HEX3,
  output [6:0]  HEX2,
  output [6:0]  HEX1,
  output [6:0]  HEX0,
  output [17:0] LEDR,
  output [8:0]  LEDG);
  //input         nIRQ); //100728

  wire reset;
  wire reset_poweron;
  reg  reset_ff;
  wire clk0;
  wire locked;
  wire [31:0] inst_addr;
  wire [31:0] inst;
  wire [31:0] data_addr;
  wire [31:0] write_data;
  wire [31:0] read_data_timer;
  wire [31:0] read_data_uart;
  wire [31:0] read_data_gpio;
  wire [31:0] read_data_mem;
  reg  [31:0] read_data;
  wire        cs_mem_n;
  wire        cs_timer_n;
  wire        cs_uart_n;
  wire        cs_gpio_n;
  wire        data_we;
  wire [3:0]  ben;

  wire clk90;
  wire data_re;
  //100728
  wire nIRQ;
  
  // reset =  KEY[0]
  // if KEY[0] is pressed, the reset goes down to "0"
  // reset is a low-active signal
  assign  reset_poweron = KEY[0];
  assign  reset = reset_poweron;

  always @(posedge clk0)  reset_ff <= reset;

  ALTPLL_clkgen pll0(
			 .inclk0   (CLOCK_27), 
			 .c0       (clk0), 
			 .c1       (clk90), 
			 .locked   (locked)); 


  always @(*)
  begin
	  if      (~cs_timer_n) read_data <= read_data_timer;
	  else if (~cs_uart_n)  read_data <= {24'b0,read_data_uart[7:0]};
	  else if (~cs_gpio_n)  read_data <= read_data_gpio;
	  else                  read_data <= read_data_mem;
  end


  armreduced arm_cpu (
		 .clk        (clk90), 
		 .reset      (~reset_ff),
       .pc         (inst_addr),
       .inst      (inst),
       .nIRQ       (), //100728
       .be         (ben), 
       .memaddr   (data_addr), 
       .memwrite  (data_we),  // data_we: active high
		 .memread   (data_re),  // data_re: active high
		 .writedata (write_data),
       .readdata   (read_data));


	// Port A: Instruction
	// Port B: Data
   ram2port_inst_data Inst_Data_Mem (
		.address_a   (inst_addr[12:2]),
		.address_b   (data_addr[12:2]),
		.byteena_b   (ben),
		.clock_a     (clk0),
		.clock_b     (~clk0),
		.data_a      (),
		.data_b      (write_data),
		.enable_a    (1'b1),
		.enable_b    (~cs_mem_n),
		.wren_a      (1'b0),
		.wren_b      (data_we),
		.q_a         (inst),
		.q_b         (read_data_mem));


  Addr_Decoder Decoder ( 
		 .Addr        (data_addr),
       .CS_MEM_N    (cs_mem_n) ,
       .CS_TC_N     (cs_timer_n),
       .CS_UART_N   (cs_uart_n),
       .CS_GPIO_N   (cs_gpio_n));

  TimerCounter Timer (
       .clk     (~clk0),
       .reset   (reset_ff),
       .CS_N    (cs_timer_n),
       .RD_N    (~data_re),
       .WR_N    (~data_we),
       .Addr    (data_addr[11:0]),
       .DataIn  (write_data),
       .DataOut (read_data_timer),
       .Intr    (nIRQ) );

   miniUART UART ( 
		 .SysClk  (~clk0),
       .Reset   (reset_ff),
       .CS_N    (cs_uart_n),
       .RD_N    (~data_re),
       .WR_N    (~data_we),
       .RxD     (UART_RXD),
       .TxD     (UART_TXD),
       .IntRx_N (),
       .IntTx_N (),
       .Addr    (data_addr[3:2]),
       .DataIn  (write_data[7:0]),
       .DataOut (read_data_uart[7:0]));

   
   GPIO uGPIO ( 
	    .CLOCK_50 (~clk0),
       .reset    (reset_ff),
       .CS_N     (cs_gpio_n),
       .RD_N     (~data_re),
       .WR_N     (~data_we),
       .Addr     (data_addr[11:0]),
       .DataIn   (write_data),
       .DataOut  (read_data_gpio),
       .Intr     (),

       .KEY     (KEY[3:1]),
       .SW      (SW),
       .HEX7    (HEX7),
       .HEX6    (HEX6),
       .HEX5    (HEX5),
       .HEX4    (HEX4),
       .HEX3    (HEX3),
       .HEX2    (HEX2),
       .HEX1    (HEX1),
       .HEX0    (HEX0),
       .LEDR    (LEDR),
       .LEDG    (LEDG));
 
endmodule

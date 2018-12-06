// File miniUART.vhd translated with vhd2vl v2.0 VHDL to Verilog RTL translator
// Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd - http://www.ocean-logic.com
// Modifications (C) 2006 Mark Gonzales - PMC Sierra Inc
// 
// vhd2vl comes with ABSOLUTELY NO WARRANTY
// ALWAYS RUN A FORMAL VERIFICATION TOOL TO COMPARE VHDL INPUT TO VERILOG OUTPUT 
// 
// This is free software, and you are welcome to redistribute it under certain conditions.
// See the license file license.txt included with the source for details.

//===========================================================================--
//
//  S Y N T H E Z I A B L E    miniUART   C O R E
//
//  www.OpenCores.Org - January 2000
//  This core adheres to the GNU public license  
//
// Design units   : miniUART core for the OCRP-1
//
// File name      : miniuart.vhd
//
// Purpose        : Implements an miniUART device for communication purposes 
//                  between the OR1K processor and the Host computer through
//                  an RS-232 communication protocol.
//                  
// Library        : uart_lib.vhd
//
// Dependencies   : IEEE.Std_Logic_1164
//
// Simulator      : ModelSim PE/PLUS version 4.7b on a Windows95 PC
//===========================================================================--
//-----------------------------------------------------------------------------
// Revision list
// Version   Author                 Date           Changes
//
// 0.1      Ovidiu Lupas     15 January 2000       New model
// 1.0      Ovidiu Lupas     January  2000         Synthesis optimizations
// 2.0      Ovidiu Lupas     April    2000         Bugs removed - RSBusCtrl
//          the RSBusCtrl did not process all possible situations
//
//        olupas@opencores.org
//-----------------------------------------------------------------------------
// Description    : The memory consists of a dual-port memory addressed by
//                  two counters (RdCnt & WrCnt). The third counter (StatCnt)
//                  sets the status signals and keeps a track of the data flow.
//-----------------------------------------------------------------------------
// Entity for miniUART Unit - 9600 baudrate                                  --
//-----------------------------------------------------------------------------

module miniUART(
SysClk,
Reset,
CS_N,
RD_N,
WR_N,
RxD,
TxD,
IntRx_N,
IntTx_N,
Addr,
DataIn,
DataOut
);

input SysClk; // System Clock
input Reset; // Reset input
input CS_N;
input RD_N;
input WR_N;
input RxD;
output TxD;
output IntRx_N; // Receive interrupt
output IntTx_N; // Transmit interrupt
input[1:0] Addr; // 
input[7:0] DataIn; // 
output[7:0] DataOut;

wire   SysClk;
wire   Reset;
wire   CS_N;
wire   RD_N;
wire   WR_N;
wire   RxD;
wire   TxD;
reg   IntRx_N;
reg   IntTx_N;
wire  [1:0] Addr;
wire  [7:0] DataIn;
reg  [7:0] DataOut;

//---------------------------------------------------------------------------
// Signals
//---------------------------------------------------------------------------
wire [7:0] RxData; // 
reg [7:0] TxData;  // 
reg [7:0] CSReg;   // Ctrl & status register
//             CSReg detailed 
//---------+--------+--------+--------+--------+--------+--------+--------+
// CSReg(7)|CSReg(6)|CSReg(5)|CSReg(4)|CSReg(3)|CSReg(2)|CSReg(1)|CSReg(0)|
//   Res   |  Res   |  Res   |  Res   | UndRun | OvrRun |  FErr  |  OErr  |
//---------+--------+--------+--------+--------+--------+--------+--------+
wire  EnabRx; // Enable RX unit
wire  EnabTx; // Enable TX unit
wire  DRdy;  // Receive Data ready
wire  TRegE; // Transmit register empty
wire  TBufE; // Transmit buffer empty
wire  FErr;  // Frame error
wire  OErr; // Output error
reg  Read;  // Read receive buffer
reg  Load;  // Load transmit buffer

//---------------------------------------------------------------------------
reg [4:0] StatM;
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Instantiation of internal components
//---------------------------------------------------------------------------
  ClkUnit ClkDiv(
      .SysClk (SysClk),
      .EnableRx (EnabRX),
      .EnableTx (EnabTX),
      .Reset (Reset));

  TxUnit TxDev(
      .Clk (SysClk),
      .Reset (Reset),
      .Enable (EnabTX),
      .Load (Load),
      .TxD (TxD),
      .TRegE (TRegE),
      .TBufE (TBufE),
      .DataO (TxData));

  RxUnit RxDev(
      .Clk (SysClk),
      .Reset (Reset),
      .Enable (EnabRX),
      .RxD (RxD),
      .RD (Read),
      .FErr (FErr),
      .OErr (OErr),
      .DRdy (DRdy),
      .DataIn (RxData));

  //---------------------------------------------------------------------------
  // Implements the controller for Rx&Tx units
  //---------------------------------------------------------------------------
  always @(posedge SysClk) 
  begin

    if(~Reset) 
	 begin
      StatM = 5'b00000;
      IntTx_N <= 1'b1;
      IntRx_N <= 1'b1;
      CSReg <= 8'b11110000;
    end
    else 
	 begin
      StatM[0]  = DRdy;
      StatM[1]  = FErr;
      StatM[2]  = OErr;
      StatM[3]  = TBufE;
      StatM[4]  = TRegE;
    end

    case(StatM)
    5'b00001 : begin
               IntRx_N   <= 1'b0;
               CSReg[2]  <= 1'b1;
               end
    5'b10001 : begin
               IntRx_N   <= 1'b0;
               CSReg[2]  <= 1'b1;
               end
    5'b11001 : begin
               IntRx_N   <= 1'b0;
               CSReg[2]  <= 1'b1;
               end
    5'b01000 : begin
               IntTx_N   <= 1'b0;
               end
    5'b11000 : begin
               IntTx_N   <= 1'b0;
               CSReg[3]  <= 1'b1;
               end
    default :  begin
               end
    endcase

    if(Read == 1'b1) 
	 begin
        CSReg[2] <= 1'b0;
        IntRx_N  <= 1'b1;
    end

    if(Load == 1'b1) 
	 begin
        CSReg[3] <= 1'b0;
        IntTx_N  <= 1'b1;
    end

  end

  //---------------------------------------------------------------------------
  // Combinational section
  //---------------------------------------------------------------------------
  always @(*) 
  begin

    if(~CS_N && ~RD_N) Read <= 1'b1;
    else               Read <= 1'b0;

    if(~CS_N && ~WR_N) Load <= 1'b1;
    else               Load <= 1'b0;

    if      (~Read)                   DataOut <= 8'bZZZZZZZZ;
    else if (Read && (Addr == 2'b00)) DataOut <= RxData;
    else if (Read && (Addr == 2'b10)) DataOut <= CSReg;

    if      (~Load)                   TxData <= 8'bZZZZZZZZ;
    else if (Load && (Addr == 2'b01)) TxData <= DataIn;

  end

//===================== End of architecture =======================--

endmodule

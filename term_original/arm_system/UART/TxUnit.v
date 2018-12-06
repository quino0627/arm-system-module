// File TxUnit.vhd translated with vhd2vl v2.0 VHDL to Verilog RTL translator
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
// File name      : TxUnit.vhd
//
// Purpose        : Implements an miniUART device for communication purposes 
//                  between the OR1K processor and the Host computer through
//                  an RS-232 communication protocol.
//                  
// Library        : uart_lib.vhd
//
// Dependencies   : IEEE.Std_Logic_1164
//
//===========================================================================--
//-----------------------------------------------------------------------------
// Revision list
// Version   Author                 Date                        Changes
//
// 0.1      Ovidiu Lupas       15 January 2000                 New model
// 2.0      Ovidiu Lupas       17 April   2000    unnecessary variable removed
//  olupas@opencores.org
//-----------------------------------------------------------------------------
// Description    : 
//-----------------------------------------------------------------------------
// Entity for the Tx Unit                                                    --
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Transmitter unit
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

module TxUnit(
Clk,
Reset,
Enable,
Load,
TxD,
TRegE,
TBufE,
DataO
);

input Clk; // Clock signal
input Reset; // Reset input
input Enable; // Enable input
input Load; // Load transmit data
output TxD; // RS-232 data output
output TRegE; // Tx register empty
output TBufE; // Tx buffer empty
input[7:0] DataO;

wire   Clk;
wire   Reset;
wire   Enable;
wire   Load;
wire   TRegE;
wire   TBufE;
wire  [7:0] DataO;

reg   TxD;

//---------------------------------------------------------------------------
// Signals
//---------------------------------------------------------------------------
reg [7:0] TBuff; // transmit buffer
reg [7:0] TReg; // transmit register
reg [3:0] BitCnt; // bit counter
reg  tmpTRegE; // 
reg  tmpTBufE; //

  //---------------------------------------------------------------------------
  // Implements the Tx unit
  //---------------------------------------------------------------------------
  always @(posedge Clk) begin : P1
    reg  tmp_TRegE;

    if(Reset == 1'b 0) begin
      tmpTRegE <= 1'b1;
      tmpTBufE <= 1'b1;
      TxD <= 1'b1;
      BitCnt <= 4'b0000;
    end
    else if(Load == 1'b1) begin
      TBuff <= DataO;
      tmpTBufE <= 1'b0;
    end
    else if(Enable == 1'b1) begin
      if((tmpTBufE == 1'b0) && (tmpTRegE == 1'b1)) begin
        TReg <= TBuff;
        tmpTRegE <= 1'b0; // tmp_TRegE := '0';
        tmpTBufE <= 1'b1;
        //           else
        //              tmp_TRegE := tmpTRegE;
      end
      if(tmpTRegE == 1'b 0) begin
        case(BitCnt)
        4'b0000 : begin
          TxD <= 1'b 0;
          BitCnt <= BitCnt + 4'b0001;
        end
        4'b0001,4'b0010,4'b0011,4'b0100,4'b0101,4'b0110,4'b0111,4'b1000 : begin
          TxD <= TReg[0] ;
          TReg <= {1'b 1,TReg[7:1] };
          BitCnt <= BitCnt + 4'b0001;
        end
        4'b1001 : begin
          TxD <= 1'b1;
          TReg <= {1'b1,TReg[7:1] };
          BitCnt <= 4'b0000;
          tmpTRegE <= 1'b1;
        end
        default : begin
        end
        endcase
      end
    end
  end

  assign TRegE = tmpTRegE;
  assign TBufE = tmpTBufE;
//=================== End of architecture ====================--

endmodule

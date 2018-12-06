// File RxUnit.vhd translated with vhd2vl v2.0 VHDL to Verilog RTL translator
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
// File name      : RxUnit.vhd
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
// 0.1      Ovidiu Lupas     15 January 2000                   New model
// 2.0      Ovidiu Lupas     17 April   2000  samples counter cleared for bit 0
//        olupas@opencores.org
//-----------------------------------------------------------------------------
// Description    : Implements the receive unit of the miniUART core. Samples
//                  16 times the RxD line and retain the value in the middle of
//                  the time interval. 
//-----------------------------------------------------------------------------
// Entity for Receive Unit - 9600 baudrate                                  --
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Receive unit
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

module RxUnit(
Clk,
Reset,
Enable,
RxD,
RD,
FErr,
OErr,
DRdy,
DataIn
);

input Clk; // system clock signal
input Reset; // Reset input
input Enable; // Enable input
input RxD; // RS-232 data input
input RD; // Read data signal
output FErr; // Status signal
output OErr; // Status signal
output DRdy; // Status signal
output[7:0] DataIn;

wire   Clk;
wire   Reset;
wire   Enable;
wire   RxD;
wire   RD;
wire   FErr;
wire   OErr;
wire   DRdy;
wire  [7:0] DataIn;

//---------------------------------------------------------------------------
// Signals
//---------------------------------------------------------------------------
reg  Start; // Syncro signal
reg  tmpRxD; // RxD buffer
reg  tmpDRdy; // Data ready buffer
reg  outErr; // 
reg  frameErr; // 
reg [3:0] BitCnt; // 
reg [3:0] SampleCnt; // samples on one bit counter
reg [7:0] ShtReg; //
reg [7:0] DOut; //

  //-------------------------------------------------------------------
  // Receiver process
  //-------------------------------------------------------------------
  always @(posedge Clk) begin
    if(Reset == 1'b0) begin
      BitCnt <= 4'b0000;
      SampleCnt <= 4'b0000;
      Start <= 1'b0;
      tmpDRdy <= 1'b0;
      frameErr <= 1'b0;
      outErr <= 1'b0;
      ShtReg <= 8'b00000000; //
      DOut <= 8'b00000000; //
    end
    else begin
      if(RD == 1'b1) begin
        tmpDRdy <= 1'b0;
        // Data was read
      end
      if(Enable == 1'b1) begin
        if(Start == 1'b0) begin
          if(RxD == 1'b0) begin
            // Start bit, 
            SampleCnt <= SampleCnt + 4'b0001;
            Start <= 1'b1;
          end
        end
        else begin
          if(SampleCnt == 4'b1000) begin
            // reads the RxD line
            tmpRxD <= RxD;
            SampleCnt <= SampleCnt + 4'b0001;
          end
          else if(SampleCnt == 4'b1111) begin
            case(BitCnt)
            4'b0000 : begin
              if(tmpRxD == 1'b1) begin
                // Start Bit
                Start <= 1'b0;
              end
              else begin
                BitCnt <= BitCnt + 4'b0001;
              end
              SampleCnt <= SampleCnt + 4'b0001;
              //when 1|2|3|4|5|6|7|8 =>
            end
            4'b0001,4'b0010,4'b0011,4'b0100,4'b0101,4'b0110,4'b0111,4'b1000 : begin
              BitCnt <= BitCnt + 4'b0001;
              SampleCnt <= SampleCnt + 4'b0001;
              ShtReg <= {tmpRxD,ShtReg[7:1] };
            end
            4'b1001 : begin
              if(tmpRxD == 1'b0) begin // stop bit expected
                frameErr <= 1'b1;
              end
              else begin
                frameErr <= 1'b0;
              end
              if(tmpDRdy == 1'b1) begin // 
                outErr <= 1'b1;
              end
              else begin
                outErr <= 1'b0;
              end
              tmpDRdy <= 1'b1;
              DOut <= ShtReg;
              BitCnt <= 4'b0000;
              Start <= 1'b0;
            end
            default : begin
            end
            endcase
          end
          else begin
            SampleCnt <= SampleCnt + 4'b0001;
          end
        end
      end
    end
  end

  assign DRdy = tmpDRdy;
  assign DataIn = DOut;
  assign FErr = frameErr;
  assign OErr = outErr;
//==================== End of architecture ====================--

endmodule

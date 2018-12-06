// File clkUnit.vhd translated with vhd2vl v2.0 VHDL to Verilog RTL translator
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
// Design units   : miniUART core for the OCRP-1
//
// File name      : clkUnit.vhd
//
// Purpose        : Implements an miniUART device for communication purposes 
//                  between the OR1K processor and the Host computer through
//                  an RS-233 communication protocol.
//                  
// Library        : uart_lib.vhd
//
// Dependencies   : IEEE.Std_Logic_1164
//
//===========================================================================--
//-----------------------------------------------------------------------------
// Revision list
// Version   Author              Date                Changes
//
// 1.0     Ovidiu Lupas      15 January 2000         New model
// 1.1     Ovidiu Lupas      28 May 2000     EnableRx/EnableTx ratio corrected
//      olupas@opencores.org
//-----------------------------------------------------------------------------
// Description    : Generates the Baud clock and enable signals for RX & TX
//                  units. 
//-----------------------------------------------------------------------------
// Entity for Baud rate generator Unit - 9600 baudrate                       --
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Baud rate generator
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

module ClkUnit(
SysClk,
EnableRx,
EnableTx,
Reset
);

input SysClk;    // System Clock
output EnableRx; // Control signal
output EnableTx; // Control signal
input Reset;

wire   SysClk;
wire   EnableRx;
wire   EnableTx;
wire   Reset;

// Reset input

//================== End of entity ==============================--
//-----------------------------------------------------------------------------
// Architecture for Baud rate generator Unit
//-----------------------------------------------------------------------------
//---------------------------------------------------------------------------
// Signals
//---------------------------------------------------------------------------
reg  ClkDiv33;
reg  tmpEnRX;
reg  tmpEnTX;
reg [5:0] Cnt33;
reg [4:0] Cnt16;
reg [3:0] Cnt10;

  //---------------------------------------------------------------------------
  // Divides the system clock of 40 MHz by 26
  //---------------------------------------------------------------------------

  always @(posedge SysClk) 
  begin 

    if(~Reset) begin
      Cnt33 = 6'b0;
      ClkDiv33 <= 1'b0;
    end
    else begin
      Cnt33 = Cnt33 + 6'b000001;
      case(Cnt33)
      	//6'b100001 : begin // 50MHz
      	6'b010010 : begin   // 27MHz
        					ClkDiv33 <= 1'b1;
        				   Cnt33 = 6'b0;
      					end
      	default:    begin
        				   ClkDiv33 <= 1'b0;
      				   end
      endcase
    end
  end

  //---------------------------------------------------------------------------
  // Provides the EnableRX signal, at ~ 155 KHz
  //---------------------------------------------------------------------------
  always @(posedge SysClk) 
  begin 

    if(~Reset) begin
      Cnt10 = 4'b0000;
      tmpEnRX <= 1'b0;
    end
    else if(ClkDiv33) begin
      Cnt10 = Cnt10 + 4'b0001;
    end

    case(Cnt10)
    4'b1010 : begin
      		  tmpEnRX <= 1'b 1;
      		  Cnt10 = 4'b0000;
    			  end
    default : begin
    			  tmpEnRX <= 1'b 0;
    			  end
    endcase

  end

  //---------------------------------------------------------------------------
  // Provides the EnableTX signal, at 9.6 KHz
  //---------------------------------------------------------------------------
  always @(posedge SysClk) 
  begin 

    if(~Reset) begin
      Cnt16 = 5'b00000;
      tmpEnTX <= 1'b0;
    end
    else if(tmpEnRX == 1'b1) begin
      Cnt16 = Cnt16 + 5'b00001;
    end
    case(Cnt16)
    5'b01111 : begin
      tmpEnTX <= 1'b1;
      Cnt16 = Cnt16 + 5'b00001;
    end
    5'b10001 : begin
      Cnt16 = 5'b00000;
      tmpEnTX <= 1'b0;
    end
    default : begin
      tmpEnTX <= 1'b0;
    end
    endcase

  end

  assign EnableRx = tmpEnRX;
  assign EnableTx = tmpEnTX;
//==================== End of architecture ===================--

endmodule

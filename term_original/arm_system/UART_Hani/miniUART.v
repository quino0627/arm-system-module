`timescale 1ns/1ps
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
input[11:0] Addr; // 
input[31:0] DataIn; // 
output[31:0] DataOut;

wire   SysClk;
wire   Reset;
wire   CS_N;
wire   RD_N;
wire   WR_N;
wire   RxD;
wire   TxD;
reg   IntRx_N;
reg   IntTx_N;
wire  [31:0] DataIn;
reg  [31:0] DataOut;

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

    if      (Read && (Addr == 12'h000)) DataOut <= {24'b0,{RxData}};
    else if (Read && (Addr == 12'h010)) DataOut <= {24'b0,{CSReg}};
    else                                DataOut <= 32'b0;

    if (Load && (Addr == 12'h004))  TxData <= DataIn[7:0];
	 else                            TxData <= 8'b0;

  end

//===================== End of architecture =======================--

endmodule

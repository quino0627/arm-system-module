
module armreduced(
   input clk,
   input reset,
   output [31:0] pc,   //->inst_addr, END
   input[31:0] inst,
   input nIRQ,
   output[3:0] be,
   output[31:0] memaddr,
   output memwrite,
   output memread,
   output[31:0] writedata,
   input[31:0] readdata
   );
   assign be = 4'b1111; // default
   assign memread = 'b1; // default

   reg [31:0] PC;
   wire [31:0] PC_prime;
   wire PCSrc, MemtoReg, MemWrite, ALUSrc;   
   wire [1:0] RegWrite;//Control Unit output wire (1/2)
   wire [2:0] ALUControl;
   wire [1:0] ImmSrc, RegSrc;   //Control Unit output wire (2/2)
   wire [4:0] RA1, RA2;   //Reg input wire
   wire [31:0] PCPlus4, PCPlus8;   //Reg input wire
   wire [31:0] ExtImm;   //Extend output wire
   wire [31:0] RD1, RD2;   //Register File output wire
   wire [31:0] SrcB; //ALU input wire
   wire [31:0] ALUResult;   //ALU output wire (1/2)
   wire ALUFlags;   //ALU output wire (2/2)
   
   wire [31:0] Result;
   
   
   assign pc = PC;
   
   //Instruction Decode. to control, reg..'
   ControlUnit controlunit(
      .clk(clk),
      .reset(reset),
      .Cond(inst[31:28]),   //input
      .Op(inst[27:26]),
      .Funct(inst[25:20]),
      .Rd(inst[15:12]),
      .ALUFlags(ALUFlags),
      .PCSrc(PCSrc),   //output
      .MemtoReg(MemtoReg),
      .MemWrite(MemWrite),
      .ALUControl(ALUControl),
      .ALUSrc(ALUSrc),
      .ImmSrc(ImmSrc),
      .RegWrite(RegWrite)
   );
   
   assign RA1=(RegSrc[0] == 0)? inst[19:16]:4'b1111;
   assign RA2=(RegSrc[1] == 0)? inst[3:0]:inst[15:12];
   assign Result = (MemtoReg)? readdata:ALUResult;
   
   RegisterFile registerfile(
      .clk(clk),
      .reset(reset),
      .A1(RA1),
      .A2(RA2),
      .A3(inst[15:12]),
      .WD3(Result),
      .RegWrite(RegWrite),
      .PCPlus8(PC+8),
      .RD1(RD1),
      .RD2(RD2)
   );

   assign SrcB=(ALUSrc)?ExtImm:RD2;
   assign memwrite = MemWrite;
   assign writedata = RD2;   

	ALU alu(
      .SrcA(RD1),
      .SrcB(SrcB),
      .ALUControl(ALUControl),
      .ALUResult(ALUResult),
      .ALUFlags(ALUFlags)
   );

   assign memaddr = ALUResult;

	Extend extend(
      .Instr(inst[23:0]),
      .ImmSrc(ImmSrc),
      .ExtImm(ExtImm)
   );

   //PC'
   assign PC_prime = (PCSrc)? Result:PC+4;
   
   //PC. reg, clk
   always @(negedge clk or posedge reset)
   begin
      if(reset==1)
         PC <= 32'b0;
      else
         PC <= PC_prime;
   end
   
endmodule


module Adder(
   input [31:0] v1,v2,
   output [31:0] y
   );

   assign y=v1+v2;
endmodule

module Mux2(
   input [31:0] d0,d1,
   input signal,
   output[31:0] y
   );
   assign y = signal? d1:d0;
endmodule
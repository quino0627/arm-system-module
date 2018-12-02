//controller
module controlUnit(input clk,reset,
                  input [31:12] Instr,
                  input [3:0] ALUFlags,
                  output [1:0] RegSrc,
                  output [1:0]RegWrite,
                  output [1:0] ImmSrc,
                  output ALUSrc,
                  output [1:0] ALUControl,
                  output MemWrite, MemtoReg,
                  output PCSrc);
  
  wire [1:0] FlagW;
  wire PCS, RegW, MemW;
  wire NoWrite;
  wire BLFlag;
  
  decoder dec( .Op(Instr[27:26]), .Funct(Instr[25:20]), .Rd(Instr[15:12]), .FlagW(FlagW), .PCS(PCS), .RegW(RegW), .MemW(MemW), .MemtoReg(MemtoReg), .ALUSrc(ALUSrc), .ImmSrc(ImmSrc), .RegSrc(RegSrc), .ALUControl(ALUControl), .NoWrite(NoWrite), .BLFlag(BLFlag));
  
  condlogic cl( .clk(clk), .reset(reset), .Cond(Instr[31:28]), .ALUFlags(ALUFlags), .FlagW(FlagW), .PCS(PCS), .RegW(RegW), .MemW(MemW), .PCSrc(PCSrc), .RegWrite(RegWrite), .MemWrite(MemWrite) );
  
endmodule

//condlogic
// Code your design here
module condlogic(input clk, reset,
input  [3:0] Cond,
input  [3:0] ALUFlags,
input  [1:0] FlagW,
input  PCS, RegW, MemW,
input NoWrite,
input BLFlag,
output  PCSrc, MemWrite,
output [1:0] RegWrite); // will be wires in tb
	wire [1:0] FlagWrite;
	wire [3:0] Flags;
	//reg [3:0] Flags_r;
	//assign Flags = Flags_r;
	wire CondEx;
  flopenr #(2) flagreg1( .clk(clk), .reset(reset), .en(FlagWrite[1]),.d(ALUFlags[3:2]), .q(Flags[3:2]) );
  flopenr #(2) flagreg0( .clk(clk), .reset(reset), .en(FlagWrite[0]),.d(ALUFlags[1:0]), .q(Flags[1:0]) ); 
// write controls are conditional
  condcheck cc(.Cond(Cond), .Flags(Flags), .CondEx(CondEx) );
assign FlagWrite = FlagW & {2{CondEx}};
assign RegWrite[1] = BLFlag;
assign RegWrite[0] = RegW & CondEx & !NoWrite;
assign MemWrite = MemW & CondEx;
assign PCSrc = PCS & CondEx;
endmodule
	
//condcheck
module condcheck(input  [3:0] Cond,
		input [3:0] Flags,
		output reg CondEx);
		wire neg, zero, carry, overflow, ge;
		assign {neg, zero, carry, overflow} = Flags;
		assign ge = (neg == overflow);
   always @(*)  begin
	case(Cond)
	4'b0000: CondEx = zero; // EQ
	4'b0001: CondEx = ~zero; // NE
	4'b0010: CondEx = carry; // CS
	4'b0011: CondEx = ~carry; // CC
	4'b0100: CondEx = neg; // MI
	4'b0101: CondEx = ~neg; // PL
	4'b0110: CondEx = overflow; // VS
	4'b0111: CondEx = ~overflow; // VC
	4'b1000: CondEx = carry & ~zero; // HI
	4'b1001: CondEx = ~(carry & ~zero); // LS
	4'b1010: CondEx = ge; // GE
	4'b1011: CondEx = ~ge; // LT
	4'b1100: CondEx = ~zero & ge; // GT
	4'b1101: CondEx = ~(~zero & ge); // LE
	4'b1110: CondEx = 1'b1; // Always
	default: CondEx = 1'bx; // undefined
	endcase
   end
endmodule

//decoder
module decoder(input  [1:0] Op,
	input  [5:0] Funct,
	input  [3:0] Rd,
	output  [1:0] FlagW,
	output  PCS, RegW, MemW,
	output  MemtoReg, ALUSrc,
	output  [1:0] ImmSrc, RegSrc,
    output reg[1:0] ALUControl,
    output reg  NoWrite,
    output reg BLFlag
    );
	reg [9:0] controls;
	wire Branch, ALUOp;
  reg [1:0] FlagW_;
  assign FlagW = FlagW_;
		// Main Decoder
  always @(*)  begin 
  BLFlag = 1'b0;
		case(Op)
		// Data-processing immediate
		2'b00: if (Funct[5]) controls = 10'b0000101001;
		// Data-processing register
		else controls = 10'b0000001001;
		// LDR
		2'b01: if (Funct[0]) controls = 10'b0001111000;
		// STR
		else controls = 10'b1001110100;
		// B
		2'b10: begin
		controls = 10'b0110100010;
		if(Funct[4]) BLFlag = 1'b1;
		end
		endcase
  end
	assign {RegSrc, ImmSrc, ALUSrc, MemtoReg,
	RegW, MemW, Branch, ALUOp} = controls;

// ALU Decoder
 always @(*)  begin
 NoWrite = 1'b1;
 if (ALUOp) begin // dp
  	case(Funct[4:1])
		4'b0100: ALUControl = 2'b00; // ADD
		4'b0010: ALUControl = 2'b01; // SUB
		//4'b0000: ALUControl = 2'b10; // AND
		//4'b1100: ALUControl = 2'b11; // ORR
		4'b0010:
		begin
			ALUControl = 2'b01; //CMP
			NoWrite = 1'b1;
		end
		4'b1101://MOV
		begin
			if (Funct[5]==1)
			begin
			ALUControl = 2'b10;
			end
		end
		default: ALUControl = 2'bx; // unimplemented
    endcase
    FlagW_[1] = Funct[0];
    FlagW_[0] = Funct[0] & (ALUControl == 2'b00 | ALUControl == 2'b01);
    end 
    else //not dp
	begin
        ALUControl = 2'b00; // add for non-DP instructions
        FlagW_ = 2'b00; // don't update Flags
	end
end
// PC Logic
assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
endmodule


module flopenr #(parameter WIDTH = 8)
  (input clk,reset,en,
   input [WIDTH-1:0] d,
   output reg [WIDTH -1:0] q);
  always @(posedge clk, posedge reset)
    begin
    if (reset) q<=0;
  else if (en) q<=d;
    end
endmodule

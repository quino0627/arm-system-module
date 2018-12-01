module ALU(
	input [31:0] srcA,
	input [31:0] srcB,
	input [1:0] ALUControl,
	output reg [31:0] ALUResult,
	output reg [3:0] ALUFlags
	);
	
	wire [31:0] condinvb; 
	wire [32:0] sum;
	wire Neg, Zero, Carry, oVerflow;
	
	assign condinvb = ALUControl[0] ? ~srcB:srcB;
	assign sum = srcA + condinvb + ALUControl[0];
	//2의 보수
	
	always @(*)
	
		casex(ALUControl)
			2'b0x: ALUResult = sum; //ADD, SUB
			// 2'b10: ALUResult = srcA & srcB; //AND
			// 2'b11: ALUResult = srcA | srcB; //OR
			2'b10 : ALUResult = srcB + 0 // equal 
			default: ALUResult = 2'bx;
		endcase

	assign Neg = ALUResult[31];
	assign Zero = (ALUResult == 32'b0);
	assign Carry = (ALUControl[1] == 1'b0) & sum[32];
	assign oVerflow = (ALUControl[1] == 1'b0) & ~(srcA[31]^srcB[31]^ALUControl[0]) & (srcA[31]^sum[31]);
	
	assign ALUflags  = {Neg, Zero, Carry, oVerflow};
endmodule
module ALU(
	input [31:0] SrcA,
	input [31:0] SrcB,
	input [1:0] ALUControl,
	output reg[31:0] ALUResult,
	output reg ALUFlags
	);
	// ALUControl == 00 :-> Result = SrcA + SrcB
	// ALUControl == 01 :-> Result = SrcA - SrcB
	// ALUControl == 10 :-> Result = SrcB
	// ALUControl == 11 :-> Result = SrcA - SrcB (which is only for CMP Op)
	// and then if Result == 0 :-> ALUFlags = 1 else 0
	always @(*)
	begin
		case(ALUControl)
		2'b00: begin
			ALUResult = SrcA + SrcB;
			ALUFlags = 0;
			end
		2'b01: begin
			ALUResult = SrcA - SrcB;
			ALUFlags = 0;
			end
		2'b10: begin
			ALUResult = SrcB;
			ALUFlags = 0;
			end
		2'b11: begin
			ALUResult = SrcA - SrcB;
			ALUFlags = (ALUResult==32'd0) ? 1'b1 : 1'b0;
			end
		endcase
	end
endmodule
		
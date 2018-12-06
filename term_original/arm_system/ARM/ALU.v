module ALU(
	input clk,
	input [31:0] SrcA,
	input [31:0] SrcB,
	input [2:0] ALUControl,//alucontrol is 3 bit
	//first bit is for add/sub conditional z update
	//others is typical
	output reg[31:0] ALUResult,
	output reg ALUFlags
	);

	always @(*)
	begin
		casex(ALUControl[2:0])
		   3'b000: begin
		         ALUResult = SrcA + SrcB;
		         end
		   3'b100: begin
		         ALUResult = SrcA + SrcB;
		         ALUFlags = (SrcA == SrcB);
		         end
		   3'b001: begin
		         ALUResult = SrcA - SrcB;
		         end
		   3'b101: begin
		         ALUResult = SrcA - SrcB;
		         ALUFlags = (SrcA == SrcB);
		         end
		   3'b010: begin   
		         ALUResult =  SrcB;
		         end
		   3'b110: begin
		         ALUResult =  SrcB;
		         ALUFlags = (SrcA == SrcB);
		         end
		   3'b011: begin
		         ALUResult =  SrcA - SrcB;
		         ALUFlags = (SrcA == SrcB);
		         end
		   default:
			begin
				ALUFlags = 1'b1;
			end
		endcase


	end
endmodule
		
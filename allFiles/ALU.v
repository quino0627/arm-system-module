module ALU(
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
		case(ALUControl[1:0]) 
		2'b00: begin
			
			ALUResult[30:0] = SrcA[30:0] + SrcB[30:0];
			ALUResult[31]= SrcA[31] + SrcB[31];
			//ALUResult = SrcA + SrcB;
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
		if(ALUControl[2]) //if this is 1, then update z value
		begin
			ALUResult = SrcA - SrcB;
			ALUFlags = (ALUResult==32'd0) ? 1'b1 :1'b0;
		end

	end
endmodule
		
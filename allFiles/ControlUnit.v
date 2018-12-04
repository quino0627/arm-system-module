module ControlUnit(
	input clk, reset,
	input [3:0] Cond,
	input [2:0] Op,
	input [5:0] Funct,
	input [3:0] Rd,
	input ALUFlags,
    output reg [1:0] RegSrc,
    output reg [1:0] RegWrite,
    output reg [1:0] ImmSrc,
    output reg ALUSrc,
    output reg [2:0] ALUControl,
    output reg MemWrite,
	output reg MemtoReg,
    output reg PCSrc);
	//first check the OP
	//then Funct
	//then condcheck
	initial
	begin
	ALUControl[2] = 0;
	end

always @(*)
begin
	if(reset ==1'b1)
	begin
		RegSrc = 2'b00;
		ALUControl[1:0] = 2'b00;
		PCSrc = 1'b0;
		MemtoReg = 1'b0;
		MemWrite = 1'b0;
		ALUSrc = 1'b0;
		ImmSrc = 2'b00;
		RegWrite = 2'b00;
	end
	case (Op)
		2'b00://ADD,SUB,CMP,MOV
		begin
		PCSrc = 1'b0;
		MemtoReg = 1'b0;
		MemWrite = 1'b0;
		casex(Funct)
			6'b00100x://ADD
			begin 
				casex(Cond)//AL, EQ, NE
				4'b1110://ADDAL
				begin
					ALUSrc = 1'b0;
					ALUControl[1:0] = 2'b00;
					//IMMSRC DONTCARE
					RegWrite = 2'b11; //REGWRITE 1bit?
					RegSrc = 2'b00;
				end
				4'b0000://ADDEQ
				begin
					if(ALUFlags==1)
					begin
						ALUSrc = 1'b0;
						ALUControl[1:0] = 2'b00;
						//IMMSRC DONTCARE
						RegWrite = 2'b11; //REGWRITE 1bit?
						RegSrc = 2'b00;
					end
					else
					begin
						RegWrite = 2'b00;
						//others, dont care
					end
				end
				4'b0001://ADDNE
				begin
					if(ALUFlags==0)
					begin
						ALUSrc = 1'b0;
						ALUControl[1:0] = 2'b00;
						//IMMSRC DONTCARE
						RegWrite = 2'b11; //REGWRITE 1bit?
						RegSrc = 2'b00;
					end
					else
					begin
						RegWrite = 2'b00;
						//others, dont care
					end
				end
				endcase
				if(Funct[0]==1)
				begin
					ALUControl[2] = 1; //if this is 1, update flag
				end
				else begin
					ALUControl[2] = 0;
				end
			end
			6'b10100x://ADDi
			begin 
				casex(Cond)//AL, EQ, NE
				4'b1110://ADDiAL
				begin
					ALUSrc = 1'b1;
					ALUControl[1:0] = 2'b00;
					ImmSrc = 2'b00;
					RegWrite = 2'b11; //REGWRITE 1bit?
					RegSrc = 2'bx0; //REGSRC[1] is DC
				end
				4'b0000://ADDiEQ
				begin
					if(ALUFlags==1)
					begin
						ALUSrc = 1'b1;
						ALUControl[1:0] = 2'b00;
						ImmSrc = 2'b00;
						RegWrite = 2'b11; //REGWRITE 1bit?
						RegSrc = 2'bx0;
					end
					else
					begin
						RegWrite = 2'b00;
						//others, dont care
					end
				end
				4'b0001://ADDiNE
				begin
					if(ALUFlags==0)
					begin
						ALUSrc = 1'b1;
						ALUControl[1:0] = 2'b00;
						ImmSrc = 2'b00;
						RegWrite = 2'b11; //REGWRITE 1bit?
						RegSrc = 2'bx0;
					end
					else
					begin
						RegWrite = 2'b00;
						//others, dont care
					end
				end
				endcase
				if(Funct[0]==1)
				begin
					ALUControl[2] = 1; //if this is 1, update flag
				end
				else begin
					ALUControl[2] = 0;
				end
			end
			6'b00010x://SUB
			begin
				casex(Cond)//AL, EQ, NE
				4'b1110://SUBAL
				begin
					ALUSrc = 1'b0;
					ALUControl[1:0] = 2'b01;
					//IMMSRC DONTCARE
					RegWrite = 2'b11; //REGWRITE 1bit?
					RegSrc = 2'b00;
				end
				4'b0000://SUBEQ
				begin
					if(ALUFlags==1)
					begin
						ALUSrc = 1'b1;
						ALUControl[1:0] = 2'b01;
						//IMMSRC DONTCARE
						RegWrite = 2'b11; //REGWRITE 1bit?
						RegSrc = 2'b00;
					end
					else
					begin
						RegWrite = 2'b00;
						//others, dont care
					end
				end
				4'b0001://SUBNE
				begin
					if(ALUFlags==0)
					begin
						ALUSrc = 1'b1;
						ALUControl[1:0] = 2'b01;
						//IMMSRC DONTCARE
						RegWrite = 2'b11; //REGWRITE 1bit?
						RegSrc = 2'b00;
					end
					else
					begin
						RegWrite = 2'b00;
						//others, dont care
					end
				end
				endcase
				if(Funct[0]==1)
				begin
					ALUControl[2] = 1; //if this is 1, update flag
				end
				else begin
					ALUControl[2] = 0;
				end
			end
			6'b10010x://SUBi
			begin
				casex(Cond)//AL, EQ, NE
				4'b1110://SUBiAL
				begin
					ALUSrc = 1'b1;
					ALUControl[1:0] = 2'b01;
					ImmSrc = 2'b00;
					RegWrite = 2'b11; //REGWRITE 1bit?
					RegSrc = 2'bx0;
				end
				4'b0000://SUBiEQ
				begin
					if(ALUFlags==1)
					begin
						ALUSrc = 1'b1;
						ALUControl[1:0] = 2'b01;
						ImmSrc = 2'b00;
						RegWrite = 2'b11; //REGWRITE 1bit?
						RegSrc = 2'bx0;
					end
					else
					begin
						RegWrite = 2'b00;
						//others, dont care??
					end
				end
				4'b0001://SUBiNE
				begin
					if(ALUFlags==0)
					begin
						ALUSrc = 1'b1;
						ALUControl[1:0] = 2'b01;
						ImmSrc = 2'b00;
						RegWrite = 2'b11; //REGWRITE 1bit?
						RegSrc = 2'bx0;
					end
					else
					begin
						RegWrite = 2'b00;
						//others, dont care??
					end
				end
				endcase
				if(Funct[0]==1)
				begin
					ALUControl[2] = 1; //if this is 1, update flag
				end
				else begin
					ALUControl[2] = 0;
				end
			end
			6'b01010x://CMP
			begin
				casex(Cond)//AL, EQ, NE
				4'b1110://CMPAL
				begin
					ALUControl[1:0] = 2'b11;
					ALUSrc = 1'b0; //cmpi -> 1
					//IMMSRC DONTCARE
					RegWrite = 2'b00;
					RegSrc = 2'b00; //CMPi -> DC

				end
				4'b0000://CMPEQ
				begin
					if(ALUFlags==1)
					begin
						ALUSrc = 1'b0;
						ALUControl[1:0] = 2'b11;
						//IMMSRC DONTCARE
						RegWrite = 2'b00; 
						RegSrc = 2'b00; //CMPi -> DC
					end
					else
					begin
						RegWrite = 2'b00;
						ALUControl[1:0] = 2'b00; // NOT TO update flags -> NOT 11
						//others, dont care??
					end
				end
				4'b0001://CMPNE
				begin
					if(ALUFlags==0)
					begin
						ALUSrc = 1'b0;
						ALUControl[1:0] = 2'b11;
						//IMMSRC DONTCARE
						RegWrite = 2'b00; 
						RegSrc = 2'b00; //CMPi -> DC
					end
					else
					begin
						RegWrite = 2'b00;
						ALUControl[1:0] = 2'b00; // NOT TO update flags -> NOT 11
						//others, dont care??
					end
				end
				endcase
			end
			6'b11010x://CMPi
			begin
				casex(Cond)//AL, EQ, NE
				4'b1110://CMPiAL
				begin
					ALUSrc = 1'b1;
					ALUControl[1:0] = 2'b11;
					ImmSrc = 2'b00;
					RegWrite = 2'b00;
					RegSrc = 2'b00;
				end
				4'b0000://CMPiEQ
				begin
					if(ALUFlags==1)
					begin
						ALUSrc = 1'b1;
						ALUControl[1:0] = 2'b11;
						ImmSrc = 2'b00;
						RegWrite = 2'b00; 
						RegSrc = 2'b00; //CMPi -> DC
					end
					else
					begin
						RegWrite = 2'b00;
						ALUControl[1:0] = 2'b00; // NOT TO update flags -> NOT 11
						//others, dont care??
					end
				end
				4'b0001://CMPiNE
				begin
					if(ALUFlags==0)
					begin
						ALUSrc = 1'b1;
						ALUControl[1:0] = 2'b11;
						ImmSrc = 2'b00;
						RegWrite = 2'b00; 
						RegSrc = 2'b00; //CMPi -> DC
					end
					else
					begin
						RegWrite = 2'b00;
						ALUControl[1:0] = 2'b00; // NOT TO update flags -> NOT 11
						//others, dont care??
					end
				end
				endcase
			end
			6'b01101x://MOV
			begin
				casex(Cond)//AL, EQ, NE
				4'b1110://MOVAL
				begin
					ALUControl[1:0] = 2'b10;
					ALUSrc = 1'b0;
					//IMMSRC DONTCARE
					RegWrite = 2'b11;
					RegSrc = 2'b00;
				end
				4'b0000://MOVEQ
				begin
					if(ALUFlags==1)
					begin
						ALUSrc = 1'b0;
						ALUControl[1:0] = 2'b10;
						RegWrite = 2'b11; 
						RegSrc = 2'b00; 
					end
					else
					begin
						RegWrite = 2'b00; //not write on reg -->meaning instr is not execute
						//others, dont care??
					end
				end
				4'b0001://MOVNE
				begin
					if(ALUFlags==0)
					begin
						ALUSrc = 1'b0;
						ALUControl[1:0] = 2'b10;
						RegWrite = 2'b11; 
						RegSrc = 2'b00; 
					end
					else
					begin
						RegWrite = 2'b00; //not write on reg -->meaning instr is not execute
						//others, dont care??
					end
				end
				endcase
			end
			6'b11101x://MOVi
			begin
				casex(Cond)//AL, EQ, NE
				4'b1110://MOViAL
				begin
					ALUControl[1:0] = 2'b10;
					ALUSrc = 1'b1;
					ImmSrc = 2'b00;
					RegWrite = 2'b11;
					RegSrc = 2'bx0;
				end
				4'b0000://MOViEQ
				begin
					if(ALUFlags==1)
					begin
						ALUSrc = 1'b1;
						ALUControl[1:0] = 2'b00;
						RegWrite = 2'b11; 
						RegSrc = 2'bx0; 
					end
					else
					begin
						RegWrite = 2'b00; //not write on reg -->meaning instr is not execute
						//others, dont care??
					end
				end
				4'b0001://MOViNE
				begin
					if(ALUFlags==0)
					begin
						ALUSrc = 1'b1;
						ALUControl[1:0] = 2'b00;
						RegWrite = 2'b11; 
						RegSrc = 2'bx0; 
					end
					else
					begin
						RegWrite = 2'b00; //not write on reg -->meaning instr is not execute
						//others, dont care??
					end
				end
				endcase
			end
		endcase
		end

		2'b01: //STR,LDR
		begin
		casex(Funct)
			6'b0xxxx0://STR
			begin
				casex(Cond)//AL, EQ, NE
				4'b1110://STRAL
				begin
					PCSrc = 1'b0;
					MemtoReg = 1'b0;
					MemWrite = 1'b1;
					ALUControl[1:0] = 2'b00;
					ALUSrc = 1'b0;
					ImmSrc = 2'b01;
					RegWrite = 2'b00;
					RegSrc = 2'b10;
				end
				4'b0000://STREQ
				begin
					if(ALUFlags==1)
					begin
						PCSrc = 1'b0;
						MemtoReg = 1'b0;
						MemWrite = 1'b1;
						ALUControl[1:0] = 2'b00;
						ALUSrc = 1'b0;
						ImmSrc = 2'b01;
						RegWrite = 2'b00;
						RegSrc = 2'b10;
					end
					else
					begin//How to not excute instruction?
					//Maybe inverse 0 to 1 memwrite
						MemWrite = 1'b0;
					end
				end
				4'b0001://STRNE
				begin
					if(ALUFlags==0)
					begin
						PCSrc = 1'b0;
						MemtoReg = 1'b0;
						MemWrite = 1'b1;
						ALUControl[1:0] = 2'b00;
						ALUSrc = 1'b0;
						ImmSrc = 2'b01;
						RegWrite = 2'b00;
						RegSrc = 2'b10;
					end
					else
					begin//How to not excute instruction?
					//Maybe inverse 0 to 1 memwrite
						MemWrite = 1'b0;
					end
				end
				endcase
			end
			6'b1xxxx0://STRi
			begin
				casex(Cond)//AL, EQ, NE
				4'b1110://STRiAL
				begin
					PCSrc = 1'b0;
					MemtoReg = 1'b0;
					MemWrite = 1'b1;
					ALUControl[1:0] = 2'b00;
					ALUSrc = 1'b1;
					ImmSrc = 2'b01;
					RegWrite = 2'b00;
					RegSrc = 2'b10;
				end
				4'b0000://STRiEQ
				begin
					if(ALUFlags==1)
					begin
						PCSrc = 1'b0;
						MemtoReg = 1'b0;
						MemWrite = 1'b1;
						ALUControl[1:0] = 2'b00;
						ALUSrc = 1'b1;
						ImmSrc = 2'b01;
						RegWrite = 2'b00;
						RegSrc = 2'b10;
					end
					else
					begin//How to not excute instruction?
					//Maybe inverse 0 to 1 memwrite
						MemWrite = 1'b0;
					end
				end
				4'b0001://STRiNE
				begin
					if(ALUFlags==0)
					begin
						PCSrc = 1'b0;
						MemtoReg = 1'b0;
						MemWrite = 1'b1;
						ALUControl[1:0] = 2'b00;
						ALUSrc = 1'b1;
						ImmSrc = 2'b01;
						RegWrite = 2'b00;
						RegSrc = 2'b10;
					end
					else
					begin//How to not excute instruction?
					//Maybe inverse 0 to 1 memwrite
						MemWrite = 1'b0;
					end
				end
				endcase
			end
			6'b0xxxx1://LDR
			begin
				casex(Cond)//AL, EQ, NE
				4'b1110://LDRAL
				begin
					PCSrc = 1'b0;
					MemtoReg = 1'b1;
					MemWrite = 1'b0;
					ALUControl[1:0] = 2'b00;
					ALUSrc = 1'b0;
					ImmSrc = 2'b01;
					RegWrite = 2'b00;
					RegSrc = 2'b00;
				end
				4'b0000://LDREQ
				begin
					if(ALUFlags==1)
					begin
						PCSrc = 1'b0;
						MemtoReg = 1'b1;
						MemWrite = 1'b0;
						ALUControl[1:0] = 2'b00;
						ALUSrc = 1'b0;
						ImmSrc = 2'b01;
						RegWrite = 2'b00;
						RegSrc = 2'b00;
					end
					else
					begin//How to not excute instruction?
					//Maybe inverse 0 to 1 memtoreg
						MemtoReg = 1'b0;
					end
				end
				4'b0001://LDRNE
				begin
					if(ALUFlags==0)
					begin
						PCSrc = 1'b0;
						MemtoReg = 1'b1;
						MemWrite = 1'b0;
						ALUControl[1:0] = 2'b00;
						ALUSrc = 1'b0;
						ImmSrc = 2'b01;
						RegWrite = 2'b00;
						RegSrc = 2'b00;
					end
					else
					begin//How to not excute instruction?
					//Maybe inverse 0 to 1 memtoreg
						MemtoReg = 1'b0;
					end
				end
				endcase
			end
			6'b1xxxx1://LDRi
			begin
				casex(Cond)//AL, EQ, NE
				4'b1110://LDRiAL
				begin
					PCSrc = 1'b0;
					MemtoReg = 1'b1;
					MemWrite = 1'b0;
					ALUControl[1:0] = 2'b00;
					ALUSrc = 1'b1;
					ImmSrc = 2'b01;
					RegWrite = 2'b00;
					RegSrc = 2'b00;
				end
				4'b0000://LDRiEQ
				begin
					if(ALUFlags==1)
					begin
						PCSrc = 1'b0;
						MemtoReg = 1'b1;
						MemWrite = 1'b0;
						ALUControl[1:0] = 2'b00;
						ALUSrc = 1'b1;
						ImmSrc = 2'b01;
						RegWrite = 2'b00;
						RegSrc = 2'b00;
					end
					else
					begin//How to not excute instruction?
					//Maybe inverse 0 to 1 memtoreg
						MemtoReg = 1'b0;
					end
				end
				4'b0001://LDRiNE
				begin
					if(ALUFlags==0)
					begin
						PCSrc = 1'b0;
						MemtoReg = 1'b1;
						MemWrite = 1'b0;
						ALUControl[1:0] = 2'b00;
						ALUSrc = 1'b1;
						ImmSrc = 2'b01;
						RegWrite = 2'b00;
						RegSrc = 2'b00;
					end
					else
					begin//How to not excute instruction?
					//Maybe inverse 0 to 1 memtoreg
						MemtoReg = 1'b0;
					end
				end
				endcase
			end
			endcase
		end

		2'b10: //B,BL
		begin
			casex(Funct[5:4])
			2'b10: //B
			begin
				casex(Cond)//AL, EQ, NE
				4'b1110://BAL
				begin
					PCSrc = 1'b1;
					MemtoReg = 1'b0;
					MemWrite = 1'b0;
					ALUControl[1:0] = 2'b00;
					ALUSrc = 1'b1;
					ImmSrc = 2'b11;
					RegWrite = 2'b00;
					RegSrc = 2'bx1;
				end
				4'b0000://BEQ
				begin	
					if(ALUFlags==1)
					begin
						PCSrc = 1'b1;
						MemtoReg = 1'b0;
						MemWrite = 1'b0;
						ALUControl[1:0] = 2'b00;
						ALUSrc = 1'b1;
						ImmSrc = 2'b11;
						RegWrite = 2'b00;
						RegSrc = 2'bx1;
					end
					else
					begin//How to not excute instruction?
					//Maybe inverse 1 to 0 pcsrc
						PCSrc = 1'b0;
					end
				end
				4'b0001://BNE
				begin
					if(ALUFlags==0)
					begin
						PCSrc = 1'b1;
						MemtoReg = 1'b0;
						MemWrite = 1'b0;
						ALUControl[1:0] = 2'b00;
						ALUSrc = 1'b1;
						ImmSrc = 2'b11;
						RegWrite = 2'b00;
						RegSrc = 2'bx1;
					end
					else
					begin//How to not excute instruction?
					//Maybe inverse 1 to 0 pcsrc
						PCSrc = 1'b0;
					end
				end
				endcase
			end
			2'b11: //BL
			begin
				casex(Cond)//AL, EQ, NE
				4'b1110://BLAL
				begin
					PCSrc = 1'b1;
					MemtoReg = 1'b0;
					MemWrite = 1'b0;
					ALUControl[1:0] = 2'b00;
					ALUSrc = 1'b1;
					ImmSrc = 2'b11;
					RegWrite = 2'b10;
					RegSrc = 2'bx1;
				end
				4'b0000://BLEQ
				begin
					if(ALUFlags==1)
					begin
						PCSrc = 1'b1;
						MemtoReg = 1'b0;
						MemWrite = 1'b0;
						ALUControl[1:0] = 2'b00;
						ALUSrc = 1'b1;
						ImmSrc = 2'b11;
						RegWrite = 2'b10;
						RegSrc = 2'bx1;
					end
					else
					begin//How to not excute instruction?
					//Maybe inverse 1 to 0 pcsrc
						PCSrc = 1'b0;
					end
				end
				4'b0001://BLNE
				begin
					if(ALUFlags==0)
					begin
						PCSrc = 1'b1;
						MemtoReg = 1'b0;
						MemWrite = 1'b0;
						ALUControl[1:0] = 2'b00;
						ALUSrc = 1'b1;
						ImmSrc = 2'b11;
						RegWrite = 2'b10;
						RegSrc = 2'bx1;
					end
					else
					begin//How to not excute instruction?
					//Maybe inverse 1 to 0 pcsrc
						PCSrc = 1'b0;
					end
				end
				endcase
			end
			endcase
		end 
		default:
		begin

		end 
	endcase

end


endmodule
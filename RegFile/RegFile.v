 module RegFile( //register file
   input clk,
   input reset,

   input [3:0] A1,
   input [3:0] A2,
   input [3:0] A3,   //write address
   input [31:0] WD3, //write data input
   input [1:0]RegWrite,   //write enable input (RE3)
   input [31:0] R15, //PCPLUS8
   
   output [31:0] RD1,   //data from reg addr A1
   output [31:0] RD2   //data from reg addr A2
   );
   
   reg[31:0] R[15:0]; 
   integer i;
   always @ (negedge clk or posedge reset)
   begin   
   
         if (reset==1) 
         begin
            for (i=0; i<16 ;i=i+1)
            begin
				R[i] <= 32'b0;
            end
         end
         
         else 
         begin     
         //10 BL
         //11 write
         //00 no write
            R[15] <= R15;    
            if(RegWrite == 2'b11) begin // if RegWrite == 01, write data into reg
               R[A3] <= WD3;
            end
            else if(RegWrite == 2'b10) begin
               R[14] <= (PCPlus8 - 4); //PC = PC-4
            end
         end
   end
   assign RD1 = A1;
   assign RD2 = A2;
   
endmodule
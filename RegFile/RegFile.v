module RegFile( //register file
   input clk,
   input reset,

   input [3:0] A1,
   input [3:0] A2,
   input [3:0] A3,   //write address
   input [31:0] WD3, //write data input
   input RegWrite,   //write enable input (RE3)
   input [31:0] PCPlus8,   //PCPlus8, R15

   output [31:0] RD1,   //data from reg addr A1
   output [31:0] RD2   //data from reg addr A2
   );
   
   reg[31:0] R[15:0]; 
   integer i;
   always @ (posedge clk or posedge reset)
   begin   
   
         if (reset) 
         begin
            for (i=0; i<16 ;i=i+1)
            begin
				R[i] <= 32'b0;
            end
         end
         
         else 
         begin         
            if(RegWrite == 1'b1) begin // if RegWrite == 1, write data into reg
               R[A3] <= WD3;
            end
            R[15] <= PCPlus8;
         end
   end
   assign RD1 = R[A1];
   assign RD2 = R[A2];
   
endmodule
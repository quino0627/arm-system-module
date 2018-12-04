 module RegisterFile( //register file
   input clk,
   input reset,

   input [3:0] A1,
   input [3:0] A2,
   input [3:0] A3,   //write address
   input [31:0] WD3, //write data input
   input [1:0 ]RegWrite,   //write enable input (RE3)
   input [31:0] PCPlus8,   //PCPlus8, R15

   output reg [31:0] RD1,   //data from reg addr A1
   output reg [31:0] RD2   //data from reg addr A2
   );
   
   reg[31:0] Rf[15:0]; 
   integer i;

   always @ (posedge clk)
   begin
      //RD1 = (A1==4'b1111) ? PCPlus8 : Rf[A1];
      RD1 = (A1==4'b1111) ? Rf[A1] : PCPlus8;
      RD2 = (A2==4'b1111) ? PCPlus8 : Rf[A2];
   end
   
   always @ (negedge clk or posedge reset)
   begin   
   
         if (reset) begin
            for (i=0; i<16 ;i=i+1)begin Rf[i] <= 32'b0; end
         end
         //10 BL
         //11 write
         //00 no write   
         else if(RegWrite == 2'b11)
         begin // if RegWrite == 11, write data into reg
            Rf[A3] <= WD3;
         end
         else if(RegWrite == 2'b10)
         begin
            Rf[14] <= (PCPlus8 - 4); //PC = PC-4
         end
          
   end
 
   
endmodule
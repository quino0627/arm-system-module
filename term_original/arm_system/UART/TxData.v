
module TxData (
		  input SysClk,
		  input Reset,

		  output reg [6:0] HEX7,  // 
		  output reg [6:0] HEX6,  // 
		  output reg [6:0] HEX5,  //
		  output reg [6:0] HEX4,  //
		  output reg [6:0] HEX3,  //
		  output reg [6:0] HEX2,  //
		  output reg [6:0] HEX1,  //
		  output reg [6:0] HEX0,  //

		  output reg [1:0] Addr,
		  output reg [7:0] DataOut,
		  input      [7:0] DataIn,
		  output reg       CS_N,
		  output reg       RD_N,
		  output reg       WR_N);

			reg [2:0] c_state;
			reg [2:0] n_state;

			reg [7:0] CSRegIn;
			reg [7:0] tmpDataOut;

			parameter  S0 =  3'b000;
			parameter  S1 =  3'b001;
			parameter  S2 =  3'b010;
			parameter  S3 =  3'b011;
			parameter  S4 =  3'b100;
			parameter  S5 =  3'b101;
			parameter  S6 =  3'b110;
			parameter  S7 =  3'b111;

			parameter  LED_None =  7'b0111111;  // Display "-"

			reg  [2:0] counter;

			always@ (posedge SysClk) // output logic
			begin
				if(~Reset) 
				begin
				 	counter <= 3'b000;
				 	HEX0 <= LED_None;
				 	HEX1 <= LED_None;
				 	HEX2 <= LED_None;
				 	HEX3 <= LED_None;
				 	HEX4 <= LED_None;
				 	HEX5 <= LED_None;
				 	HEX6 <= LED_None;
				 	HEX7 <= LED_None;
				end
				else
				begin
				   if (c_state == S6)  // 
					begin
                  case (counter)
					   3'b000: HEX0 <= tmpDataOut[6:0];
					   3'b001: HEX1 <= tmpDataOut[6:0];
					   3'b010: HEX2 <= tmpDataOut[6:0];
					   3'b011: HEX3 <= tmpDataOut[6:0];
					   3'b100: HEX4 <= tmpDataOut[6:0];
					   3'b101: HEX5 <= tmpDataOut[6:0];
					   3'b110: HEX6 <= tmpDataOut[6:0];
					   3'b111: HEX7 <= tmpDataOut[6:0];
			 			endcase
						counter <= counter + 3'b001;
				   end
				end
			end


			always@ (posedge SysClk) // output logic
			begin
				if(~Reset) 
				 	CSRegIn <= 8'h00;
				else
				begin
					if      (c_state == S0) CSRegIn <= 8'h0;
				   else if (c_state == S3) CSRegIn <= DataIn;
				end
			end

			always@ (*) 
			begin
				 if (DataOut == 8'h7A)  tmpDataOut <= 8'h41;
				 else                   tmpDataOut <= DataOut + 8'h01;
			end

			always@ (posedge SysClk) // output logic
			begin
			if (~Reset)    
			begin
				   CS_N    <= 1'b1;
				   RD_N    <= 1'b1;
				   WR_N    <= 1'b1;
					DataOut <= 8'h41;
			end
		   else
			begin
				if (c_state == S2) // Read status register to check if Tx buffer is empty 
			 	begin
				   CS_N <= 1'b0;
				   RD_N <= 1'b0;
				   WR_N <= 1'b1;
				   Addr <= 2'b01;
				end
				else if (c_state == S6) // Transmit "tmpDataOut" to TxD
			 	begin
				   CS_N <= 1'b0;
				   RD_N <= 1'b1;
				   WR_N <= 1'b0;
				   Addr <= 2'b00;
				   DataOut <= tmpDataOut;
				end
				else
			 	begin
				   CS_N <= 1'b1;
				   RD_N <= 1'b1;
				   WR_N <= 1'b1;
				end
			end
			end

			always@ (posedge SysClk) // synchronous resettable flop-flops
			begin
				if(~Reset) c_state <= S0;
				else       c_state <= n_state;
			end
			
			always@(*) // Next state logic
			begin
			case(c_state)
			S0 :  n_state <= S1;
			S1 :  n_state <= S2;
			S2 :  n_state <= S3;
			S3 :  n_state <= S4;
			S4 :  if (CSRegIn[3])  n_state <= S6; //UnderRun (Tx Buffer & Tx Reg Empty)
			      else             n_state <= S5;
			S5 :  n_state <= S2;
			S6 :  n_state <= S0;
			default:  n_state <= S0;
			endcase
         end

endmodule 

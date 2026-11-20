module memory(clk_i,rst_i,valid_i,ready_o,wr_rd_i,wdata_i,rdata_o,addr_i);
	input clk_i,rst_i,valid_i,wr_rd_i;
	input [`DATA_WIDTH-1:0] wdata_i;
	input [`ADDR_WIDTH-1:0] addr_i;
	output reg ready_o;
	output reg [`DATA_WIDTH-1:0] rdata_o;
	integer i;
	reg [`DATA_WIDTH-1:0] mem [`DEPTH-1:0];


	always@(posedge clk_i) begin
		if(rst_i == 1) begin
			ready_o <= 0;
			rdata_o <= 0;
			for(i=0;i<`DEPTH;i=i+1) begin
				mem[i] = 0;
			end
		end 
		//rst end 
		else begin
			if(valid_i == 1) begin
				ready_o <= 1; 
				if(wr_rd_i == 1) begin
					mem[addr_i] <= wdata_i;
				end
				if(wr_rd_i == 0) begin
					rdata_o <= mem[addr_i];
				end
		end //valid end 
		else begin
			ready_o <= 0;
		end
		end
	end //always end

endmodule

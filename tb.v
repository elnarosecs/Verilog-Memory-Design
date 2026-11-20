
`define DEPTH 10
`define DATA_WIDTH 32
`define ADDR_WIDTH $clog2(`DEPTH)
`include "memory.v"

module top;
	reg clk_i,rst_i,valid_i,wr_rd_i;
	reg [`DATA_WIDTH-1:0] wdata_i;
	reg [`ADDR_WIDTH-1:0] addr_i;
	wire ready_o;
	wire [`DATA_WIDTH-1:0] rdata_o;
	reg [`DATA_WIDTH-1:0] data_arr [`DEPTH-1:0]; 
	integer i;

memory dut(
			.clk_i(clk_i),
			.rst_i(rst_i),
			.valid_i(valid_i),
			.ready_o(ready_o),
			.wr_rd_i(wr_rd_i),
			.wdata_i(wdata_i),
			.rdata_o(rdata_o),
			.addr_i(addr_i));
// clock generation
	always #5 clk_i = ~clk_i;

// reset task(its a good coding practice to make inputs of tb to be idle)
task reset();
		begin
			valid_i <= 0;
			wr_rd_i <= 0;
			wdata_i <= 0;
			addr_i  <= 0;
			@(posedge clk_i);// upto next positive edge it waits
		end
endtask

// write task
task write(input reg [`ADDR_WIDTH-1:0] start_loc, input reg [`ADDR_WIDTH-1:0] num_location);
begin
		for(i=start_loc;i<start_loc+num_location;i=i+1) begin

		@(posedge clk_i);
		wr_rd_i <= 1;
		wdata_i <= i;
		addr_i  <= i;
		valid_i <= 1;
		wait(ready_o == 1); //handshaking completed// will wait till it is 1, if it will get 1 the stimulation will struck there
		reset();
		end
 end
endtask


// read task

task read(input reg [`ADDR_WIDTH-1:0] start_loc, input reg [`ADDR_WIDTH-1:0] num_location);
	begin
		for(i=start_loc;i<start_loc+num_location;i=i+1) begin
@(posedge clk_i);
		wr_rd_i <= 0;
		addr_i  <= i;
		valid_i <= 1;
		wait(ready_o == 1); //handshaking completed
		reset();
		end
	end
endtask

// input generation

initial begin
		clk_i = 0;
		rst_i = 1;
		reset();
		repeat(2) @(posedge clk_i);
		rst_i = 0;
	

		for(i=0;i<10;i=i+1) begin
			data_arr[i] = $random;
			$display("data_arr[%0d] = %0d",i,data_arr[i]);
		end
end		
initial begin
write(0,10);
      			$readmemh("write_bd.hex",dut.mem);// load hexadecimal values in the file write_bd,hex to mem array in design file
			$writememb("read_bd.bin",dut.mem);// it will write the contents in mem array in design file in binary format to read_bd.bin file
read(0,10);

		#100 $finish();	
	end
endmodule

//testcase1 Perform 10 write from location 20 ,29 
//testcase2 Perform write to location 31 to 40 with data present in data_array
//testcase3 Perform back write and read

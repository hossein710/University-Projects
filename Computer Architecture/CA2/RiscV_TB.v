// Soroush Nasiri 810803098
// Hossein Moradi 810803090

module RiscV_TB ();
    reg clk, rst;
    wire [31:0]Res;
    RiscV risc5(Res, clk, rst);
    initial begin

        #5 rst = 1;
        #20 rst = 0;
        #30 clk = 0;
        repeat (20000) #10 clk = ~clk;
    end
endmodule
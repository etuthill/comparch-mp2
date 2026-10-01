`timescale 1ns/1ps

module mp2_tb;

    logic clk;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;

    top uut (.clk(clk), .RGB_R(RGB_R), .RGB_G(RGB_G), .RGB_B(RGB_B));

    initial begin
        clk = 0;
        forever #41.667 clk = ~clk;
    end

    initial begin
        $dumpfile("mp2.vcd");
        $dumpvars(0, mp2_tb);

        #1000000000;
        $finish;
    end

endmodule
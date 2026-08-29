`timescale 1ns/1ps

module password_core_tb;

    reg clk;
    reg reset;
    reg bit_in;
    reg enter;

    wire unlocked;
    wire failed;

    password_core uut (
        .clk(clk),
        .reset(reset),
        .bit_in(bit_in),
        .enter(enter),
        .unlocked(unlocked),
        .failed(failed)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("password_core.vcd");
        $dumpvars(0, password_core_tb);

        $monitor(
            "Time=%0t bit=%b enter=%b count=%d password=%b unlocked=%b failed=%b",
            $time,
            bit_in,
            enter,
            uut.bit_count,
            uut.entered_password,
            unlocked,
            failed
        );

        clk = 0;
        reset = 1;
        bit_in = 0;
        enter = 0;

        #10;
        reset = 0;

        // WRONG PASSWORD: 1 0 0 1

        #8;
        bit_in = 1;
        enter = 1;

        #10;
        enter = 0;

        #10;
        bit_in = 0;
        enter = 1;

        #10;
        enter = 0;

        #10;
        bit_in = 0;
        enter = 1;

        #10;
        enter = 0;

        #10;
        bit_in = 1;
        enter = 1;

        #10;
        enter = 0;

        #20;

        $finish;

    end

endmodule
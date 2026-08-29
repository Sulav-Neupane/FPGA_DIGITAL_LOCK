`timescale 1ns/1ps

module attempt_counter_tb;

    reg clk;
    reg reset;
    reg failed;

    wire [1:0] attempts;
    wire locked_out;

    attempt_counter uut (
        .clk(clk),
        .reset(reset),
        .failed(failed),
        .attempts(attempts),
        .locked_out(locked_out)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("attempt_counter.vcd");
        $dumpvars(0, attempt_counter_tb);

        $monitor(
            "Time=%0t failed=%b attempts=%d locked_out=%b",
            $time,
            failed,
            attempts,
            locked_out
        );

        clk = 0;
        reset = 1;
        failed = 0;

        // Reset system
        #10;
        reset = 0;


        // FAILURE #1
        #8;
        failed = 1;

        #10;
        failed = 0;


        // FAILURE #2
        #10;
        failed = 1;

        #10;
        failed = 0;


        // FAILURE #3
        #10;
        failed = 1;

        #10;
        failed = 0;


        #20;

        $finish;

    end

endmodule   
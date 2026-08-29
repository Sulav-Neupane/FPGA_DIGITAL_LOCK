`timescale 1ns/1ps

module lockout_timer_tb;

    reg clk;
    reg reset;
    reg locked_out;

    wire timeout_done;
    wire [31:0] timer_count;


    lockout_timer #(
        .LOCKOUT_CYCLES(5)
    ) uut (
        .clk(clk),
        .reset(reset),
        .locked_out(locked_out),

        .timeout_done(timeout_done),
        .timer_count(timer_count)
    );


    always #5 clk = ~clk;


    initial begin

        $dumpfile("lockout_timer.vcd");
        $dumpvars(0, lockout_timer_tb);

        $monitor(
            "Time=%0t locked_out=%b timer=%0d timeout=%b",
            $time,
            locked_out,
            timer_count,
            timeout_done
        );


        clk = 0;
        reset = 1;
        locked_out = 0;


        // Reset
        #10;
        reset = 0;


        // Activate lockout
        #8;
        locked_out = 1;


        // Allow timer to run
        #60;


        // Simulate lockout being cleared
        locked_out = 0;


        #20;

        $finish;

    end

endmodule
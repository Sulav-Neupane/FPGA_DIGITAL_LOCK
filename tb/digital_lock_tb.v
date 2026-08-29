`timescale 1ns/1ps

module digital_lock_tb;

    reg clk;
    reg reset;
    reg bit_in;
    reg enter;

    wire unlocked;
    wire failed;
    wire [1:0] attempts;
    wire locked_out;


    digital_lock uut (
        .clk(clk),
        .reset(reset),
        .bit_in(bit_in),
        .enter(enter),

        .unlocked(unlocked),
        .failed(failed),
        .attempts(attempts),
        .locked_out(locked_out)
    );


    // 10 ns clock period
    always #5 clk = ~clk;


    // Submit one bit
    task submit_bit;
        input value;

        begin
            bit_in = value;
            enter = 1;

            #10;

            enter = 0;

            #10;
        end
    endtask


    // Submit a complete 4-bit password
    task submit_password;
        input [3:0] password;

        begin
            submit_bit(password[3]);
            submit_bit(password[2]);
            submit_bit(password[1]);
            submit_bit(password[0]);
        end
    endtask


    initial begin

        $dumpfile("digital_lock.vcd");
        $dumpvars(0, digital_lock_tb);

        $monitor(
            "Time=%0t enter=%b attempts=%d locked_out=%b timer=%0d timeout=%b unlocked=%b failed=%b",
            $time,
            enter,
            attempts,
            locked_out,
            uut.timer_count,
            uut.timeout_done,
            unlocked,
            failed
        );


        // Initial values
        clk = 0;
        reset = 1;
        bit_in = 0;
        enter = 0;


        // Reset system
        #10;
        reset = 0;


        // -------------------------
        // WRONG PASSWORD #1
        // -------------------------
        submit_password(4'b1001);

        #10;


        // -------------------------
        // WRONG PASSWORD #2
        // -------------------------
        submit_password(4'b1111);

        #10;


        // -------------------------
        // WRONG PASSWORD #3
        // -------------------------
        submit_password(4'b0000);

        // At this point:
        // attempts = 3
        // locked_out = 1


        // Wait long enough for the
        // lockout timer to expire
        #80;

        // Expected:
        // attempts = 0
        // locked_out = 0


        // -------------------------
        // CORRECT PASSWORD
        // after recovery
        // -------------------------
        submit_password(4'b1011);


        #30;

        $finish;

    end

endmodule
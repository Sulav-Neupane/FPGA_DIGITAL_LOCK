`timescale 1ns/1ps

module digital_lock_selfcheck_tb;

    reg clk;
    reg reset;
    reg relock;
    reg bit_in;
    reg enter;

    wire unlocked;
    wire failed;
    wire [1:0] attempts;
    wire locked_out;

    integer errors;


    digital_lock uut (
        .clk(clk),
        .reset(reset),
        .relock(relock),
        .bit_in(bit_in),
        .enter(enter),

        .unlocked(unlocked),
        .failed(failed),
        .attempts(attempts),
        .locked_out(locked_out)
    );


    // 10 ns clock period
    always #5 clk = ~clk;


    // -----------------------------------
    // Submit one password bit
    // -----------------------------------
    task submit_bit;
        input value;

        begin
            // Change inputs away from the rising edge
            @(negedge clk);

            bit_in = value;
            enter  = 1'b1;

            // enter stays high across one rising edge
            @(negedge clk);

            enter = 1'b0;
        end
    endtask


    // -----------------------------------
    // Submit complete 4-bit password
    // -----------------------------------
    task submit_password;
        input [3:0] password;

        begin
            submit_bit(password[3]);
            submit_bit(password[2]);
            submit_bit(password[1]);
            submit_bit(password[0]);
        end
    endtask


    // -----------------------------------
    // Automatic PASS / FAIL checker
    // -----------------------------------
    task check;
        input condition;
        input [8*80-1:0] message;

        begin
            if (condition) begin
                $display("PASS: %0s", message);
            end

            else begin
                $display("FAIL: %0s", message);
                errors = errors + 1;
            end
        end
    endtask


    initial begin

        $dumpfile("digital_lock_selfcheck.vcd");
        $dumpvars(0, digital_lock_selfcheck_tb);

        errors = 0;

        clk    = 0;
        reset  = 1;
        relock = 0;
        bit_in = 0;
        enter  = 0;


        // ===================================
        // TEST 1: RESET
        // ===================================

        repeat (2) @(posedge clk);

        reset = 0;

        @(posedge clk);
        #1;

        check(
            attempts == 2'd0 &&
            locked_out == 1'b0 &&
            unlocked == 1'b0,
            "Reset initializes digital lock"
        );


        // ===================================
        // TEST 2: WRONG PASSWORD #1
        // ===================================

        submit_password(4'b1001);

        // attempt_counter sees the failed pulse
        // on the following clock edge
        @(posedge clk);
        #1;

        check(
            attempts == 2'd1,
            "First wrong password increments attempts to 1"
        );

        check(
            unlocked == 1'b0,
            "Wrong password does not unlock system"
        );


        // ===================================
        // TEST 3: WRONG PASSWORD #2
        // ===================================

        submit_password(4'b1111);

        @(posedge clk);
        #1;

        check(
            attempts == 2'd2,
            "Second wrong password increments attempts to 2"
        );


        // ===================================
        // TEST 4: WRONG PASSWORD #3
        // ===================================

        submit_password(4'b0000);

        @(posedge clk);
        #1;

        check(
            attempts == 2'd3,
            "Third wrong password increments attempts to 3"
        );

        check(
            locked_out == 1'b1,
            "Third wrong password activates lockout"
        );


        // ===================================
        // TEST 5: INPUT BLOCKED DURING LOCKOUT
        // ===================================

            // Try submitting one bit while lockout is active
            @(negedge clk);
            bit_in = 1'b1;
            enter  = 1'b1;

            @(posedge clk);
            #1;

            // Password core should not receive the entry
                check(
                    uut.password_unit.bit_count == 3'd0,
                "   Password input is blocked during lockout"
                    );

                check(
                    unlocked == 1'b0,
                    "System remains locked during lockout"
                        );

                    @(negedge clk);
                    enter = 1'b0;

        // ===================================
        // TEST 6: AUTOMATIC TIMEOUT RECOVERY
        // ===================================

        wait (locked_out == 1'b0);
        @(posedge clk);
        #1;

        check(
            locked_out == 1'b0,
            "Lockout clears after timeout"
        );

        check(
            attempts == 2'd0,
            "Attempt counter resets after timeout"
        );


        // ===================================
        // TEST 7: CORRECT PASSWORD
        // ===================================

        submit_password(4'b1011);

        #1;

        check(
            unlocked == 1'b1,
            "Correct password unlocks system"
        );

                    // ===================================
            // TEST 8: MANUAL RELOCK
                // ===================================

            // Assert relock away from rising edge
            @(negedge clk);
            relock = 1'b1;

            // Allow one rising edge to capture relock
            @(posedge clk);
            #1;

                check(
                    unlocked == 1'b0,
                    "Manual relock returns system to locked state"
                    );

                check(
                uut.password_unit.bit_count == 3'd0,
                "Manual relock clears password entry progress"
                );


                        // Release relock
                        @(negedge clk);
                        relock = 1'b0;

// ===================================
// TEST 9: LOGIN AFTER RELOCK
// ===================================

            submit_password(4'b1011);

            #1;

            check(
            unlocked == 1'b1,
            "Correct password works again after manual relock"
            );
        // ===================================
        // FINAL RESULT
        // ===================================

        if (errors == 0) begin
            $display("");
            $display("==============================");
            $display("       ALL TESTS PASSED"       );
            $display("==============================");
        end

        else begin
            $display("");
            $display("==============================");
            $display("TESTS FAILED: %0d error(s)", errors);
            $display("==============================");
        end

        #10;
        $finish;

    end

endmodule
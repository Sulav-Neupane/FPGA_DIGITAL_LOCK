module digital_lock (
    input wire clk,
    input wire reset,
    input wire bit_in,
    input wire enter,

    output wire unlocked,
    output wire failed,
    output wire [1:0] attempts,
    output wire locked_out
);

    wire core_unlocked;
    wire core_failed;

    wire gated_enter;

    wire timeout_done;
    wire [31:0] timer_count;


    // Disable password input during lockout
    assign gated_enter = enter & ~locked_out;


    // Password authentication
    password_core password_unit (
        .clk(clk),
        .reset(reset),
        .bit_in(bit_in),
        .enter(gated_enter),

        .unlocked(core_unlocked),
        .failed(core_failed)
    );


    // Failed-attempt counter
    attempt_counter attempt_unit (
        .clk(clk),
        .reset(reset),
        .failed(core_failed),
        .clear_lockout(timeout_done),

        .attempts(attempts),
        .locked_out(locked_out)
    );


    // Lockout timer
    lockout_timer #(
        .LOCKOUT_CYCLES(5)
    ) timer_unit (
        .clk(clk),
        .reset(reset),
        .locked_out(locked_out),

        .timeout_done(timeout_done),
        .timer_count(timer_count)
    );


    assign unlocked = core_unlocked & ~locked_out;
    assign failed   = core_failed;

endmodule
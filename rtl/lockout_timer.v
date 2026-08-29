module lockout_timer #(
    parameter integer LOCKOUT_CYCLES = 5
)(
    input wire clk,
    input wire reset,
    input wire locked_out,

    output wire timeout_done,
    output reg [31:0] timer_count
);

    // Timeout becomes active when the required
    // number of lockout cycles has elapsed.
    assign timeout_done =
        locked_out &&
        (timer_count == LOCKOUT_CYCLES - 1);


    always @(posedge clk) begin

        if (reset) begin
            timer_count <= 32'd0;
        end

        else if (!locked_out) begin
            timer_count <= 32'd0;
        end

        else if (timeout_done) begin
            timer_count <= 32'd0;
        end

        else begin
            timer_count <= timer_count + 1'b1;
        end

    end

endmodule
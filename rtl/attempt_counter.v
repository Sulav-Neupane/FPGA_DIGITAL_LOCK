module attempt_counter (
    input wire clk,
    input wire reset,
    input wire failed,
    input wire clear_lockout,

    output reg [1:0] attempts,
    output reg locked_out
);

    always @(posedge clk) begin

        if (reset) begin
            attempts   <= 2'd0;
            locked_out <= 1'b0;
        end

        else if (clear_lockout) begin
            attempts   <= 2'd0;
            locked_out <= 1'b0;
        end

        else if (failed && !locked_out) begin

            if (attempts == 2'd2) begin
                attempts   <= 2'd3;
                locked_out <= 1'b1;
            end

            else begin
                attempts <= attempts + 1'b1;
            end

        end

    end

endmodule
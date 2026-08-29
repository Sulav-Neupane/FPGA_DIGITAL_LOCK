module password_core (
    input wire clk,
    input wire reset,
    input wire bit_in,
    input wire enter,

    output reg unlocked,
    output reg failed
);

    parameter PASSWORD = 4'b1011;

    reg [3:0] entered_password;
    reg [2:0] bit_count;

    always @(posedge clk) begin

        if (reset) begin
            entered_password <= 4'b0000;
            bit_count <= 3'd0;
            unlocked <= 1'b0;
            failed <= 1'b0;
        end

        else begin

            // failed should normally stay low
            failed <= 1'b0;

            if (enter && !unlocked) begin

                entered_password <= {
                    entered_password[2:0],
                    bit_in
                };

                if (bit_count == 3) begin

                    if ({
                        entered_password[2:0],
                        bit_in
                    } == PASSWORD) begin

                        unlocked <= 1'b1;

                    end

                    else begin

                        failed <= 1'b1;
                        entered_password <= 4'b0000;

                    end

                    bit_count <= 3'd0;

                end

                else begin
                    bit_count <= bit_count + 1'b1;
                end

            end

        end

    end

endmodule
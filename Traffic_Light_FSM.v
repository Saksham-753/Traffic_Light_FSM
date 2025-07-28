module TrafficLightController (
    input clk,
    input reset,
    input sensor,
    output reg HG, HY, HR,
    output reg SG, SR
);

    // State encoding
    typedef enum reg [1:0] {
        S0 = 2'b00, // Highway Green
        S1 = 2'b01, // Highway Yellow
        S2 = 2'b10  // Highway Red
    } state_t;

    state_t current_state, next_state;

    // Timer counter for state duration
    reg [3:0] timer;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S0;
            timer <= 0;
        end else begin
            if (timer == 4'd9) begin // 10 clock cycles per state
                current_state <= next_state;
                timer <= 0;
            end else begin
                timer <= timer + 1;
            end
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            S0: next_state = (sensor) ? S1 : S0;
            S1: next_state = S2;
            S2: next_state = S0;
            default: next_state = S0;
        endcase
    end

    // Output logic
    always @(*) begin
        // Default all off
        HG = 0; HY = 0; HR = 0;
        SG = 0; SR = 0;

        case (current_state)
            S0: begin
                HG = 1; HR = 0; HY = 0;
                SR = 1; SG = 0;
            end
            S1: begin
                HY = 1; HR = 0; HG = 0;
                SR = 1; SG = 0;
            end
            S2: begin
                HR = 1; HG = 0; HY = 0;
                SG = 1; SR = 0;
            end
        endcase
    end

endmodule
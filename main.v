module car_parking_system
   (
    input clk, reset, car_enter, car_leave,
    output reg [3:0] available_slots,
    output reg parking_full, spot_allocated
);

    // Parameters
    parameter NUM_SPOTS = 4; // Assuming 4 parking spots

    // States for FSM
    parameter IDLE = 2'b00, ALLOCATING = 2'b01, FULL = 2'b10;
    reg [1:0] current_state, next_state;

    reg [3:0] spots; // 1 means the spot is taken, 0 means it's free
    reg [3:0] free_spot; // Indicate which spot is free when allocating

    // FSM logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            spots <= 4'b0000; // Initialize spots on reset
        end else begin
            current_state <= next_state;
        end
    end

     // Next state logic and spot allocation
    always @(*) begin
        spot_allocated = 0;
        free_spot = 4'b0000;

        case (current_state)
            IDLE: begin
                if (car_enter && spots != 4'b1111) // if car enters and spots are available
                    next_state = ALLOCATING;
                else if (spots == 4'b1111) // if all spots are taken
                    next_state = FULL;
                else
                    next_state = IDLE;
            end
             ALLOCATING: begin
    if (spots[0] == 0) {
        free_spot = 4'b0001;
    } else if (spots[1] == 0) {
        free_spot = 4'b0010;
    } else if (spots[2] == 0) {
        free_spot = 4'b0100;
    } else if (spots[3] == 0) {
        free_spot = 4'b1000;
    }
    spot_allocated = 1;
    next_state = IDLE;
end
  FULL: begin
                if (car_leave) // if a car leaves
                    next_state = IDLE;
                else
                    next_state = FULL;
            end

            default: next_state = IDLE;
        endcase
    end

    // Update spots based on allocation and cars leaving
    always @(posedge clk) begin
        if (spot_allocated) begin
            spots = spots | free_spot;
        end
        if (car_leave) begin
            spots = spots & (~free_spot); // Free the spot that's left
        end
    end

    // Calculate available slots
    always @(*) begin
        available_slots = NUM_SPOTS - $countones(spots);
    end

    assign parking_full = (available_slots == 0) ? 1'b1 : 1'b0;

endmodule

`timescale 1ns/1ps

module car_parking_system_tb;

    // Clock parameters
    parameter CLK_PERIOD = 20; // 50 MHz clock

    reg clk, reset, car_enter, car_leave;
    wire [3:0] available_slots;
    wire parking_full, spot_allocated;

    // Instantiate the car parking system
    car_parking_system uut (
        .clk(clk),
        .reset(reset),
        .car_enter(car_enter),
        .car_leave(car_leave),
        .available_slots(available_slots),
        .parking_full(parking_full),
        .spot_allocated(spot_allocated)
    );

    // Clock generation
    always begin
        # (CLK_PERIOD/2) clk = ~clk;
    end

    // Test scenarios
    initial begin
        // Initialize signals
        clk = 0;
        reset = 0; // Initially in reset
        car_enter = 0;
        car_leave = 0;

        // Apply reset
        # CLK_PERIOD reset = 1; // Release reset
        # (5 * CLK_PERIOD);

        // Scenario: Single car enters
        car_enter = 1;
        # CLK_PERIOD car_enter = 0;
        # (2 * CLK_PERIOD);

        // Scenario: Another car enters
        car_enter = 1;
        # CLK_PERIOD car_enter = 0;
        # (2 * CLK_PERIOD);

        // Scenario: First car leaves
        car_leave = 1;
        # CLK_PERIOD car_leave = 0;
        # (2 * CLK_PERIOD);

        // Scenario: Multiple cars enter till parking is full
        repeat (3) begin
            car_enter = 1;
            # CLK_PERIOD car_enter = 0;
            # (2 * CLK_PERIOD);
        end

        // Scenario: One car leaves
        car_leave = 1;
        # CLK_PERIOD car_leave = 0;
        # (2 * CLK_PERIOD);

        // Scenario: All cars leave
        repeat (4) begin // Adjusted to consider 4 cars might be parked.
            car_leave = 1;
            # CLK_PERIOD car_leave = 0;
            # (2 * CLK_PERIOD);
        end

        $finish;
    end

endmodule

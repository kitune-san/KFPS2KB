//
// KFPS2KB
// SIMPLE KEYBOARD CONTROLLER
//
// Written by kitune-san
//
module KFPS2KB (
    input   logic           clock,
    input   logic           reset,

    input   logic           device_clock,
    input   logic           device_data,

    output  logic           irq,
    output  logic   [7:0]   keycode,
    input   logic           clear_keycode
);
    //
    // Internal Signals
    //
    logic   [7:0]   register;
    logic           recieved_flag;
    logic           error_flag;
    logic           break_flag;


    //
    // Shift register
    //
    KFPS2KB_Shift_Register u_Shift_Register (
        .clock          (clock),
        .reset          (reset),

        .device_clock   (device_clock),
        .device_data    (device_data),

        .register       (register),
        .recieved_flag  (recieved_flag),
        .error_flag     (error_flag)
    );


    //
    // Make keycode
    //
    always_ff @(negedge clock, posedge reset) begin
        if (reset) begin
            irq         <= 1'b0;
            break_flag  <= 1'b0;
            keycode     <= 8'h00;
        end
        else if (clear_keycode) begin
            irq         <= 1'b0;
            break_flag  <= 1'b0;
            keycode     <= 8'h00;
        end
        else if (error_flag) begin
            // Error
            irq         <= 1'b1;
            break_flag  <= 1'b0;
            keycode     <= 8'hFF;
        end
        else if (recieved_flag) begin
            if (irq == 1'b1) begin
                // Error
                irq         <= 1'b1;
                break_flag  <= 1'b0;
                keycode     <= 8'hFF;
            end
            else if (register == 8'hF0) begin
                // Set break flag
                irq         <= 1'b0;
                break_flag  <= 1'b1;
                keycode     <= keycode;
            end
            else if (break_flag == 1'b1) begin
                // Break code
                irq         <= 1'b1;
                break_flag  <= 1'b0;
                keycode     <= {1'b1, register[6:0]};
            end
            else begin
                // Make code
                irq         <= 1'b1;
                break_flag  <= 1'b0;
                keycode     <= register[7:0];
            end
        end
        else begin
            irq         <= irq;
            break_flag  <= break_flag;
            keycode     <= keycode;
        end
    end

endmodule

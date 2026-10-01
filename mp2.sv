module top( 
    input logic     clk,
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
); 
    parameter PWM_INTERVAL = 1200; // resolution
    parameter FADE_INTERVAL = 10000; // brightness ticks
    parameter FADE_MAX = 200; // full color change time
    parameter FADE_STEP = PWM_INTERVAL / FADE_MAX; //brightness units
    logic [$clog2(FADE_INTERVAL)-1:0] timer = 0; // needed bits
    logic [$clog2(PWM_INTERVAL)-1:0] bright_step = 0; // brightness during transition
    logic [2:0] color_state = 0; // state
    logic [$clog2(PWM_INTERVAL)-1:0] pwm_count = 0; // pwm
    logic [$clog2(PWM_INTERVAL)-1:0] bright_R, bright_G, bright_B; // target brightness

    always_ff @(posedge clk) begin
        if (pwm_count == PWM_INTERVAL - 1)
            pwm_count <= 0;
        else
            pwm_count <= pwm_count + 1;

        if (timer == FADE_INTERVAL - 1) begin // change brightness
            timer <= 0;
            if (bright_step == PWM_INTERVAL - FADE_STEP) begin
                bright_step <= 0;
                if (color_state == 5) // state loop
                    color_state <= 0;
                else
                    color_state <= color_state + 1;
            end else begin
                bright_step <= bright_step + FADE_STEP;
            end
        end else begin
            timer <= timer + 1;
        end
    end

    always_comb begin
        bright_R = 0;
        bright_G = 0;
        bright_B = 0;
        case (color_state)
            0: begin // R to Y
                bright_R = PWM_INTERVAL;
                bright_G = bright_step;
                bright_B = 0;
            end
            1: begin // Y to G
                bright_R = PWM_INTERVAL - bright_step;
                bright_G = PWM_INTERVAL;
                bright_B = 0;
            end
            2: begin // G to C
                bright_R = 0;
                bright_G = PWM_INTERVAL;
                bright_B = bright_step;
            end
            3: begin // C to B
                bright_R = 0;
                bright_G = PWM_INTERVAL - bright_step;
                bright_B = PWM_INTERVAL;
            end
            4: begin // B to M
                bright_R = bright_step;
                bright_G = 0;
                bright_B = PWM_INTERVAL;
            end
            5: begin // M to R
                bright_R = PWM_INTERVAL;
                bright_G = 0;
                bright_B = PWM_INTERVAL - bright_step;
            end
            default: begin
                bright_R = 0;
                bright_G = 0;
                bright_B = 0;
            end
        endcase
        // PWM
        RGB_R = (pwm_count < bright_R) ? 1'b0 : 1'b1;
        RGB_G = (pwm_count < bright_G) ? 1'b0 : 1'b1;
        RGB_B = (pwm_count < bright_B) ? 1'b0 : 1'b1;
    end
endmodule
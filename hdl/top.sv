`timescale 1ns / 1ps

module top(
    input  logic       clk,
    input  logic       reset,
    input  logic       key_valid,     // K
    input  logic [1:0] pin_in,        // Bus {IN1, IN0}
    output logic       led_puerta,    // SOLENOID
    output logic       led_alarma,    // ALARM
    output logic       led_estado_1,  // LED1
    output logic       led_estado_0   // LED0
);

    // Señales de interconexión interna entre FSMs
    logic match_pulse;
    logic err_pulse;
    logic timer_en;
    logic timer_done;
    
    // Buses de depuración de estados
    logic [1:0] mealy_state;
    logic [2:0] moore_state;

    // Contador de 4 bits para el módulo temporizador (Timer_Module)
    logic [3:0] timer_count;

    // 1. Instancia del Subproceso 1: FSM Mealy (Validador)
    mealy u_mealy (
        .clk         (clk),
        .reset       (reset),
        .k           (key_valid),
        .in          (pin_in),
        .match_pulse (match_pulse),
        .err_pulse   (err_pulse),
        .q_state     (mealy_state)
    );

    // 2. Instancia del Subproceso 2: FSM Moore (Seguridad)
    moore u_moore (
        .clk         (clk),
        .reset       (reset),
        .m           (match_pulse),
        .r           (err_pulse),
        .t           (timer_done),
        .solenoid    (led_puerta),
        .alarm       (led_alarma),
        .timer_en    (timer_en),
        .led1        (led_estado_1),
        .led0        (led_estado_0),
        .q_state     (moore_state)
    );

    // 3. Temporizador síncrono (reproduce el Timer_Module de Logisim)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            timer_count <= 4'b0000;
        end else begin
            if (!timer_en) begin
                timer_count <= 4'b0000;
            end else begin
                if (timer_count < 4'd6)
                    timer_count <= timer_count + 1'b1;
                else
                    timer_count <= 4'd6; // Se sostiene en 6
            end
        end
    end

    // Detección de cuenta alcanzada (6 ciclos = 0110_2)
    assign timer_done = (timer_count == 4'd6);

endmodule
`timescale 1ns / 1ps

module moore(
    input  logic clk,
    input  logic reset,
    input  logic m,           // MATCH_PULSE desde Mealy
    input  logic r,           // ERR_PULSE desde Mealy
    input  logic t,           // TIMER_DONE desde Temporizador
    output logic solenoid,    // Apertura cerradura
    output logic alarm,       // Sirena de intrusión
    output logic timer_en,    // Habilitador de cuenta del timer
    output logic led1,        // LED amarillo (alerta) / bit 1
    output logic led0,        // LED verde/azul (desbloqueo) / bit 0
    output logic [2:0] q_state// Estado actual (depuración)
);

    // 1. Definición de tipos de estado (Enum de 3 bits)
    typedef enum logic [2:0] {
        LOCKED_0 = 3'b000,   // Bloqueado, 0 fallos
        LOCKED_1 = 3'b001,   // Bloqueado, 1 fallo
        LOCKED_2 = 3'b010,   // Bloqueado, 2 fallos (alerta)
        UNLOCKED = 3'b011,   // Puerta abierta (solenoide activo)
        ALARM    = 3'b100    // Intrusión (3 fallos, sirena activa)
    } statetype;

    statetype state, nextstate;

    // Variables de salida intermedias (pre-stage)
    logic sol_pre, alm_pre, ten_pre, l1_pre, l0_pre;

    // 2. Registro de estado síncrono con reset asíncrono (D_FF)
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= LOCKED_0;
        else
            state <= nextstate;
    end

    // 3. Lógica de estado siguiente combinacional
    always_comb begin
        case (state)
            LOCKED_0: begin
                if (m)      nextstate = UNLOCKED;
                else if (r) nextstate = LOCKED_1;
                else        nextstate = LOCKED_0;
            end
            LOCKED_1: begin
                if (m)      nextstate = UNLOCKED;
                else if (r) nextstate = LOCKED_2;
                else        nextstate = LOCKED_1;
            end
            LOCKED_2: begin
                if (m)      nextstate = UNLOCKED;
                else if (r) nextstate = ALARM;
                else        nextstate = LOCKED_2;
            end
            UNLOCKED: begin
                if (t)      nextstate = LOCKED_0;
                else        nextstate = UNLOCKED;
            end
            ALARM: begin
                if (t)      nextstate = LOCKED_0;
                else        nextstate = ALARM;
            end
            default: nextstate = LOCKED_0;
        endcase
    end

    // 4. Lógica de salida Moore (pre-stage: depende ÚNICAMENTE del estado)
    always_comb begin
        case (state)
            LOCKED_0: begin
                sol_pre = 1'b0; alm_pre = 1'b0; ten_pre = 1'b0; l1_pre = 1'b0; l0_pre = 1'b0;
            end
            LOCKED_1: begin
                sol_pre = 1'b0; alm_pre = 1'b0; ten_pre = 1'b0; l1_pre = 1'b0; l0_pre = 1'b0;
            end
            LOCKED_2: begin
                sol_pre = 1'b0; alm_pre = 1'b0; ten_pre = 1'b0; l1_pre = 1'b1; l0_pre = 1'b0;
            end
            UNLOCKED: begin
                sol_pre = 1'b1; alm_pre = 1'b0; ten_pre = 1'b1; l1_pre = 1'b0; l0_pre = 1'b1;
            end
            ALARM: begin
                sol_pre = 1'b0; alm_pre = 1'b1; ten_pre = 1'b1; l1_pre = 1'b1; l0_pre = 1'b1;
            end
            default: begin
                sol_pre = 1'b0; alm_pre = 1'b0; ten_pre = 1'b0; l1_pre = 1'b0; l0_pre = 1'b0;
            end
        endcase
    end

    // 5. Asignación de salidas Moore
    assign solenoid = sol_pre;
    assign alarm    = alm_pre;
    assign timer_en = ten_pre;
    assign led1     = l1_pre;
    assign led0     = l0_pre;
    assign q_state  = state;

endmodule
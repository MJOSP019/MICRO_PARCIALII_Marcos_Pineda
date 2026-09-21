`timescale 1ns / 1ps

module mealy(
    input  logic       clk,
    input  logic       reset,
    input  logic       k,          // KEY_VALID
    input  logic [1:0] in,         // Dígito ingresado {IN1, IN0}
    output logic       match_pulse,// Salida Mealy: clave completada
    output logic       err_pulse,  // Salida Mealy: dígito erróneo
    output logic [1:0] q_state     // Estado actual (depuración)
);

    // 1. Definición de tipos de estado (Enum de 2 bits)
    typedef enum logic [1:0] {
        S0 = 2'b00,   // Espera Dígito 1 (01)
        S1 = 2'b01,   // Espera Dígito 2 (10)
        S2 = 2'b10    // Espera Dígito 3 (11)
    } statetype;
    
    statetype state, nextstate;

    // Variables internas de salida (pre-stage)
    logic match_pre, err_pre;
    logic e; // Señal EQUAL del comparador dinámico

    // 2. Comparador de dígito esperado según el estado actual
    always_comb begin
        case (state)
            S0:      e = (in == 2'b01);
            S1:      e = (in == 2'b10);
            S2:      e = (in == 2'b11);
            default: e = 1'b0;
        endcase
    end

    // 3. Registro de estado síncrono con reset asíncrono (D_FF)
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0;
        else
            state <= nextstate;
    end

    // 4. Lógica de estado siguiente combinacional
    always_comb begin
        case (state)
            S0: begin
                if (k && e)       nextstate = S1;
                else if (k && !e) nextstate = S0;
                else              nextstate = S0;
            end
            S1: begin
                if (k && e)       nextstate = S2;
                else if (k && !e) nextstate = S0;
                else              nextstate = S1;
            end
            S2: begin
                if (k && e)       nextstate = S0;
                else if (k && !e) nextstate = S0;
                else              nextstate = S2;
            end
            default: nextstate = S0;
        endcase
    end

    // 5. Lógica de salida Mealy (pre-stage: depende de estado y entradas K, E)
    always_comb begin
        match_pre = 1'b0;
        err_pre   = 1'b0;
        case (state)
            S0: begin
                if (k && !e) err_pre = 1'b1;
            end
            S1: begin
                if (k && !e) err_pre = 1'b1;
            end
            S2: begin
                if (k && e)       match_pre = 1'b1;
                else if (k && !e) err_pre   = 1'b1;
            end
            default: begin
                match_pre = 1'b0;
                err_pre   = 1'b0;
            end
        endcase
    end

    // 6. Asignación de salidas
    assign match_pulse = match_pre;
    assign err_pulse   = err_pre;
    assign q_state     = state;

endmodule
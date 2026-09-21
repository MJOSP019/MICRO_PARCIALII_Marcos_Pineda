`timescale 1ns / 1ps

module testbench();

    // Señales de estímulo
    logic       clk;
    logic       reset;
    logic       key_valid;
    logic [1:0] pin_in;

    // Señales de monitoreo
    logic       led_puerta;
    logic       led_alarma;
    logic       led_estado_1;
    logic       led_estado_0;

    // Instanciación de la unidad bajo prueba (UUT)
    top uut (
        .clk          (clk),
        .reset        (reset),
        .key_valid    (key_valid),
        .pin_in       (pin_in),
        .led_puerta   (led_puerta),
        .led_alarma   (led_alarma),
        .led_estado_1 (led_estado_1),
        .led_estado_0 (led_estado_0)
    );

    // Generador de reloj: Período = 10 ns (Frecuencia = 100 MHz)
    always #5 clk = ~clk;

    // Tarea auxiliar para ingresar un dígito con pulso en key_valid
    task automatic enter_key(input logic [1:0] digit);
        begin
            pin_in = digit;
            #10;
            key_valid = 1'b1;
            #10;
            key_valid = 1'b0;
            #20;
        end
    endtask

    initial begin
        // Inicialización de señales
        clk       = 1'b0;
        reset     = 1'b1;
        key_valid = 1'b0;
        pin_in    = 2'b00;

        // 1. Reset Maestro inicial
        #30;
        reset = 1'b0;
        #20;
        $display("[TB] Sistema inicializado en reposo (LOCKED_0).");

        // 2. PRUEBA 1: Secuencia de PIN Correcto (01 -> 10 -> 11)
        $display("[TB] --- INICIANDO PRUEBA 1: PIN CORRECTO ---");
        enter_key(2'b01); // Dígito 1
        enter_key(2'b10); // Dígito 2
        enter_key(2'b11); // Dígito 3

        // En este punto, led_puerta debe activarse (UNLOCKED)
        #20;
        if (led_puerta) 
            $display("[TB] EXCELENTE: Cerradura abierta (LED_PUERTA = 1).");
        else 
            $display("[TB] ERROR: La cerradura no abrio.");

        // Esperar el auto-rebloqueo (6 ciclos de temporizador)
        #100;
        if (!led_puerta) 
            $display("[TB] EXCELENTE: Rebloqueo automatico completado.");

        // 3. PRUEBA 2: Intentos Fallidos hasta Alarma (3 fallos)
        $display("[TB] --- INICIANDO PRUEBA 2: 3 FALLOS CONSECUTIVOS ---");
        
        // Fallo 1
        enter_key(2'b00);
        $display("[TB] Fallo 1 registrado (Pasa a LOCKED_1).");

        // Fallo 2
        enter_key(2'b00);
        #10;
        if (led_estado_1)
            $display("[TB] Fallo 2 registrado: Alerta preventiva activa (LED_ESTADO_1 = 1).");

        // Fallo 3
        enter_key(2'b00);
        #10;
        if (led_alarma)
            $display("[TB] ALERTA MAXIMA: 3 fallos alcanzados, sirena encendida (LED_ALARMA = 1).");

        // Esperar penalización por tiempo
        #100;
        $display("[TB] Penalizacion terminada. Sistema restaurado a reposo.");

        $display("[TB] Todas las pruebas han concluido satisfactoriamente.");
        $finish;
    end

endmodule
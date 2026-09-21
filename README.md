# Parcial 2: Análisis de Timing, Migración a SystemVerilog y Flujo en Vivado

**Estudiante:** Marcos Josué Pineda Urbina  
**Asignatura:** Arquitectura de Computadoras y Microcontroladores 1  
**FPGA Objetivo:** AMD / Xilinx Artix-7 (xc7a35tcpg236-1)  

---

## 1. Estructura del Repositorio

* `hdl/`: Módulos en SystemVerilog (`top.sv`, `mealy.sv`, `moore.sv`) y banco de pruebas (`testbench.sv`).
* `timing_analysis/`: Análisis matemático de retardo combinacional, $f_{\max}$ y restricciones de Setup/Hold con compuertas 74HC.
* `vivado_evidence/`: Capturas de RTL Elaborated Design, Síntesis, Implementación física (Device) y formas de onda de simulación.

---

## 2. Análisis de Timing FF a FF (Mealy → Moore)

* **Ruta síncrona:** Salida Q1 de `FF_1` (Mealy) → `AND_MATCH` (74HC21) → Entrada M → AND 3-in (74HC11) → Árbol OR (74HC32) → Entrada D1 de `FF_1` (Moore).
* **Parámetros de componentes (74HC a 4.5 V, 25 °C):**
  * $t_{pcq} = 35\text{ ns}$ (Flip-Flop Mealy)
  * $t_{pd,\text{comb}} = 22\text{ ns} + 20\text{ ns} + (3 \times 20\text{ ns}) = 102\text{ ns}$
  * $t_{\text{setup}} = 20\text{ ns}$, $t_{\text{hold}} = 0\text{ ns}$ (Flip-Flop Moore)
* **Restricción de Setup:** $T_c \ge 35\text{ ns} + 102\text{ ns} + 20\text{ ns} = 157\text{ ns} \longrightarrow f_{\max} = 6.37\text{ MHz}$.
* **Restricción de Hold:** $t_{ccq} + t_{cd,\text{comb}} > 0\text{ ns} \ge t_{\text{hold}} = 0\text{ ns}$ (Cumple con margen positivo).

---

## 3. Discusión de Etapas en Vivado

1. **RTL Analysis:** Elabora la red lógica genérica independiente de la tecnología (`RTL_REG_ASYNC`, multiplexores, sumadores y decodificación de estados).
2. **Synthesis:** Mapea la lógica booleana a Look-Up Tables (**LUT6**) y Flip-Flops dedicados (**FDRE/FDCE**). Consumo: 1% LUT, 1% FF.
3. **Implementation:** Ubica físicamente las celdas en los Bloques Lógicos Configurables (**CLBs**) en el cuadrante `X0Y0` y rutea las pistas metálicas considerando los retardos parásitos reales.

---

## 4. Enlaces a Videos Explicativos (YouTube)

* **Inciso 1 (Análisis de Timing FF a FF):** [Pegar enlace de YouTube aquí]
* **Inciso 2 (HDL SystemVerilog y Simulación):** [Pegar enlace de YouTube aquí]
* **Inciso 3 (Flujo de Compilación en Vivado):** [Pegar enlace de YouTube aquí]

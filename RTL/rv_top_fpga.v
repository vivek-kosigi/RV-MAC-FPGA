// =========================================================
// rv_top_fpga.v  - FPGA wrapper for rv_top_all (Type-3 ready)
// =========================================================
`timescale 1ns/1ps

module rv_top_fpga (
    input  wire       clk,
    input  wire       rst_n,
    output wire [2:0] led,
    output wire       lcd_rs,
    output wire       lcd_e,
    output wire [7:0] data
);

    // internal debug wires (kept for probe)
    wire [31:0] if_reg_w, id_reg_w, ex_reg_w, mem_reg_w, wb_reg_w;
    wire [31:0] alu_out_w, mac_out_w, perc_out_w;
    wire [2:0]  alu_op_w;
    wire [31:0] mac10_w, perc10_w;

    rv_top_all u_core (
        .clk        (clk),
        .rst_n      (rst_n),
        .led        (led),
        .lcd_rs     (lcd_rs),
        .lcd_e      (lcd_e),
        .data       (data),

        .if_reg_out (if_reg_w),
        .id_reg_out (id_reg_w),
        .ex_reg_out (ex_reg_w),
        .mem_reg_out(mem_reg_w),
        .wb_reg_out (wb_reg_w),
        .alu_out_dbg(alu_out_w),
        .mac_dbg    (mac_out_w),
        .perc_dbg   (perc_out_w),
        .alu_op_dbg (alu_op_w),
        .mac10_dbg  (mac10_w),
        .perc10_dbg (perc10_w)
    );

endmodule

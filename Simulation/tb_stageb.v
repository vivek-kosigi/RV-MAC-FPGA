`timescale 1ns/1ps

module tb_stageb;

    reg clk;
    reg rst_n;

    wire [2:0]  led;
    wire        lcd_rs;
    wire        lcd_e;
    wire [7:0]  data;

    // debug outputs from core
    wire [31:0] IF_dbg, ID_dbg, EX_dbg, MEM_dbg, WB_dbg;
    wire [31:0] alu_out_dbg, mac_dbg, perc_dbg;
    wire [2:0]  alu_op_dbg;
    wire [31:0] mac10_dbg, perc10_dbg;

    integer cycle = 0;
    reg [39*8-1:0] op_str;

    // Local pipeline-shift registers (to mimic IF/ID/EX/MEM/WB for numeric columns if needed)
    reg [31:0] IF_p, ID_p, EX_p, MEM_p, WB_p;

    // DUT
    rv_top_all dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .led        (led),
        .lcd_rs     (lcd_rs),
        .lcd_e      (lcd_e),
        .data       (data),

        .if_reg_out (IF_dbg),
        .id_reg_out (ID_dbg),
        .ex_reg_out (EX_dbg),
        .mem_reg_out(MEM_dbg),
        .wb_reg_out (WB_dbg),

        .alu_out_dbg(alu_out_dbg),
        .mac_dbg    (mac_dbg),
        .perc_dbg   (perc_dbg),
        .alu_op_dbg (alu_op_dbg),

        .mac10_dbg  (mac10_dbg),
        .perc10_dbg (perc10_dbg)
    );

    // clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // reset
    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
    end

    initial begin
        IF_p  = 32'd0;
        ID_p  = 32'd0;
        EX_p  = 32'd0;
        MEM_p = 32'd0;
        WB_p  = 32'd0;
    end

    // Helper: decode EX_dbg instruction into printable op string
    // EX_dbg is the 32-bit instruction word sitting in the EX pipeline stage
    always @(*) begin
        // default
        op_str = "UNK         ";
        // Look at opcode (bits [6:0]) and funct fields
        case (EX_dbg[6:0])
            7'b0110011: begin // R-type (ADD,SUB,AND,OR,XOR,MUL)
                if (EX_dbg[31:25] == 7'b0000001 && EX_dbg[14:12] == 3'b000) op_str = "MUL (a * b)";
                else begin
                    case (EX_dbg[14:12]) // funct3
                        3'b000: begin
                            if (EX_dbg[31:25] == 7'b0100000) op_str = "SUB (a - b)";
                            else op_str = "ADD (a + b)";
                        end
                        3'b111: op_str = "AND (a & b)";
                        3'b110: op_str = "OR  (a | b)";
                        3'b100: op_str = "XOR (a ^ b)";
                        default: op_str = "R-OP       ";
                    endcase
                end
            end
            7'b0010011: begin // I-type ADDI (treated as ADD)
                if (EX_dbg[14:12] == 3'b000) op_str = "ADDI (a+imm)";
                else op_str = "I-OP       ";
            end
            default: op_str = "UNK         ";
        endcase
    end

    // shift pipeline registers on every clock for numeric columns
    always @(posedge clk) begin
        if (!rst_n) begin
            IF_p  <= 32'd0; ID_p <= 32'd0; EX_p <= 32'd0; MEM_p <= 32'd0; WB_p <= 32'd0;
        end else begin
            WB_p  <= MEM_p;
            MEM_p <= EX_p;
            EX_p  <= ID_p;
            ID_p  <= IF_p;
            IF_p  <= alu_out_dbg; // keep numeric column behavior identical to your original TB
        end
    end

    // per-cycle console print (uses decoded op_str from EX_dbg)
    always @(posedge clk) begin
        if (rst_n) begin
            cycle <= cycle + 1;
            $display("CYCLE %0d | %-11s | ALU=%0d | IF=%0d ID=%0d EX=%0d MEM=%0d WB=%0d | MAC=%0d | PER=%0d | LEDS=%b",
                      cycle, op_str, alu_out_dbg, IF_p, ID_p, EX_p, MEM_p, WB_p, mac_dbg, perc_dbg, led);
        end
    end

    initial begin
        #600;
        $display("----------------------------------------------------");
        $display("MAC on FPGA      = MAC value at 10th cycle = %0d", mac10_dbg);
        $display("Perceptron value = PER value at 10th cycle = %0d", perc10_dbg);
        $display("Threshold used   = 1000 (LED1<1000, LED2>=1000)");
        $display("Note: Pipeline produces 1 ALU result / cycle after fill,");
        $display("      while MAC+Perceptron accelerator also updates every cycle.");
        $display("      A sequential CPU would need many instructions per MAC+PER,");
        $display("      but this accelerator does it in ~1 cycle per new input.");
        $display("----------------------------------------------------");
        $finish;
    end

endmodule

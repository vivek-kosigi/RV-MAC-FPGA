// =========================================================
// rv_top_all.v  - RV32I+M subset 5-stage pipelined core with
//                MAC + Perceptron + LCD + cycle-latch @10
// Single-file (contains all helper modules) to avoid duplicate defs
// =========================================================
`timescale 1ns/1ps

module rv_top_all (
    input  wire        clk,
    input  wire        rst_n,
    output wire [2:0]  led,

    // LCD interface
    output wire        lcd_rs,
    output wire        lcd_e,
    output wire [7:0]  data,

    // debug outputs for simulation / analysis
    output wire [31:0] if_reg_out, id_reg_out, ex_reg_out, mem_reg_out, wb_reg_out,
    output wire [31:0] alu_out_dbg, mac_dbg, perc_dbg,
    output wire [2:0]  alu_op_dbg,
    output wire [31:0] mac10_dbg,
    output wire [31:0] perc10_dbg
);

    // ----------------------------------------------------
    // Internal signals
    // ----------------------------------------------------
    reg  [31:0] pc;
    wire [31:0] inst_if;

    reg [31:0] if_reg, id_reg, ex_reg, mem_reg, wb_reg;

    // decode fields
    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [4:0] rs1, rs2;
    wire [31:0] imm_i, imm_s, imm_b, imm_j;

    // regfile wires
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] rf_wdata;
    wire        rf_we;

    // ALU / EX stage
    reg  [2:0]  alu_op;
    wire [31:0] alu_a, alu_b;
    wire [31:0] alu_out;

    // MAC & Perceptron
    reg  [31:0] mac_reg;
    wire [31:0] mac_out;
    wire [31:0] perceptron_out;

    // 10th-cycle latch
    reg [31:0] cycle_cnt;
    reg [31:0] mac_10;
    reg [31:0] perc_10;
    reg        latched_10;

    // debug wires
    assign if_reg_out  = if_reg;
    assign id_reg_out  = id_reg;
    assign ex_reg_out  = ex_reg;
    assign mem_reg_out = mem_reg;
    assign wb_reg_out  = wb_reg;

    // ----------------------------------------------------
    // IMEM (RISC-V encodings for ADD,SUB,AND,OR,XOR,MUL)
    // ----------------------------------------------------
    imem u_imem (.addr(pc[7:2]), .inst(inst_if));

    // PC: increment by 4 each clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pc <= 32'd0;
        else pc <= pc + 4;
    end

    // IF register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) if_reg <= 32'd0;
        else if_reg <= inst_if;
    end

    // ----------------------------------------------------
    // ID stage: decode
    // ----------------------------------------------------
    assign opcode = id_reg[6:0];
    assign rd     = id_reg[11:7];
    assign funct3 = id_reg[14:12];
    assign rs1    = id_reg[19:15];
    assign rs2    = id_reg[24:20];
    assign funct7 = id_reg[31:25];

    // immediates
    assign imm_i = {{20{id_reg[31]}}, id_reg[31:20]};
    assign imm_s = {{20{id_reg[31]}}, id_reg[31:25], id_reg[11:7]};
    assign imm_b = {{19{id_reg[31]}}, id_reg[31], id_reg[7], id_reg[30:25], id_reg[11:8], 1'b0};
    assign imm_j = {{11{id_reg[31]}}, id_reg[31], id_reg[19:12], id_reg[20], id_reg[30:21], 1'b0};

    // regfile instantiation
    regfile u_rf (
        .clk   (clk),
        .rst_n (rst_n),
        .rs1   (rs1),
        .rs2   (rs2),
        .rd    (rd),
        .we    (rf_we),
        .wdata (rf_wdata),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    // ID register capture
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) id_reg <= 32'd0;
        else id_reg <= if_reg;
    end

    // ----------------------------------------------------
    // EX stage: decode ALU op (small subset)
    // Map to debug codes: 0 ADD,1 SUB,2 AND,3 OR,4 XOR,5 MUL
    // ----------------------------------------------------
    reg [2:0] ex_opcode;
    reg [31:0] ex_rs1_data, ex_rs2_data;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_reg <= 32'd0;
            ex_opcode <= 3'd0;
            ex_rs1_data <= 32'd0;
            ex_rs2_data <= 32'd0;
        end else begin
            ex_reg <= id_reg;
            ex_rs1_data <= rs1_data;
            ex_rs2_data <= rs2_data;
            // default
            ex_opcode <= 3'd0;
            if (id_reg[6:0] == 7'b0110011) begin // R-type
                if (funct7 == 7'b0000001 && funct3 == 3'b000) ex_opcode <= 3'd5; // MUL
                else begin
                    case (funct3)
                        3'b000: begin if (funct7 == 7'b0100000) ex_opcode <= 3'd1; else ex_opcode <= 3'd0; end
                        3'b111: ex_opcode <= 3'd2;
                        3'b110: ex_opcode <= 3'd3;
                        3'b100: ex_opcode <= 3'd4;
                        default: ex_opcode <= 3'd0;
                    endcase
                end
            end else if (id_reg[6:0] == 7'b0010011) begin // ADDI
                if (funct3 == 3'b000) ex_opcode <= 3'd0;
            end
        end
    end

    always @(*) alu_op = ex_opcode;
    assign alu_a = ex_rs1_data;
    assign alu_b = ex_rs2_data;

    alu u_alu (.a(alu_a), .b(alu_b), .op(alu_op), .y(alu_out));

    // EX -> MEM pipeline regs (instruction words for waveform)
    reg [31:0] ex_alu_out;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_alu_out <= 32'd0;
            mem_reg <= 32'd0;
        end else begin
            ex_alu_out <= alu_out;
            mem_reg <= ex_reg;
        end
    end

    // pass ALU result along pipeline
    reg [31:0] mem_alu_out;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) mem_alu_out <= 32'd0;
        else mem_alu_out <= ex_alu_out;
    end

    reg [31:0] wb_alu_out;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_reg <= 32'd0;
            wb_alu_out <= 32'd0;
        end else begin
            wb_reg <= mem_reg;
            wb_alu_out <= mem_alu_out;
        end
    end

    // Writeback: always write ALU result to rd (except x0)
    assign rf_we = 1'b1;
    assign rf_wdata = wb_alu_out;

    // expose alu debug
    assign alu_out_dbg = alu_out;
    assign alu_op_dbg  = alu_op;

    // ----------------------------------------------------
    // MAC & Perceptron (identical behaviour)
    // ----------------------------------------------------
    reg [31:0] a_local, b_local;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_local <= 32'd10;
            b_local <= 32'd11;
        end else begin
            a_local <= a_local;
            b_local <= b_local;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) mac_reg <= 32'd0;
        else mac_reg <= mac_reg + (a_local * b_local);
    end
    assign mac_out = mac_reg;
    assign mac_dbg = mac_out;

    perceptron u_perc (.mac_in(mac_out), .a(a_local), .b(b_local), .y(perceptron_out));
    assign perc_dbg = perceptron_out;

    // 10th cycle latch
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_cnt <= 32'd0; mac_10 <= 32'd0; perc_10 <= 32'd0; latched_10 <= 1'b0;
        end else begin
            cycle_cnt <= cycle_cnt + 1;
            if (cycle_cnt == 32'd10 && !latched_10) begin
                mac_10 <= mac_out;
                perc_10 <= perceptron_out;
                latched_10 <= 1'b1;
            end
        end
    end
    assign mac10_dbg = mac_10;
    assign perc10_dbg = perc_10;

    // LEDs
    wire [31:0] perc_for_led = latched_10 ? perc_10 : perceptron_out;
    assign led[0] = 1'b1;
    assign led[1] = (perc_for_led < 32'd1000);
    assign led[2] = (perc_for_led >= 32'd1000);

    // LCD
    lcd_driver u_lcd (
        .clk(clk), .rst_n(rst_n),
        .mac_value(mac_10[15:0]), .per_value(perc_10[15:0]), .latched_10(latched_10),
        .lcd_rs(lcd_rs), .lcd_e(lcd_e), .data(data)
    );

endmodule

// =====================================================
// imem: ROM with RISC-V encodings for the repeating sequence
// =====================================================
module imem (input [5:0] addr, output reg [31:0] inst);
    always @(*) begin
        case (addr)
            6'd0:  inst = 32'b0000000_00010_00001_000_00011_0110011; // ADD x3,x1,x2
            6'd1:  inst = 32'b0100000_00010_00001_000_00011_0110011; // SUB
            6'd2:  inst = 32'b0000000_00010_00001_111_00011_0110011; // AND
            6'd3:  inst = 32'b0000000_00010_00001_110_00011_0110011; // OR
            6'd4:  inst = 32'b0000000_00010_00001_100_00011_0110011; // XOR
            6'd5:  inst = 32'b0000001_00010_00001_000_00011_0110011; // MUL
            default: inst = 32'b0000000_00010_00001_000_00011_0110011;
        endcase
    end
endmodule

// =====================================================
// ALU
// =====================================================
module alu (
    input  [31:0] a,
    input  [31:0] b,
    input  [2:0]  op,
    output reg [31:0] y
);
    always @(*) begin
        case(op)
            3'b000: y = a + b;   // ADD
            3'b001: y = a - b;   // SUB
            3'b010: y = a & b;   // AND
            3'b011: y = a | b;   // OR
            3'b100: y = a ^ b;   // XOR
            3'b101: y = a * b;   // MUL
            default: y = 32'd0;
        endcase
    end
endmodule

// =====================================================
// Perceptron
// =====================================================
module perceptron (
    input  [31:0] mac_in,
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] y
);
    assign y = mac_in + (2*a) + (3*b);
endmodule

// =====================================================
// Register file (x0 hardwired zero, x1=10, x2=11 initially)
// =====================================================
module regfile (
    input clk, input rst_n,
    input [4:0] rs1, rs2, rd,
    input we,
    input [31:0] wdata,
    output [31:0] rs1_data, rs2_data
);
    reg [31:0] regs [0:31];
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i=0;i<32;i=i+1) regs[i] <= 32'd0;
            regs[1] <= 32'd10;
            regs[2] <= 32'd11;
        end else begin
            if (we && rd != 5'd0) regs[rd] <= wdata;
        end
    end
    assign rs1_data = (rs1==5'd0) ? 32'd0 : regs[rs1];
    assign rs2_data = (rs2==5'd0) ? 32'd0 : regs[rs2];
endmodule

// =====================================================
// bin16_to_bcd and lcd_driver (verbatim behavior)
// =====================================================
module bin16_to_bcd (
    input  [15:0] bin,
    output reg [3:0] thou,
    output reg [3:0] hund,
    output reg [3:0] tens,
    output reg [3:0] ones
);
    integer i;
    reg [31:0] shift;
    always @* begin
        shift = 32'd0;
        shift[15:0] = bin;
        for (i = 0; i < 16; i = i + 1) begin
            if (shift[19:16] >= 5) shift[19:16] = shift[19:16] + 3;
            if (shift[23:20] >= 5) shift[23:20] = shift[23:20] + 3;
            if (shift[27:24] >= 5) shift[27:24] = shift[27:24] + 3;
            if (shift[31:28] >= 5) shift[31:28] = shift[31:28] + 3;
            shift = shift << 1;
        end
        thou = shift[31:28];
        hund = shift[27:24];
        tens = shift[23:20];
        ones = shift[19:16];
    end
endmodule

module lcd_driver (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] mac_value,
    input  wire [15:0] per_value,
    input  wire        latched_10,
    output reg         lcd_rs,
    output reg         lcd_e,
    output reg  [7:0]  data
);
    wire [3:0] mac_th, mac_hu, mac_te, mac_on;
    wire [3:0] per_th, per_hu, per_te, per_on;

    bin16_to_bcd u_mac_b2b (.bin(mac_value), .thou(mac_th), .hund(mac_hu), .tens(mac_te), .ones(mac_on));
    bin16_to_bcd u_per_b2b (.bin(per_value), .thou(per_th), .hund(per_hu), .tens(per_te), .ones(per_on));

    function [7:0] to_ascii;
        input [3:0] d;
        begin to_ascii = 8'h30 + d; end
    endfunction

    localparam integer DIVIDER = 100_000;
    reg [16:0] div_cnt;
    wire tick;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) div_cnt <= 0;
        else if (div_cnt == DIVIDER-1) div_cnt <= 0;
        else div_cnt <= div_cnt + 1;
    end
    assign tick = (div_cnt == 0);

    reg [5:0] state;
    reg e_phase;
    reg [7:0] ch;
    reg [5:0] char_index;

    always @(*) begin
        case (char_index)
            6'd0:  ch = "M";
            6'd1:  ch = "A";
            6'd2:  ch = "C";
            6'd3:  ch = ":";
            6'd4:  ch = " ";
            6'd5:  ch = to_ascii(mac_th);
            6'd6:  ch = to_ascii(mac_hu);
            6'd7:  ch = to_ascii(mac_te);
            6'd8:  ch = to_ascii(mac_on);
            6'd9:  ch = " ";
            6'd10: ch = " ";
            6'd11: ch = " ";
            6'd12: ch = " ";
            6'd13: ch = " ";
            6'd14: ch = " ";
            6'd15: ch = " ";
            6'd16: ch = "P";
            6'd17: ch = "E";
            6'd18: ch = "R";
            6'd19: ch = ":";
            6'd20: ch = " ";
            6'd21: ch = to_ascii(per_th);
            6'd22: ch = to_ascii(per_hu);
            6'd23: ch = to_ascii(per_te);
            6'd24: ch = to_ascii(per_on);
            6'd25: ch = " ";
            6'd26: ch = " ";
            6'd27: ch = " ";
            6'd28: ch = " ";
            6'd29: ch = " ";
            6'd30: ch = " ";
            6'd31: ch = " ";
            default: ch = " ";
        endcase
    end

    localparam S_POWERUP_WAIT  = 0;
    localparam S_FUNC_SET      = 1;
    localparam S_DISP_ON       = 2;
    localparam S_ENTRY_MODE    = 3;
    localparam S_CLEAR         = 4;
    localparam S_SET_LINE1     = 5;
    localparam S_WRITE_LINE1   = 6;
    localparam S_SET_LINE2     = 7;
    localparam S_WRITE_LINE2   = 8;
    localparam S_DONE          = 9;

    reg [15:0] power_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_POWERUP_WAIT;
            e_phase    <= 1'b0;
            lcd_rs     <= 1'b0;
            lcd_e      <= 1'b0;
            data       <= 8'h00;
            power_cnt  <= 16'd0;
            char_index <= 6'd0;
        end else begin
            if (state == S_POWERUP_WAIT) begin
                if (tick) begin
                    if (power_cnt < 16'd20) power_cnt <= power_cnt + 1;
                    else begin power_cnt <= 16'd0; state <= S_FUNC_SET; e_phase <= 1'b0; end
                end
            end else if (tick) begin
                case (state)
                    S_FUNC_SET: begin
                        if (!e_phase) begin lcd_rs <= 1'b0; data <= 8'h38; lcd_e <= 1'b1; e_phase <= 1'b1; end
                        else begin lcd_e <= 1'b0; e_phase <= 1'b0; state <= S_DISP_ON; end
                    end
                    S_DISP_ON: begin
                        if (!e_phase) begin lcd_rs <= 1'b0; data <= 8'h0C; lcd_e <= 1'b1; e_phase <= 1'b1; end
                        else begin lcd_e <= 1'b0; e_phase <= 1'b0; state <= S_ENTRY_MODE; end
                    end
                    S_ENTRY_MODE: begin
                        if (!e_phase) begin lcd_rs <= 1'b0; data <= 8'h06; lcd_e <= 1'b1; e_phase <= 1'b1; end
                        else begin lcd_e <= 1'b0; e_phase <= 1'b0; state <= S_CLEAR; end
                    end
                    S_CLEAR: begin
                        if (!e_phase) begin lcd_rs <= 1'b0; data <= 8'h01; lcd_e <= 1'b1; e_phase <= 1'b1; end
                        else begin lcd_e <= 1'b0; e_phase <= 1'b0; state <= S_SET_LINE1; end
                    end
                    S_SET_LINE1: begin
                        if (!e_phase) begin lcd_rs <= 1'b0; data <= 8'h80; lcd_e <= 1'b1; e_phase <= 1'b1; char_index <= 6'd0; end
                        else begin lcd_e <= 1'b0; e_phase <= 1'b0; state <= S_WRITE_LINE1; end
                    end
                    S_WRITE_LINE1: begin
                        if (char_index < 6'd16) begin
                            if (!e_phase) begin lcd_rs <= 1'b1; data <= ch; lcd_e <= 1'b1; e_phase <= 1'b1; end
                            else begin lcd_e <= 1'b0; e_phase <= 1'b0; char_index <= char_index + 1; end
                        end else state <= S_SET_LINE2;
                    end
                    S_SET_LINE2: begin
                        if (!e_phase) begin lcd_rs <= 1'b0; data <= 8'hC0; lcd_e <= 1'b1; e_phase <= 1'b1; char_index <= 6'd16; end
                        else begin lcd_e <= 1'b0; e_phase <= 1'b0; state <= S_WRITE_LINE2; end
                    end
                    S_WRITE_LINE2: begin
                        if (char_index < 6'd32) begin
                            if (!e_phase) begin lcd_rs <= 1'b1; data <= ch; lcd_e <= 1'b1; e_phase <= 1'b1; end
                            else begin lcd_e <= 1'b0; e_phase <= 1'b0; char_index <= char_index + 1; end
                        end else state <= S_DONE;
                    end
                    S_DONE: begin state <= S_DONE; end
                    default: state <= S_POWERUP_WAIT;
                endcase
            end
        end
    end

endmodule

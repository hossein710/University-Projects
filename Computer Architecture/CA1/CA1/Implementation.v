// Hossein Moradi 810803090
// Soroush Nasiri 810803098

module ProgramCounter (output_reg, input_reg, clk, rst);
    input clk, rst;
    input  [31:0] input_reg;
    output reg [31:0] output_reg;

    always @(posedge clk or posedge rst) begin
        if (rst)
            output_reg <= 32'b0;
        else
            output_reg <= input_reg;
    end
endmodule


module InstructionMemory (result, adr);
    input  [31:0] adr;
    output reg [31:0] result;

    always @(adr) begin
        result = 32'h00000013;
        case (adr)
            32'd0:   result = 32'h3E800913;
            32'd4:   result = 32'h00000413;
            32'd8:   result = 32'h00942293;
            32'd12:  result = 32'h04028A63;
            32'd16:  result = 32'h3E800913;
            32'd20:  result = 32'h00000493;
            32'd24:  result = 32'h0094A313;
            32'd28:  result = 32'h02030E63;
            32'd32:  result = 32'h00092383;
            32'd36:  result = 32'h00492E03;
            32'd40:  result = 32'h007E4863;
            32'd44:  result = 32'h00490913;
            32'd48:  result = 32'h00148493;
            32'd52:  result = 32'hFE5FF06F;
            32'd56:  result = 32'h00038EB3;
            32'd60:  result = 32'h000E03B3;
            32'd64:  result = 32'h000E8E33;
            32'd68:  result = 32'h00792023;
            32'd72:  result = 32'h01C92223;
            32'd76:  result = 32'h00490913;
            32'd80:  result = 32'h00148493;
            32'd84:  result = 32'hFC5FF06F;
            32'd88:  result = 32'h00140413;
            32'd92:  result = 32'hFADFF06F;
            32'd96:  result = 32'h3E800B13;
            32'd100: result = 32'h000B2B83;
            32'd104: result = 32'h004B2B83;
            32'd108: result = 32'h008B2B83;
            32'd112: result = 32'h00CB2B83;
            32'd116: result = 32'h010B2B83;
            32'd120: result = 32'h014B2B83;
            32'd124: result = 32'h018B2B83;
            32'd128: result = 32'h01CB2B83;
            32'd132: result = 32'h020B2B83;
            32'd136: result = 32'h024B2B83;
            32'd140: result = 32'h0000006F;
            default: result = 32'h00000013;
        endcase
    end
endmodule


module RegisterFile (rd1, rd2, rs1, rs2, rw, wd, we, clk);
    input  [4:0]  rs1, rs2, rw;
    input  [31:0] wd;
    input         we, clk;
    output [31:0] rd1, rd2;

    reg [31:0] regs [0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    assign rd1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign rd2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];

    always @(posedge clk) begin
        if (we && (rw != 5'b0))
            regs[rw] <= wd;
    end
endmodule


module SimpleALU (Y, A, B);
    input  [31:0] A, B;
    output [31:0] Y;
    assign Y = A + B;
endmodule


module ALU (Y, zero, neg, A, B, ALUfunc);
    output reg [31:0] Y;
    output            zero, neg;
    input  [31:0]     A, B;
    input  [2:0]      ALUfunc;

    always @(A or B or ALUfunc) begin
        case (ALUfunc)
            3'd0: Y = A + B;
            3'd1: Y = A + (~B) + 1;
            3'd2: Y = A & B;
            3'd3: Y = A | B;
            3'd4: Y = A ^ B;
            3'd5: Y = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
            default: Y = 32'b0;
        endcase
    end

    assign zero = (Y == 32'b0);
    assign neg  = Y[31];
endmodule


module DataMemory (rd, adr, wd, we, clk);
    output [31:0] rd;
    input  [31:0] adr, wd;
    input         we, clk;

    localparam MEM_WORDS = 1 << 12;
    reg [31:0] memory [0 : MEM_WORDS-1];

    assign rd = memory[adr[13:2]];

    always @(posedge clk) begin
        if (we)
            memory[adr[13:2]] <= wd;
    end

    integer k;
    initial begin
        for (k = 0; k < MEM_WORDS; k = k + 1)
            memory[k] = 32'b0;
        memory[250] = 32'h0000004A;
        memory[251] = 32'hFFFFFFF4;
        memory[252] = 32'h0000002B;
        memory[253] = 32'hFFFFFFE1;
        memory[254] = 32'hFFFFFFF1;
        memory[255] = 32'h0000000A;
        memory[256] = 32'h00000009;
        memory[257] = 32'h00000012;
        memory[258] = 32'h0000000D;
        memory[259] = 32'hFFFFFFEB;
    end
endmodule


module ImmediateExtention (result, imm, Immsrc);
    output reg [31:0] result;
    input      [24:0] imm;
    input      [1:0]  Immsrc;

    always @(imm or Immsrc) begin
        case (Immsrc)
            2'b00: result = {{20{imm[24]}}, imm[24:13]};
            2'b01: result = {{20{imm[24]}}, imm[24:18], imm[4:0]};
            2'b10: result = {{19{imm[24]}}, imm[24], imm[0], imm[23:18], imm[4:1], 1'b0};
            2'b11: result = {{11{imm[24]}}, imm[24], imm[12:5], imm[13], imm[23:14], 1'b0};
            default: result = 32'b0;
        endcase
    end
endmodule


module ControlUnit (
    resultSrc,
    memWrite,
    aluSrc,
    aluFunc,
    regWrite,
    immSrc,
    pcSrc,
    zero, neg,
    opcode,
    func3,
    func7
);
    input        zero, neg;
    input  [6:0] opcode;
    input  [2:0] func3;
    input  [6:0] func7;

    output [1:0] resultSrc;
    output       memWrite, aluSrc, regWrite;
    output reg [2:0] aluFunc;
    output [1:0] immSrc;
    output [1:0] pcSrc;

    reg [1:0] aluOp;

    always @(opcode) begin
        case (opcode)
            7'd51:  aluOp = 2'b10;
            7'd19:  aluOp = 2'b11;
            7'd3:   aluOp = 2'b00;
            7'd35:  aluOp = 2'b00;
            7'd103: aluOp = 2'b00;
            7'd99:  aluOp = 2'b01;
            7'd111: aluOp = 2'b00;
            default: aluOp = 2'b00;
        endcase
    end

    always @(aluOp or func3 or func7) begin
        case (aluOp)
            2'b00: aluFunc = 3'd0;
            2'b01: aluFunc = 3'd1;
            2'b10: begin
                case ({func7, func3})
                    {7'd0,  3'd0}: aluFunc = 3'd0;
                    {7'd32, 3'd0}: aluFunc = 3'd1;
                    {7'd0,  3'd7}: aluFunc = 3'd2;
                    {7'd0,  3'd6}: aluFunc = 3'd3;
                    {7'd0,  3'd4}: aluFunc = 3'd4;
                    {7'd0,  3'd2}: aluFunc = 3'd5;
                    default:       aluFunc = 3'd0;
                endcase
            end
            2'b11: begin
                case (func3)
                    3'd0: aluFunc = 3'd0;
                    3'd6: aluFunc = 3'd3;
                    3'd4: aluFunc = 3'd4;
                    3'd2: aluFunc = 3'd5;
                    default: aluFunc = 3'd0;
                endcase
            end
            default: aluFunc = 3'd0;
        endcase
    end

    wire branch_taken;
    assign branch_taken =
        (func3 == 3'b000 &&  zero)          |
        (func3 == 3'b001 && ~zero)          |
        (func3 == 3'b100 &&  neg && ~zero)  |
        (func3 == 3'b101 && (~neg || zero));

    assign pcSrc =
        (opcode == 7'd103)                ? 2'b10 :
        (opcode == 7'd111)                ? 2'b01 :
        (opcode == 7'd99 && branch_taken) ? 2'b01 :
                                            2'b00;

    assign resultSrc =
        (opcode == 7'd3)                        ? 2'b01 :
        (opcode == 7'd111 || opcode == 7'd103)  ? 2'b10 :
                                                  2'b00;

    assign memWrite = (opcode == 7'd35);

    assign aluSrc = (opcode == 7'd51 || opcode == 7'd99) ? 1'b0 : 1'b1;

    assign immSrc =
        (opcode == 7'd19 || opcode == 7'd3 || opcode == 7'd103) ? 2'b00 :
        (opcode == 7'd35)                                        ? 2'b01 :
        (opcode == 7'd99)                                        ? 2'b10 :
        (opcode == 7'd111)                                       ? 2'b11 :
                                                                   2'b00;

    assign regWrite =
        (opcode == 7'd51  ||
         opcode == 7'd19  ||
         opcode == 7'd3   ||
         opcode == 7'd111 ||
         opcode == 7'd103);

endmodule
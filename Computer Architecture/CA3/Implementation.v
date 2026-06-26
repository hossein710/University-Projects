// Soroush Nasiri 810803098
// Hossein Moradi 810803090

module ProgramCounter (output_reg, input_reg, clk, rst, en);
    input             clk, rst, en;
    input      [31:0] input_reg;
    output reg [31:0] output_reg;

    always @(posedge clk or posedge rst) begin
        if (rst)
            output_reg <= 32'b0;
        else if (en)
            output_reg <= input_reg;
    end
endmodule


module PipeReg #(parameter WIDTH = 32) (output_reg, input_reg, clk, rst, clr, en);
    input                  clk, rst, clr, en;
    input      [WIDTH-1:0] input_reg;
    output reg [WIDTH-1:0] output_reg;

    always @(posedge clk or posedge rst) begin
        if (rst)
            output_reg <= {WIDTH{1'b0}};
        else if (clr)
            output_reg <= {WIDTH{1'b0}};
        else if (en)
            output_reg <= input_reg;
    end
endmodule


module InstructionMemory (result, adr);
    input      [31:0] adr;
    output reg [31:0] result;

    always @(*) begin
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

    always @(negedge clk) begin
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

    always @(*) begin
        case (ALUfunc)
            3'd0: Y = A + B;
            3'd1: Y = A - B;
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

    always @(*) begin
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
    regWrite,
    resultSrc,
    memWrite,
    aluSrc,
    aluFunc,
    immSrc,
    pcWr,
    jalr,
    pcWrCon,
    opcode,
    func3,
    func7
);
    input  [6:0] opcode;
    input  [2:0] func3;
    input  [6:0] func7;

    output reg       regWrite, memWrite, aluSrc, pcWr, jalr;
    output reg [1:0] resultSrc, immSrc;
    output reg [2:0] aluFunc, pcWrCon;

    reg [1:0] aluOp;

    always @(opcode or func3) begin
        regWrite  = 1'b0;
        resultSrc = 2'b00;
        memWrite  = 1'b0;
        aluSrc    = 1'b1;
        immSrc    = 2'b00;
        pcWr      = 1'b0;
        jalr      = 1'b0;
        pcWrCon   = 3'b000;
        aluOp     = 2'b00;
        case (opcode)
            7'd51:  begin regWrite = 1'b1; aluSrc = 1'b0; aluOp = 2'b10; end
            7'd19:  begin regWrite = 1'b1; aluSrc = 1'b1; immSrc = 2'b00; aluOp = 2'b11; end
            7'd3:   begin regWrite = 1'b1; aluSrc = 1'b1; immSrc = 2'b00; resultSrc = 2'b01; aluOp = 2'b00; end
            7'd35:  begin memWrite = 1'b1; aluSrc = 1'b1; immSrc = 2'b01; aluOp = 2'b00; end
            7'd99:  begin
                aluSrc = 1'b0; immSrc = 2'b10; aluOp = 2'b01;
                case (func3)
                    3'b000:  pcWrCon = 3'b001;
                    3'b001:  pcWrCon = 3'b010;
                    3'b100:  pcWrCon = 3'b011;
                    3'b101:  pcWrCon = 3'b100;
                    default: pcWrCon = 3'b000;
                endcase
            end
            7'd111: begin regWrite = 1'b1; pcWr = 1'b1; immSrc = 2'b11; resultSrc = 2'b10; aluOp = 2'b00; end
            7'd103: begin regWrite = 1'b1; pcWr = 1'b1; jalr = 1'b1; aluSrc = 1'b1; immSrc = 2'b00; resultSrc = 2'b10; aluOp = 2'b00; end
            default: ;
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
endmodule


module HazardDetectionUnit (
    ForwardAE,
    ForwardBE,
    StallF,
    StallD,
    FlushD,
    FlushE,

    rs1D,
    rs2D,
    rs1E,
    rs2E,
    rdE,
    rdM,
    rdW,
    regWriteM,
    regWriteW,
    resultSrcE,
    pcSrcE
);
    output [1:0] ForwardAE, ForwardBE;
    output       StallF, StallD, FlushD, FlushE;

    input  [4:0] rs1D, rs2D, rs1E, rs2E, rdE, rdM, rdW;
    input  [1:0] resultSrcE;
    input        regWriteM, regWriteW, pcSrcE;

    wire lwStall;

    assign ForwardAE = (regWriteM && (rdM != 5'b0) && (rdM == rs1E)) ? 2'b10 :
                       (regWriteW && (rdW != 5'b0) && (rdW == rs1E)) ? 2'b01 : 2'b00;
    assign ForwardBE = (regWriteM && (rdM != 5'b0) && (rdM == rs2E)) ? 2'b10 :
                       (regWriteW && (rdW != 5'b0) && (rdW == rs2E)) ? 2'b01 : 2'b00;

    assign lwStall = (resultSrcE == 2'b01) && (rdE != 5'b0) &&
                     ((rdE == rs1D) || (rdE == rs2D));

    assign StallF = lwStall;
    assign StallD = lwStall;
    assign FlushD = pcSrcE;
    assign FlushE = lwStall | pcSrcE;
endmodule

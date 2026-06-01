// Hossein Moradi 810803090
// Soroush Nasiri 810803098


module Register (output_reg, input_reg, we, clk, rst);
    input         clk, rst, we;
    input  [31:0] input_reg;
    output reg [31:0] output_reg;

    always @(posedge clk or posedge rst) begin
        if (rst)
            output_reg <= 32'b0;
        else if (we)
            output_reg <= input_reg;
    end
endmodule

module Memory (rd, adr, wd, we, clk);
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
            memory[k] = 32'h00000013;

        // Program instructions at word addresses 0-35
        memory[0]   = 32'h3E800913;
        memory[1]   = 32'h00000413;
        memory[2]   = 32'h00942293;
        memory[3]   = 32'h04028A63;
        memory[4]   = 32'h3E800913;
        memory[5]   = 32'h00000493;
        memory[6]   = 32'h0094A313;
        memory[7]   = 32'h02030E63;
        memory[8]   = 32'h00092383;
        memory[9]   = 32'h00492E03;
        memory[10]  = 32'h007E4863;
        memory[11]  = 32'h00490913;
        memory[12]  = 32'h00148493;
        memory[13]  = 32'hFE5FF06F;
        memory[14]  = 32'h00038EB3;
        memory[15]  = 32'h000E03B3;
        memory[16]  = 32'h000E8E33;
        memory[17]  = 32'h00792023;
        memory[18]  = 32'h01C92223;
        memory[19]  = 32'h00490913;
        memory[20]  = 32'h00148493;
        memory[21]  = 32'hFC5FF06F;
        memory[22]  = 32'h00140413;
        memory[23]  = 32'hFADFF06F;
        memory[24]  = 32'h3E800B13;
        memory[25]  = 32'h000B2B83;
        memory[26]  = 32'h004B2B83;
        memory[27]  = 32'h008B2B83;
        memory[28]  = 32'h00CB2B83;
        memory[29]  = 32'h010B2B83;
        memory[30]  = 32'h014B2B83;
        memory[31]  = 32'h018B2B83;
        memory[32]  = 32'h01CB2B83;
        memory[33]  = 32'h020B2B83;
        memory[34]  = 32'h024B2B83;
        memory[35]  = 32'h0000006F;

        // Data at word addresses 250-259
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
    PCW,
    AdrSrc,
    memWrite,
    OldPCWrite,
    IRWrite,
    MDRWrite,
    regWrite,
    immSrc,
    ASRC,
    BSRC,
    aluFunc,
    resultSrc,
    clk,
    rst,
    zero,
    neg,
    OPCode,
    func3,
    func7
);
    output            PCW;
    output reg        AdrSrc;
    output reg        memWrite;
    output reg        OldPCWrite;
    output reg        IRWrite;
    output reg        MDRWrite;
    output reg        regWrite;
    output reg [1:0]  immSrc;
    output reg [1:0]  ASRC;
    output reg [1:0]  BSRC;
    output reg [2:0]  aluFunc;
    output reg [1:0]  resultSrc;
    input zero, neg, clk, rst;
    input [6:0] OPCode;
    input [2:0] func3;
    input [6:0] func7;

    reg PCWrite;
    reg PCWriteCond;
    reg [4:0] ns;
    reg [4:0] ps;
    reg [1:0] aluOP;

    wire andbeq, andbge, andblt, andbne;

    parameter IF = 5'd0, ID = 5'd1, LW1 = 5'd2, LW2 = 5'd3,
              LW3 = 5'd4, SW1 = 5'd5, SW2 = 5'd6, RT1 = 5'd7,
              RT2 = 5'd8, BRANCH = 5'd9, JAL1 = 5'd10, JAL2 = 5'd11,
              JAL3 = 5'd12, JALR2 = 5'd13, IT1 = 5'd14, IT2 = 5'd15;

    always @(posedge clk or posedge rst) begin
        if (rst)
            ps <= IF;
        else
            ps <= ns;
    end

    always @(ps) begin
        case (ps)
            IF:     ns = ID;
            ID:     ns = (OPCode == 7'd51)  ? RT1    :
                         (OPCode == 7'd3)   ? LW1    :
                         (OPCode == 7'd35)  ? SW1    :
                         (OPCode == 7'd111) ? JAL1   :
                         (OPCode == 7'd103) ? JAL1   :
                         (OPCode == 7'd99)  ? BRANCH :
                         (OPCode == 7'd19)  ? IT1    : IF;
            BRANCH: ns = IF;
            RT1:    ns = RT2;
            RT2:    ns = IF;
            SW1:    ns = SW2;
            SW2:    ns = IF;
            LW1:    ns = LW2;
            LW2:    ns = LW3;
            LW3:    ns = IF;
            IT1:    ns = IT2;
            IT2:    ns = IF;
            JAL1:   ns = (OPCode == 7'd103) ? JALR2 : JAL2;
            JAL2:   ns = JAL3;
            JALR2:  ns = JAL3;
            JAL3:   ns = IF;
            default: ns = IF;
        endcase
    end

    always @(ps) begin
        PCWrite     = 1'b0;
        AdrSrc      = 1'b0;
        memWrite    = 1'b0;
        OldPCWrite  = 1'b0;
        IRWrite     = 1'b0;
        MDRWrite    = 1'b0;
        regWrite    = 1'b0;
        immSrc      = 2'b00;
        ASRC        = 2'b00;
        BSRC        = 2'b00;
        aluOP       = 2'b00;
        resultSrc   = 2'b00;
        PCWriteCond = 1'b0;

        case (ps)
            IF: begin
                AdrSrc     = 1'b0;
                IRWrite    = 1'b1;
                ASRC       = 2'b00;   // PC
                BSRC       = 2'b10;   // 4
                aluOP      = 2'b00;   // add -> PC + 4
                resultSrc  = 2'b10;
                PCWrite    = 1'b1;
                OldPCWrite = 1'b1;
            end
            ID: begin
                ASRC   = 2'b01;       // OldPC
                BSRC   = 2'b01;       // immExt
                aluOP  = 2'b00;
                immSrc = 2'b10;       // B-type
            end
            BRANCH: begin
                ASRC        = 2'b10;  // A = rs1
                BSRC        = 2'b00;  // B = rs2
                aluOP       = 2'b01;
                resultSrc   = 2'b00;  // branch target in ALUOut
                PCWriteCond = 1'b1;
            end
            RT1: begin
                ASRC  = 2'b10;        // rs1
                BSRC  = 2'b00;        // rs2
                aluOP = 2'b10;        // R-type ALU op
            end
            RT2: begin
                resultSrc = 2'b00;    // ALUOut
                regWrite  = 1'b1;
            end
            SW1: begin
                immSrc = 2'b01;       // S-type
                ASRC   = 2'b10;       // rs1
                BSRC   = 2'b01;       // immExt
                aluOP  = 2'b00;
            end
            SW2: begin
                resultSrc = 2'b00;
                AdrSrc    = 1'b1;
                memWrite  = 1'b1;
            end
            LW1: begin
                ASRC   = 2'b10;       // rs1
                BSRC   = 2'b01;       // immExt
                aluOP  = 2'b00;
                immSrc = 2'b00;       // I-type
            end
            LW2: begin
                resultSrc = 2'b00;
                AdrSrc    = 1'b1;
                MDRWrite  = 1'b1;     // load MDR only when reading real data
            end
            LW3: begin
                resultSrc = 2'b01;
                regWrite  = 1'b1;
            end
            JAL1: begin
                ASRC  = 2'b01;        // OldPC
                BSRC  = 2'b10;        // return address OldPC + 4
                aluOP = 2'b00;
            end
            JAL2: begin
                resultSrc = 2'b00;    // write return address to ALUOut
                regWrite  = 1'b1;
                ASRC      = 2'b01;    // OldPC
                BSRC      = 2'b01;    
                immSrc    = 2'b11;    // J-type
            end
            JALR2: begin
                resultSrc = 2'b00;    // write return address to ALUOut
                regWrite  = 1'b1;
                ASRC      = 2'b10;    // rs1
                BSRC      = 2'b01;    
                immSrc    = 2'b00;    // I-type
            end
            JAL3: begin
                resultSrc = 2'b00;    // jump target in ALUOut
                PCWrite   = 1'b1;
            end
            IT1: begin
                aluOP  = 2'b11;       // I-type ALU op
                ASRC   = 2'b10;       // rs1
                BSRC   = 2'b01;       // immExt
                immSrc = 2'b00;       // I-type
            end
            IT2: begin
                regWrite  = 1'b1;
                resultSrc = 2'b00;    // ALUOut
            end
        endcase
    end

    assign andbeq = PCWriteCond && zero  && (func3 == 3'b000);
    assign andbne = PCWriteCond && ~zero && (func3 == 3'b001);
    assign andblt = PCWriteCond && neg   && (func3 == 3'b100);
    assign andbge = PCWriteCond && ~neg  && (func3 == 3'b101);

    assign PCW = PCWrite || andbeq || andbge || andblt || andbne;

    always @(aluOP or func7 or func3) begin
        case (aluOP)
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
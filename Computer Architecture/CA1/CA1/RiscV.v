// Soroush Nasiri 810803098
// Hossein Moradi 810803090

module RiscV (result, clk, rst);
    input        clk, rst;
    output [31:0] result;

    wire [31:0] pcOut;
    wire [31:0] pcNext;
    wire [31:0] pc4;
    wire [31:0] pcImm;
    wire [31:0] instr;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] immExt;
    wire [31:0] aluB;
    wire [31:0] aluOut;
    wire [31:0] memOut;
    wire [31:0] wdReg;
    wire zero, neg;
    wire [1:0]  pcSrc;
    wire [1:0]  resultSrc;
    wire [1:0]  immSrc;
    wire [2:0]  aluFunc;
    wire memWrite, regWrite, aluSrc;

    ProgramCounter PC (
        .output_reg (pcOut),
        .input_reg  (pcNext),
        .clk        (clk),
        .rst        (rst)
    );

    InstructionMemory IM (
        .result (instr),
        .adr    (pcOut)
    );

    SimpleALU pcPlus4 (
        .Y (pc4),
        .A (pcOut),
        .B (32'd4)
    );

    SimpleALU pcPlusImm (
        .Y (pcImm),
        .A (pcOut),
        .B (immExt)
    );

    assign pcNext = (pcSrc == 2'b10) ? aluOut :
                    (pcSrc == 2'b01) ? pcImm  :
                                       pc4;

    RegisterFile RF (
        .rd1 (rd1),
        .rd2 (rd2),
        .rs1 (instr[19:15]),
        .rs2 (instr[24:20]),
        .rw  (instr[11:7]),
        .wd  (wdReg),
        .we  (regWrite),
        .clk (clk)
    );

    ImmediateExtention ImmExt (
        .result  (immExt),
        .imm     (instr[31:7]),
        .Immsrc  (immSrc)
    );

    assign aluB = aluSrc ? immExt : rd2;

    ALU MainALU (
        .Y       (aluOut),
        .zero    (zero),
        .neg     (neg),
        .A       (rd1),
        .B       (aluB),
        .ALUfunc (aluFunc)
    );

    DataMemory DM (
        .rd  (memOut),
        .adr (aluOut),
        .wd  (rd2),
        .we  (memWrite),
        .clk (clk)
    );

    assign wdReg = (resultSrc == 2'b01) ? memOut :
                   (resultSrc == 2'b10) ? pc4    :
                                          aluOut;

    ControlUnit CU (
        .resultSrc (resultSrc),
        .memWrite  (memWrite),
        .aluSrc    (aluSrc),
        .aluFunc   (aluFunc),
        .regWrite  (regWrite),
        .immSrc    (immSrc),
        .pcSrc     (pcSrc),
        .zero      (zero),
        .neg       (neg),
        .opcode    (instr[6:0]),
        .func3     (instr[14:12]),
        .func7     (instr[31:25])
    );

    assign result = wdReg;

endmodule

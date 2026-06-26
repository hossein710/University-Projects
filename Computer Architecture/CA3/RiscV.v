// Soroush Nasiri 810803098
// Hossein Moradi 810803090

module RiscV (result, clk, rst);
    input         clk, rst;
    output [31:0] result;

    wire        StallF, StallD, FlushD, FlushE;
    wire [31:0] aluOutM, wdReg;
    wire        regWriteW;
    wire [4:0]  rdW;

    wire [31:0] pcF, pcNext, pc4F, instrF;

    ProgramCounter PC (
        .output_reg (pcF),
        .input_reg  (pcNext),
        .clk        (clk),
        .rst        (rst),
        .en         (~StallF)
    );

    InstructionMemory IM (
        .result (instrF),
        .adr    (pcF)
    );

    SimpleALU pcPlus4 (
        .Y (pc4F),
        .A (pcF),
        .B (32'd4)
    );

    wire [95:0] fd;
    PipeReg #(96) RegFD (
        .output_reg (fd),
        .input_reg  ({pc4F, pcF, instrF}),
        .clk        (clk),
        .rst        (rst),
        .clr        (FlushD),
        .en         (~StallD)
    );

    wire [31:0] instrD = fd[31:0];
    wire [31:0] pcD    = fd[63:32];
    wire [31:0] pc4D   = fd[95:64];

    wire [4:0]  rs1D   = instrD[19:15];
    wire [4:0]  rs2D   = instrD[24:20];
    wire [4:0]  rdD    = instrD[11:7];

    wire        regWriteD, memWriteD, aluSrcD, pcWrD, jalrD;
    wire [1:0]  resultSrcD, immSrcD;
    wire [2:0]  aluFuncD, pcWrConD;
    wire [31:0] rd1D, rd2D, immExtD;

    ControlUnit CU (
        .regWrite  (regWriteD),
        .resultSrc (resultSrcD),
        .memWrite  (memWriteD),
        .aluSrc    (aluSrcD),
        .aluFunc   (aluFuncD),
        .immSrc    (immSrcD),
        .pcWr      (pcWrD),
        .jalr      (jalrD),
        .pcWrCon   (pcWrConD),
        .opcode    (instrD[6:0]),
        .func3     (instrD[14:12]),
        .func7     (instrD[31:25])
    );

    RegisterFile RF (
        .rd1 (rd1D),
        .rd2 (rd2D),
        .rs1 (rs1D),
        .rs2 (rs2D),
        .rw  (rdW),
        .wd  (wdReg),
        .we  (regWriteW),
        .clk (clk)
    );

    ImmediateExtention ImmExt (
        .result (immExtD),
        .imm    (instrD[31:7]),
        .Immsrc (immSrcD)
    );

    wire [12:0] ctrlD = {pcWrConD, jalrD, pcWrD, aluFuncD, aluSrcD,
                         memWriteD, resultSrcD, regWriteD};

    wire [12:0] ctrlE;
    PipeReg #(13) RegDE_C (
        .output_reg (ctrlE),
        .input_reg  (ctrlD),
        .clk        (clk),
        .rst        (rst),
        .clr        (FlushE),
        .en         (1'b1)
    );

    wire        regWriteE  = ctrlE[0];
    wire [1:0]  resultSrcE = ctrlE[2:1];
    wire        memWriteE  = ctrlE[3];
    wire        aluSrcE    = ctrlE[4];
    wire [2:0]  aluFuncE   = ctrlE[7:5];
    wire        pcWrE      = ctrlE[8];
    wire        jalrE      = ctrlE[9];
    wire [2:0]  pcWrConE   = ctrlE[12:10];

    wire [174:0] de;
    PipeReg #(175) RegDE (
        .output_reg (de),
        .input_reg  ({rs2D, rs1D, rdD, immExtD, pcD, pc4D, rd2D, rd1D}),
        .clk        (clk),
        .rst        (rst),
        .clr        (FlushE),
        .en         (1'b1)
    );

    wire [31:0] rd1E    = de[31:0];
    wire [31:0] rd2E    = de[63:32];
    wire [31:0] pc4E    = de[95:64];
    wire [31:0] pcE     = de[127:96];
    wire [31:0] immExtE = de[159:128];
    wire [4:0]  rdE     = de[164:160];
    wire [4:0]  rs1E    = de[169:165];
    wire [4:0]  rs2E    = de[174:170];

    wire [1:0]  ForwardAE, ForwardBE;
    wire [31:0] ABusE, BBusE, aluB, aluOutE, pcTargetE;
    wire        zeroE, negE;

    assign ABusE = (ForwardAE == 2'b10) ? aluOutM :
                   (ForwardAE == 2'b01) ? wdReg   : rd1E;

    assign BBusE = (ForwardBE == 2'b10) ? aluOutM :
                   (ForwardBE == 2'b01) ? wdReg   : rd2E;

    assign aluB = aluSrcE ? immExtE : BBusE;

    ALU MainALU (
        .Y       (aluOutE),
        .zero    (zeroE),
        .neg     (negE),
        .A       (ABusE),
        .B       (aluB),
        .ALUfunc (aluFuncE)
    );

    SimpleALU pcPlusImm (
        .Y (pcTargetE),
        .A (pcE),
        .B (immExtE)
    );

    wire branchTakenE = (pcWrConE == 3'b001) ?  zeroE          :
                        (pcWrConE == 3'b010) ? ~zeroE          :
                        (pcWrConE == 3'b011) ? (negE & ~zeroE) :
                        (pcWrConE == 3'b100) ? (~negE | zeroE) :
                                                1'b0;

    wire pcSrcE = pcWrE | branchTakenE;

    assign pcNext = pcSrcE ? (jalrE ? aluOutE : pcTargetE) : pc4F;

    wire [3:0] ctrlM;
    PipeReg #(4) RegEM_C (
        .output_reg (ctrlM),
        .input_reg  ({regWriteE, resultSrcE, memWriteE}),
        .clk        (clk),
        .rst        (rst),
        .clr        (1'b0),
        .en         (1'b1)
    );

    wire        memWriteM  = ctrlM[0];
    wire [1:0]  resultSrcM = ctrlM[2:1];
    wire        regWriteM  = ctrlM[3];

    wire [100:0] em;
    PipeReg #(101) RegEM (
        .output_reg (em),
        .input_reg  ({pc4E, rdE, BBusE, aluOutE}),
        .clk        (clk),
        .rst        (rst),
        .clr        (1'b0),
        .en         (1'b1)
    );

    assign      aluOutM    = em[31:0];
    wire [31:0] writeDataM = em[63:32];
    wire [4:0]  rdM        = em[68:64];
    wire [31:0] pc4M       = em[100:69];

    wire [31:0] readDataM;
    DataMemory DM (
        .rd  (readDataM),
        .adr (aluOutM),
        .wd  (writeDataM),
        .we  (memWriteM),
        .clk (clk)
    );

    wire [2:0] ctrlW;
    PipeReg #(3) RegMW_C (
        .output_reg (ctrlW),
        .input_reg  ({regWriteM, resultSrcM}),
        .clk        (clk),
        .rst        (rst),
        .clr        (1'b0),
        .en         (1'b1)
    );

    wire [1:0]  resultSrcW = ctrlW[1:0];
    assign      regWriteW  = ctrlW[2];

    wire [100:0] mw;
    PipeReg #(101) RegMW (
        .output_reg (mw),
        .input_reg  ({pc4M, rdM, readDataM, aluOutM}),
        .clk        (clk),
        .rst        (rst),
        .clr        (1'b0),
        .en         (1'b1)
    );

    wire [31:0] aluOutW   = mw[31:0];
    wire [31:0] readDataW = mw[63:32];
    assign      rdW       = mw[68:64];
    wire [31:0] pc4W      = mw[100:69];

    assign wdReg = (resultSrcW == 2'b00) ? aluOutW   :
                   (resultSrcW == 2'b01) ? readDataW :
                                           pc4W;

    assign result = wdReg;

    HazardDetectionUnit HDU (
        .ForwardAE  (ForwardAE),
        .ForwardBE  (ForwardBE),
        .StallF     (StallF),
        .StallD     (StallD),
        .FlushD     (FlushD),
        .FlushE     (FlushE),
        .rs1D       (rs1D),
        .rs2D       (rs2D),
        .rs1E       (rs1E),
        .rs2E       (rs2E),
        .rdE        (rdE),
        .rdM        (rdM),
        .rdW        (rdW),
        .regWriteM  (regWriteM),
        .regWriteW  (regWriteW),
        .resultSrcE (resultSrcE),
        .pcSrcE     (pcSrcE)
    );

endmodule

// Soroush Nasiri 810803098
// Hossein Moradi 810803090

module RiscV (result, clk, rst);
    output [31:0] result;
    input       clk, rst;
    wire        PCW, AdrSrc, IRWrite, OldPCWrite, regWrite, memWrite, MDRWrite;
    wire [31:0] pcOut;
    wire [31:0] MemIn;
    wire [31:0] Res;
    wire [31:0] IROut;
    wire [31:0] MDROut;
    wire [31:0] OldPCOut;
    wire [31:0] immExt;
    wire [31:0] AOut;
    wire [31:0] BOut;
    wire [31:0] AIN;
    wire [31:0] BIN;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] memOut;
    wire [1:0]  immSrc;
    wire [1:0]  ASRC;
    wire [1:0]  BSRC;
    wire        zero, neg;
    wire [2:0]  aluFunc;
    wire [31:0] aluOut;
    wire [31:0] FinalAluOut;
    wire [1:0]  resultSrc;

    assign MemIn = (AdrSrc == 1'b0) ? pcOut : Res;

    Register PC (
        .output_reg (pcOut),
        .input_reg  (Res),
        .we         (PCW),
        .clk        (clk),
        .rst        (rst)
    );

    Memory Me (
        .rd  (memOut),
        .adr (MemIn),
        .wd  (rd2),
        .we  (memWrite),
        .clk (clk)
    );

    Register IR (
        .output_reg (IROut),
        .input_reg  (memOut),
        .we         (IRWrite),
        .clk        (clk),
        .rst        (rst)
    );

    Register MDR (
        .output_reg (MDROut),
        .input_reg  (memOut),
        .we         (MDRWrite),
        .clk        (clk),
        .rst        (rst)
    );

    Register OldPC (
        .output_reg (OldPCOut),
        .input_reg  (pcOut),
        .we         (OldPCWrite),
        .clk        (clk),
        .rst        (rst)
    );

    RegisterFile RF (
        .rd1 (rd1),
        .rd2 (rd2),
        .rs1 (IROut[19:15]),
        .rs2 (IROut[24:20]),
        .rw  (IROut[11:7]),
        .wd  (Res),
        .we  (regWrite),
        .clk (clk)
    );

    ImmediateExtention ImmExt (
        .result  (immExt),
        .imm     (IROut[31:7]),
        .Immsrc  (immSrc)
    );
    
    Register A (
        .output_reg (AOut),
        .input_reg  (rd1),
        .we         (1'b1),
        .clk        (clk),
        .rst        (rst)
    );

    Register B (
        .output_reg (BOut),
        .input_reg  (rd2),
        .we         (1'b1),
        .clk        (clk),
        .rst        (rst)
    );

    assign AIN = (ASRC == 2'b00) ? pcOut    :
                 (ASRC == 2'b01) ? OldPCOut :
                 (ASRC == 2'b10) ? AOut     : 32'bx;
    
    assign BIN = (BSRC == 2'b00) ? BOut     :
                 (BSRC == 2'b01) ? immExt   :
                 (BSRC == 2'b10) ? 32'd4    : 32'bx;

    ALU MainALU (
        .Y       (aluOut),
        .zero    (zero),
        .neg     (neg),
        .A       (AIN),
        .B       (BIN),
        .ALUfunc (aluFunc)
    );

    Register ALUOUT (
        .output_reg (FinalAluOut),
        .input_reg  (aluOut),
        .we         (1'b1),
        .clk        (clk),
        .rst        (rst)
    );

    assign Res = (resultSrc == 2'b00) ? FinalAluOut :
                 (resultSrc == 2'b01) ? MDROut      :
                 (resultSrc == 2'b10) ? aluOut      : 32'bx;

    ControlUnit CU (
        .PCW(PCW),
        .AdrSrc(AdrSrc),
        .memWrite(memWrite),
        .OldPCWrite(OldPCWrite),
        .IRWrite(IRWrite),
        .MDRWrite(MDRWrite),
        .regWrite(regWrite),
        .immSrc(immSrc),
        .ASRC(ASRC),
        .BSRC(BSRC),
        .aluFunc(aluFunc),
        .resultSrc(resultSrc),
        //------
        .zero(zero),
        .neg(neg),
        .OPCode(IROut[6:0]),
        .func3(IROut[14:12]),
        .func7(IROut[31:25]),
        .clk(clk),
        .rst(rst)
    );

    assign result = MDROut;

endmodule

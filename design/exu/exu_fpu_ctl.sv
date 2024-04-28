

module exu_fpu_ctl
   import veer_types::*;
(
   input logic         clk,                       // Top level clock
   input logic         active_clk,                // Level 1 active clock
   input logic         rst_l,                     // Reset
   input logic         scan_mode,                 // Scan mode

   input logic [31:0]  a,                // A operand
   input logic [31:0]  b,                // B operand
   input logic [31:0]  c,                // C operand, for fused multiply-add

   input fpu_pkt_t     fp,

   output logic        finish,           // Finish
   output logic        fpu_stall,        // FPU is running

   output logic [31:0] out

  );
   // FPU inputs
   logic [2:0][31:0] fpu_operands;
   fpnew_pkg::operation_e fpu_op;
   logic fpu_op_mod;
   // FPU outputs
   logic fpu_tag;
   logic [31:0] fpu_result;
   fpnew_pkg::status_t fpu_status;


   logic fpu_in_ready, fpu_in_valid;
   logic fpu_out_ready, fpu_out_valid;




   // TODO: need different order based on fpu_op
   assign fpu_operands[0] = c;// = 32'h40000000;
   assign fpu_operands[1] = a;// = 32'h3f800000;
   assign fpu_operands[2] = b;// = 32'h40000000;
   assign fpu_in_valid = 1;
   assign fpu_out_ready = 1;

   assign fpu_op = (({4{fp.add | fp.sub}}      & fpnew_pkg::ADD) |
                    ({4{fp.mul}}      & fpnew_pkg::MUL) |
                    ({4{fp.div}}      & fpnew_pkg::DIV));
   assign fpu_op_mod = fp.sub;
/*
                       logic       valid;
                       logic       load;
                       logic       store;
                       logic       madd;
                       logic       msub;
                       logic       nmsub;
                       logic       nmadd;
                       logic       add;
                       logic       sub;
                       logic       mul;
                       logic       div;
                       logic       sqrt;
                       logic       sgnj;
                       logic       sgnjn;
                       logic       sgnjx;
                       logic       min;
                       logic       max;
                       logic       cvt;
                       logic       mv;
                       logic       eq;
                       logic       lt;
                       logic       le;
                       logic       class_;*/



   fpnew_top #(
      .Features(fpnew_pkg::RV32F),
      .Implementation(fpnew_pkg::DEFAULT_NOREGS),
      .TagType(logic),
      .PulpDivsqrt(1'b1)
   ) fpu_e1 (
      .clk_i         (clk),
      .rst_ni        (1),
      .operands_i    (fpu_operands),
      .rnd_mode_i    (0),
      .op_i          (fpu_op),
      .op_mod_i      (fpu_op_mod),
      .src_fmt_i     (fpnew_pkg::FP32),
      .dst_fmt_i     (fpnew_pkg::FP32),
      .int_fmt_i     (fpnew_pkg::INT32),
      .vectorial_op_i(0),
      .tag_i         (0),
      .simd_mask_i   (0),
      .in_valid_i    (fpu_in_valid),
      .in_ready_o    (fpu_in_ready),
      .flush_i       (0),
      .result_o      (fpu_result[31:0]),
      .status_o      (fpu_status),
      .tag_o         (fpu_tag),
      .out_valid_o   (fpu_out_valid),
      .out_ready_i   (fpu_out_ready),
      .busy_o        (/*unused*/)
   );


   //assig fpu_valid_o = fpu_out_valid;

   always begin
    //if (fpu_out_valid & fp.valid) $display("[busy=%d] fpu_result = 0x%08X", fpu_busy, fpu_result[31:0]);
   end

  endmodule

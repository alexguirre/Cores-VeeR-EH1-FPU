

module exu_fpu_ctl
   import veer_types::*;
(
   input logic         clk,              // Top level clock
   input logic         active_clk,       // Level 1 active clock
   input logic         rst_l,            // Reset
   input logic         scan_mode,        // Scan mode

   input logic [31:0]  a,                // A operand
   input logic [31:0]  b,                // B operand
   input logic [31:0]  c,                // C operand, for fused multiply-add

   input fpu_pkt_t     fp,

   input logic         flush_lower,      // Flush pipeline

   input logic [2:0]   fcsr_frm,         // FCSR rounding mode

   output logic        valid_ff_e1,      // Valid E1 stage
   output logic        finish,           // Finish
   output logic        fpu_stall,        // FPU is running

   output logic [31:0] out

  );
   logic         flush_lower_ff;
   logic         valid_e1;

   fpu_pkt_t     fp_ff;
   logic [31:0]  a_ff;
   logic [31:0]  b_ff;
   logic [31:0]  c_ff;

   // FPU inputs
   logic [2:0][31:0]       fpu_operands;
   fpnew_pkg::operation_e  fpu_op;
   logic                   fpu_op_mod;
   fpnew_pkg::roundmode_e  fpu_rnd_mode;
   fpnew_pkg::fp_format_e  fpu_src_fmt;
   fpnew_pkg::fp_format_e  fpu_dst_fmt;
   fpnew_pkg::int_format_e fpu_int_fmt;
   // FPU outputs
   logic [31:0]        fpu_result;
   logic [31:0]        fpu_result_ff;
   fpnew_pkg::status_t fpu_status; // TODO(FPU): write status to fcsr fflags
   logic               fpu_busy;


   logic fpu_in_ready, fpu_in_valid;
   logic fpu_out_ready, fpu_out_valid;


   rvdff  #(1)                flush_any_ff (.*, .clk(active_clk), .din(flush_lower),                .dout(flush_lower_ff));
   rvdff  #(1)                e1val_ff     (.*, .clk(active_clk), .din(fp.valid & ~flush_lower_ff), .dout(valid_ff_e1));

   rvdffe #($bits(fpu_pkt_t)) fpff         (.*, .en(fp.valid & ~flush_lower_ff), .din(fp),      .dout(fp_ff));
   rvdffe #(32)               aff          (.*, .en(fp.valid & ~flush_lower_ff), .din(a[31:0]), .dout(a_ff[31:0]));
   rvdffe #(32)               bff          (.*, .en(fp.valid & ~flush_lower_ff), .din(b[31:0]), .dout(b_ff[31:0]));
   rvdffe #(32)               cff          (.*, .en(fp.valid & ~flush_lower_ff), .din(c[31:0]), .dout(c_ff[31:0]));

   rvdffe #(32)               resultff     (.*, .en(fpu_out_valid), .din(fpu_result[31:0]), .dout(fpu_result_ff[31:0]));


   assign valid_e1                = valid_ff_e1 & ~flush_lower_ff;

   assign fpu_in_valid = valid_e1;
   assign fpu_out_ready = 1;
   assign fpu_src_fmt = fpnew_pkg::FP32;
   assign fpu_dst_fmt = fpnew_pkg::FP32;
   assign fpu_int_fmt = fpnew_pkg::INT32;

   always_comb begin
     assign fpu_op = (({4{fp_ff.add | fp_ff.sub}}                  & fpnew_pkg::ADD)    |
                      ({4{fp_ff.mul}}                              & fpnew_pkg::MUL)    |
                      ({4{fp_ff.div}}                              & fpnew_pkg::DIV)    |
                      ({4{fp_ff.sqrt}}                             & fpnew_pkg::SQRT)   |
                      ({4{fp_ff.min | fp_ff.max}}                  & fpnew_pkg::MINMAX) |
                      ({4{fp_ff.sgnj | fp_ff.sgnjn | fp_ff.sgnjx}} & fpnew_pkg::SGNJ));
     assign fpu_op_mod = fp_ff.sub;

     // note: minmax and sign injection operations are encoded in rounding mode
     // TODO(FPU): if rm is set to an invalid value it should raise an illegal
     // instruction exception
     `define RM_DYN    3'b111
     assign fpu_rnd_mode = ({3{fp_ff.rm == `RM_DYN}} & fcsr_frm) |
                           ({3{fp_ff.rm != `RM_DYN}} & fp_ff.rm);
     `undef RM_DYN

     if (fp_ff.add | fp_ff.sub) begin
        assign fpu_operands[1] = a_ff;
        assign fpu_operands[2] = b_ff;
     end else begin
        assign fpu_operands[0] = a_ff;
        assign fpu_operands[1] = b_ff;
        assign fpu_operands[2] = c_ff;
     end
   end

  /* TODO(FPU): instructions not handled

     TODO(FPU): fused-multiply-add needs to read register rs3
         logic       madd;
         logic       msub;
         logic       nmsub;
         logic       nmadd;

     TODO(FPU): conversion instructions need to read/write integer registers
         logic       cvt;

     TODO(FPU): move to/from integer registers need to read/write integer registers
         logic       mv;

     TODO(FPU): comparisons and classify needs to store result in integer register
         logic       eq;
         logic       lt;
         logic       le;

         logic       class_;
  */



   fpnew_top #(
      .Features(fpnew_pkg::RV32F),
      .Implementation(fpnew_pkg::DEFAULT_NOREGS),
      .TagType(logic),
      .PulpDivsqrt(1'b1)
   ) fpu_e1 (
      .clk_i         (active_clk),
      .rst_ni        (rst_l),
      .operands_i    (fpu_operands),
      .rnd_mode_i    (fpu_rnd_mode),
      .op_i          (fpu_op),
      .op_mod_i      (fpu_op_mod),
      .src_fmt_i     (fpu_src_fmt),
      .dst_fmt_i     (fpu_dst_fmt),
      .int_fmt_i     (fpu_int_fmt),
      .vectorial_op_i(0),
      .tag_i         (0),
      .simd_mask_i   (0),
      .in_valid_i    (fpu_in_valid),
      .in_ready_o    (fpu_in_ready),
      .flush_i       (flush_lower_ff),
      .result_o      (fpu_result[31:0]),
      .status_o      (fpu_status),
      .tag_o         (/* unused */),
      .out_valid_o   (fpu_out_valid),
      .out_ready_i   (fpu_out_ready),
      .busy_o        (fpu_busy)
   );

   assign out[31:0] = fpu_result_ff[31:0];
   assign finish = fpu_out_valid;
   assign fpu_stall = fpu_busy;




   // DEBUGGING, to see individual signals in gtkwave
       logic       dbg_fp_valid;
       logic       dbg_fp_madd;
       logic       dbg_fp_msub;
       logic       dbg_fp_nmsub;
       logic       dbg_fp_nmadd;
       logic       dbg_fp_add;
       logic       dbg_fp_sub;
       logic       dbg_fp_mul;
       logic       dbg_fp_div;
       logic       dbg_fp_sqrt;
       logic       dbg_fp_sgnj;
       logic       dbg_fp_sgnjn;
       logic       dbg_fp_sgnjx;
       logic       dbg_fp_min;
       logic       dbg_fp_max;
       logic       dbg_fp_cvt;
       logic       dbg_fp_mv;
       logic       dbg_fp_eq;
       logic       dbg_fp_lt;
       logic       dbg_fp_le;
       logic       dbg_fp_class_;
       logic [2:0] dbg_fp_rm; // rounding mode

      assign dbg_fp_valid = fp_ff.valid;
      assign dbg_fp_madd = fp_ff.madd;
      assign dbg_fp_msub = fp_ff.msub;
      assign dbg_fp_nmsub = fp_ff.nmsub;
      assign dbg_fp_nmadd = fp_ff.nmadd;
      assign dbg_fp_add = fp_ff.add;
      assign dbg_fp_sub = fp_ff.sub;
      assign dbg_fp_mul = fp_ff.mul;
      assign dbg_fp_div = fp_ff.div;
      assign dbg_fp_sqrt = fp_ff.sqrt;
      assign dbg_fp_sgnj = fp_ff.sgnj;
      assign dbg_fp_sgnjn = fp_ff.sgnjn;
      assign dbg_fp_sgnjx = fp_ff.sgnjx;
      assign dbg_fp_min = fp_ff.min;
      assign dbg_fp_max = fp_ff.max;
      assign dbg_fp_cvt = fp_ff.cvt;
      assign dbg_fp_mv = fp_ff.mv;
      assign dbg_fp_eq = fp_ff.eq;
      assign dbg_fp_lt = fp_ff.lt;
      assign dbg_fp_le = fp_ff.le;
      assign dbg_fp_class_ = fp_ff.class_;
      assign dbg_fp_rm = fp_ff.rm;



  endmodule

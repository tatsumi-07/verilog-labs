module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  reg  [3:0] exp_result;
  integer    i, j, op_idx;
  integer    errors = 0;
  integer    total = 0;

  // Instantiate DUT
  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  initial begin
    // 1. Sensitivity List Test: Change 'op' without changing 'a' or 'b'
    t_a  = 4'd7;
    t_b  = 4'd3;
    t_op = 1'b0; // ADD -> 7 + 3 = 10
    #5;
    
    t_op = 1'b1; // SUB -> 7 - 3 = 4 (a and b unchanged)
    #5;
    exp_result = t_a - t_b;
    total = total + 1;
    if (t_result !== exp_result) begin
      $display("FAIL [Sens List]: op changed to 1 | got %0d, expected %0d", t_result, exp_result);
      errors = errors + 1;
    end

    // 2. Exhaustive self-checking loop across all a, b, and op
    for (op_idx = 0; op_idx < 2; op_idx = op_idx + 1) begin
      for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
          t_a  = i;
          t_b  = j;
          t_op = op_idx;
          #5;

          exp_result = (t_op == 1'b0) ? (t_a + t_b) : (t_a - t_b);
          total = total + 1;

          if (t_result !== exp_result) begin
            $display("FAIL at time %0t: op=%b a=%0d b=%0d | got result=%0d, expected %0d",
                     $time, t_op, t_a, t_b, t_result, exp_result);
            errors = errors + 1;
          end
        end
      end
    end

    $display("SUMMARY: %0d/%0d PASSED (%0d ERRORS)", total - errors, total, errors);
    $finish;
  end

endmodule
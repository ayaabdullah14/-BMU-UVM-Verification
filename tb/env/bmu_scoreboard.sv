
class bmu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(bmu_scoreboard)

  uvm_analysis_imp #(bmu_seq_item, bmu_scoreboard) analysis_export; 
  bmu_reference_model model;  // Independent specification-based reference model.


  // Expected state of the registered DUT result.
  logic [31:0] expected_result_ff;
  bit          have_result_expectation;

  // Information about the request that created expected_result_ff.
  longint unsigned expected_source_cycle;
  string           expected_operation;
  logic            expected_source_rst_l;
  logic            expected_source_valid_in;
  rtl_pkg::rtl_alu_pkt_t expected_source_ap;
  logic            expected_source_csr_ren;
  logic [31:0]     expected_source_csr_data;
  logic [31:0]     expected_source_a;
  logic [31:0]     expected_source_b;

  // Counts transactions received from the monitor.
  longint unsigned observed_cycle;

  // Activity counters.
  int unsigned observed_count;
  int unsigned reset_count;
  int unsigned valid_request_count;
  int unsigned nop_request_count;
  int unsigned hold_request_count;
  int unsigned skipped_prediction_count;

  // Result comparison counters.
  int unsigned result_check_count;
  int unsigned result_pass_count;
  int unsigned result_fail_count;

  // Error comparison counters.
  int unsigned error_check_count;
  int unsigned error_pass_count;
  int unsigned error_fail_count;


  function new(
    string        name   = "bmu_scoreboard",
    uvm_component parent = null
  );
    super.new(name, parent);
    analysis_export = new("analysis_export", this);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    model = bmu_reference_model::type_id::create("model");

    // Initialize expected-result state.
    expected_result_ff      = 32'h0000_0000;
    have_result_expectation = 1'b0;
    expected_source_cycle   = 0;
    expected_operation      = "NONE";
    expected_source_rst_l   = 1'bx;
    expected_source_valid_in = 1'bx;
    expected_source_ap      = 'x;
    expected_source_csr_ren = 1'bx;
    expected_source_csr_data = 32'hxxxx_xxxx;
    expected_source_a       = 32'hxxxx_xxxx;
    expected_source_b       = 32'hxxxx_xxxx;
    observed_cycle          = 0;

    // Initialize activity counters.
    observed_count           = 0;
    reset_count              = 0;
    valid_request_count      = 0;
    nop_request_count        = 0;
    hold_request_count       = 0;
    skipped_prediction_count = 0;

    // Initialize comparison counters.
    result_check_count = 0;
    result_pass_count  = 0;
    result_fail_count  = 0;
    error_check_count  = 0;
    error_pass_count   = 0;
    error_fail_count   = 0;
  endfunction


  // Save the exact request that created the next expected result.
  // These values are used later if the result comparison fails.
  function void save_expected_source(bmu_seq_item tr);
    expected_source_cycle    = observed_cycle;
    expected_source_rst_l    = tr.rst_l;
    expected_source_valid_in = tr.valid_in;
    expected_source_ap       = tr.ap;
    expected_source_csr_ren  = tr.csr_ren_in;
    expected_source_csr_data = tr.csr_rddata_in;
    expected_source_a        = tr.a_in;
    expected_source_b        = tr.b_in;
  endfunction


  // Return 1 only when the control signals needed by the model are known.
  // valid_in is intentionally not included because error is independent of it.
  function bit controls_are_known(bmu_seq_item tr);
    return !$isunknown({tr.rst_l, tr.ap, tr.csr_ren_in});
  endfunction


  // Legal NOP selected by the approved project behavior.
  function bit no_operation_selected(
    bmu_seq_item tr,
    bit          control_is_known
  );
    return control_is_known         &&
           (tr.valid_in   === 1'b1) &&
           (tr.ap         ==  '0)   &&
           (tr.csr_ren_in ==  1'b0);
  endfunction


  // Check the registered result predicted from the preceding sampled cycle.
  function void check_previous_result(bmu_seq_item tr);
    if (!have_result_expectation)
      return;

    result_check_count++;

    if (tr.result_ff === expected_result_ff) begin
      result_pass_count++;

      `uvm_info(
        "BMU_RESULT_PASS",
        $sformatf(
          {"observe_cycle=%0d source_cycle=%0d operation=%s ",
           "expected=0x%08h actual=0x%08h"},
          observed_cycle,
          expected_source_cycle,
          expected_operation,
          expected_result_ff,
          tr.result_ff
        ),
        UVM_MEDIUM
      )
    end
    else begin
      result_fail_count++;

      `uvm_error(
        "BMU_RESULT_MISMATCH",
        $sformatf(
          {"observe_cycle=%0d source_cycle=%0d operation=%s ",
           "expected=0x%08h actual=0x%08h | ",
           "source_rst_l=%0b source_valid=%0b source_ap=0x%0h ",
           "source_csr_ren=%0b source_csr_data=0x%08h ",
           "source_a=0x%08h source_b=0x%08h"},
          observed_cycle,
          expected_source_cycle,
          expected_operation,
          expected_result_ff,
          tr.result_ff,
          expected_source_rst_l,
          expected_source_valid_in,
          expected_source_ap,
          expected_source_csr_ren,
          expected_source_csr_data,
          expected_source_a,
          expected_source_b
        )
      )
    end
  endfunction


  // Check error for the current sampled cycle.
  // This follows the confirmed rule that error does not depend on valid_in.
  function void check_current_error(
    bmu_seq_item tr,
    logic        predicted_error,
    string       current_operation
  );
    error_check_count++;

    if (tr.error === predicted_error) begin
      error_pass_count++;

      `uvm_info(
        "BMU_ERROR_PASS",
        $sformatf(
          {"cycle=%0d operation=%s valid_in=%0b ",
           "expected_error=%0b actual_error=%0b"},
          observed_cycle,
          current_operation,
          tr.valid_in,
          predicted_error,
          tr.error
        ),
        UVM_HIGH
      )
    end
    else begin
      error_fail_count++;

      `uvm_error(
        "BMU_ERROR_MISMATCH",
        $sformatf(
          {"cycle=%0d operation=%s expected_error=%0b actual_error=%0b | ",
           "rst_l=%0b valid_in=%0b ap=0x%0h csr_ren=%0b ",
           "csr_data=0x%08h a=0x%08h b=0x%08h"},
          observed_cycle,
          current_operation,
          predicted_error,
          tr.error,
          tr.rst_l,
          tr.valid_in,
          tr.ap,
          tr.csr_ren_in,
          tr.csr_rddata_in,
          tr.a_in,
          tr.b_in
        )
      )
    end
  endfunction


  // Called once for every transaction published by the monitor.
  function void write(bmu_seq_item tr);
    logic [31:0] predicted_result;
    logic        predicted_error;
    bit          control_is_known;
    bit          result_inputs_are_known;
    bit          no_operation;
    string       current_operation;

    observed_cycle++;
    observed_count++;

    check_previous_result(tr);    // Step 1: Check result_ff from the preceding cycle.


    // Step 2: Decode the current sampled transaction.
    control_is_known = controls_are_known(tr);
    no_operation     = no_operation_selected(tr, control_is_known);

    predicted_result  = 32'hxxxx_xxxx;
    predicted_error   = 1'bx;
    current_operation = "UNKNOWN_OR_SCAN";

    // Step 3: Predict and check error for the current cycle.
    if (control_is_known && (tr.scan_mode === 1'b0)) begin
      model.predict(tr, predicted_result, predicted_error);

      if (no_operation)
        current_operation = "NOP";
      else
        current_operation =
          model.operation_name(model.decode_operation(tr));

      check_current_error(tr, predicted_error, current_operation);
    end
    else begin
      skipped_prediction_count++;

      `uvm_warning(
        "BMU_SB_SKIP",
        $sformatf(
          {"cycle=%0d prediction skipped: rst_l=%b scan_mode=%b ",
           "valid_in=%b ap=0x%0h csr_ren=%b"},
          observed_cycle,
          tr.rst_l,
          tr.scan_mode,
          tr.valid_in,
          tr.ap,
          tr.csr_ren_in
        )
      )
    end

    // Step 4: Build expected result_ff for the following monitored cycle.

    // scan_mode is outside the functional-verification scope.
    if (tr.scan_mode !== 1'b0) begin
      have_result_expectation = 1'b0;
    end

    // A result cannot be predicted when reset or valid contains X/Z.
    else if ($isunknown({tr.rst_l, tr.valid_in})) begin
      have_result_expectation = 1'b0;
    end

    // Synchronous reset clears result_ff in the next monitored cycle.
    else if (tr.rst_l == 1'b0) begin
      reset_count++;

      expected_result_ff      = 32'h0000_0000;
      expected_operation      = "RESET";
      have_result_expectation = 1'b1;
      save_expected_source(tr);
    end

    // Legal NOP writes zero and does not raise error.
    else if (no_operation) begin
      valid_request_count++;
      nop_request_count++;

      expected_result_ff      = 32'h0000_0000;
      expected_operation      = "NOP";
      have_result_expectation = 1'b1;
      save_expected_source(tr);
    end

    // A valid operation updates result_ff using the model prediction.
    else if (tr.valid_in == 1'b1) begin
      result_inputs_are_known =
        !$isunknown({
          tr.ap,
          tr.csr_ren_in,
          tr.csr_rddata_in,
          tr.a_in,
          tr.b_in
        });

      if (result_inputs_are_known && control_is_known) begin
        valid_request_count++;

        expected_result_ff      = predicted_result;
        expected_operation      = current_operation;
        have_result_expectation = 1'b1;
        save_expected_source(tr);
      end
      else begin
        skipped_prediction_count++;
        have_result_expectation = 1'b0;

        `uvm_warning(
          "BMU_SB_UNKNOWN_INPUT",
          $sformatf(
            {"cycle=%0d valid request contains X/Z values; ",
             "result prediction skipped"},
            observed_cycle
          )
        )
      end
    end

    // valid_in=0 means result_ff must keep its previous value.
    else begin
      hold_request_count++;

      // Do not assign expected_result_ff here. It keeps its previous value.
      if (have_result_expectation) begin
        expected_operation = "HOLD(valid_in=0)";
        save_expected_source(tr);
      end
    end
  endfunction


  // Make sure the scoreboard received traffic and performed both check types.
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    if (observed_count == 0) begin
      `uvm_error(
        "BMU_SB_NO_TRAFFIC",
        "The scoreboard received no monitor transactions"
      )
    end

    if (result_check_count == 0) begin
      `uvm_error(
        "BMU_SB_NO_RESULT_CHECKS",
        "The scoreboard performed no result comparisons"
      )
    end

    if (error_check_count == 0) begin
      `uvm_error(
        "BMU_SB_NO_ERROR_CHECKS",
        "The scoreboard performed no error comparisons"
      )
    end
  endfunction


  // Print one final summary that can be used by the regression script.
  function void report_phase(uvm_phase phase);
    int unsigned total_checks;
    int unsigned total_passes;
    int unsigned total_failures;

    super.report_phase(phase);

    total_checks   = result_check_count + error_check_count;
    total_passes   = result_pass_count  + error_pass_count;
    total_failures = result_fail_count  + error_fail_count;

    `uvm_info(
      "BMU_SB_SUMMARY",
      $sformatf(
        {"observed=%0d total_checks=%0d pass=%0d fail=%0d | ",
         "result_checks=%0d result_pass=%0d result_fail=%0d | ",
         "error_checks=%0d error_pass=%0d error_fail=%0d | ",
         "valid_requests=%0d nop_requests=%0d hold_requests=%0d ",
         "resets=%0d skipped=%0d"},
        observed_count,
        total_checks,
        total_passes,
        total_failures,
        result_check_count,
        result_pass_count,
        result_fail_count,
        error_check_count,
        error_pass_count,
        error_fail_count,
        valid_request_count,
        nop_request_count,
        hold_request_count,
        reset_count,
        skipped_prediction_count
      ),
      UVM_NONE
    )
  endfunction

endclass


class bmu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(bmu_scoreboard)

  uvm_analysis_imp #(bmu_seq_item, bmu_scoreboard) analysis_export;

  bmu_reference_model model;

  // Expected registered-result state.
  logic [31:0] expected_result_ff;
  bit          have_result_expectation;

  // Information about the transaction that generated the expected result.
  longint unsigned expected_source_cycle;
  string           expected_operation;

  // Local cycle counter.
  longint unsigned observed_cycle;

  // Activity counters.
  int unsigned observed_count;
  int unsigned reset_count;
  int unsigned valid_request_count;
  int unsigned nop_request_count;
  int unsigned hold_request_count;
  int unsigned skipped_prediction_count;

  // Result-checking counters.
  int unsigned result_check_count;
  int unsigned result_pass_count;
  int unsigned result_fail_count;

  // Error-checking counters.
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

    expected_result_ff      = 32'h0000_0000;
    have_result_expectation = 1'b0;
    expected_source_cycle   = 0;
    expected_operation      = "NONE";
    observed_cycle          = 0;

    observed_count           = 0;
    reset_count              = 0;
    valid_request_count      = 0;
    nop_request_count        = 0;
    hold_request_count       = 0;
    skipped_prediction_count = 0;

    result_check_count = 0;
    result_pass_count  = 0;
    result_fail_count  = 0;

    error_check_count = 0;
    error_pass_count  = 0;
    error_fail_count  = 0;
  endfunction


  // Called once for every transaction published by the monitor.
  function void write(bmu_seq_item tr);

    logic [31:0] predicted_result;
    logic        predicted_error;

    bit control_is_known;
    bit result_input_is_known;
    bit no_operation;

    string current_operation;


    observed_cycle++;
    observed_count++;


    // ----------------------1. Check result_ff expected from the preceding monitored cycle.---------------------------

    if (have_result_expectation) begin
      result_check_count++;

      if (tr.result_ff === expected_result_ff) begin
        result_pass_count++;

        `uvm_info(
          "BMU_RESULT_PASS",
          $sformatf(
    {
      "PASS observe_cycle=%0d source_cycle=%0d operation=%s ",
      "expected_result=0x%08h actual_result=0x%08h"
    },
    observed_cycle,
    expected_source_cycle,
    expected_operation,
    expected_result_ff,
    tr.result_ff
  ),
  UVM_MEDIUM )

       
      end
      else begin
        result_fail_count++;

        `uvm_error(
  "BMU_RESULT_MISMATCH",
  $sformatf(
    {
      "FAIL observe_cycle=%0d source_cycle=%0d operation=%s ",
      "expected_result=0x%08h actual_result=0x%08h"
    },
    observed_cycle,
    expected_source_cycle,
    expected_operation,
    expected_result_ff,
    tr.result_ff
  )
)
      end
    end


    // ----------2. Determine whether the current control values are known.---

    control_is_known =
      !$isunknown({
        tr.rst_l,
        tr.ap,
        tr.csr_ren_in
      });

    no_operation =
      control_is_known             &&
      (tr.valid_in   === 1'b1)     &&
      (tr.ap         ==  '0)       &&
      (tr.csr_ren_in ==  1'b0);


    // --------------3. Predict and check error for the current monitored cycle.------------------------------

    if (control_is_known && (tr.scan_mode === 1'b0)) begin

      model.predict(
        tr,
        predicted_result,
        predicted_error
      );

      if (no_operation)
        current_operation = "NOP";
      else
        current_operation =
          model.operation_name(model.decode_operation(tr));

      error_check_count++;

      if (tr.error === predicted_error) begin
        error_pass_count++;

        `uvm_info(
          "BMU_ERROR_PASS",
          $sformatf(
            "cycle=%0d operation=%s error=%0b valid_in=%0b",
            observed_cycle,
            current_operation,
            tr.error,
            tr.valid_in
          ),
          UVM_HIGH
        )
      end
      else begin
        error_fail_count++;

        `uvm_error(
          "BMU_ERROR_MISMATCH",
          $sformatf(
            "cycle=%0d operation=%s valid_in=%0b ap=0x%0h expected_error=%0b actual_error=%0b",
            observed_cycle,
            current_operation,
            tr.valid_in,
            tr.ap,
            predicted_error,
            tr.error
          )
        )
      end
    end
    else begin
      predicted_result  = 32'hxxxx_xxxx;
      predicted_error   = 1'bx;
      current_operation = "UNKNOWN_OR_SCAN";

      skipped_prediction_count++;

      `uvm_warning(
        "BMU_SB_SKIP",
        $sformatf(
          "cycle=%0d skipped prediction: rst_l=%b scan_mode=%b valid_in=%b",
          observed_cycle,
          tr.rst_l,
          tr.scan_mode,
          tr.valid_in
        )
      )
    end


    // ----------------------4. Build expected result_ff for the following monitored cycle.-----------------------------

    if (tr.scan_mode !== 1'b0) begin

      // scan_mode is outside functional-verification scope.
      have_result_expectation = 1'b0;

    end
    else if ($isunknown({tr.rst_l, tr.valid_in})) begin

      have_result_expectation = 1'b0;

    end
    else if (tr.rst_l == 1'b0) begin

      // Synchronous reset produces result_ff = 0 in the next cycle.
      reset_count++;

      expected_result_ff      = 32'h0000_0000;
      expected_source_cycle   = observed_cycle;
      expected_operation      = "RESET";
      have_result_expectation = 1'b1;

    end
    else if (no_operation) begin

      // Legal NOP:
      // valid_in=1, ap='0, csr_ren_in=0.
      // result_ff must become zero in the next cycle.
      valid_request_count++;
      nop_request_count++;

      expected_result_ff      = 32'h0000_0000;
      expected_source_cycle   = observed_cycle;
      expected_operation      = "NOP";
      have_result_expectation = 1'b1;

    end
    else if (tr.valid_in == 1'b1) begin

      result_input_is_known =
        !$isunknown({
          tr.ap,
          tr.csr_ren_in,
          tr.csr_rddata_in,
          tr.a_in,
          tr.b_in
        });

      if (result_input_is_known && control_is_known) begin

        // predicted_result was calculated above by the untimed model.
        valid_request_count++;

        expected_result_ff      = predicted_result;
        expected_source_cycle   = observed_cycle;
        expected_operation      = current_operation;
        have_result_expectation = 1'b1;

      end
      else begin

        skipped_prediction_count++;
        have_result_expectation = 1'b0;

        `uvm_warning(
          "BMU_SB_UNKNOWN_INPUT",
          $sformatf(
            "cycle=%0d valid request contains X/Z values; result prediction skipped",
            observed_cycle
          )
        )
      end

    end
    else begin

      // valid_in == 0:
      // Do not assign a new value to expected_result_ff.
      // It therefore retains its previous value.
      hold_request_count++;

      if (have_result_expectation) begin
        expected_source_cycle = observed_cycle;
        expected_operation    = "HOLD(valid_in=0)";
      end

    end
  endfunction


  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    if (observed_count == 0) begin
      `uvm_error(
        "BMU_SB_NO_TRAFFIC",
        "The scoreboard received no monitor transactions"
      )
    end

    if ((result_check_count == 0) &&
        (error_check_count  == 0)) begin
      `uvm_error(
        "BMU_SB_NO_CHECKS",
        "The scoreboard performed no comparisons"
      )
    end
  endfunction


  function void report_phase(uvm_phase phase);

    int unsigned total_checks;
    int unsigned total_passes;
    int unsigned total_failures;

    super.report_phase(phase);

    total_checks =
      result_check_count +
      error_check_count;

    total_passes =
      result_pass_count +
      error_pass_count;

    total_failures =
      result_fail_count +
      error_fail_count;

    `uvm_info(
      "BMU_SB_SUMMARY",
      $sformatf(
        {
          "observed=%0d total_checks=%0d pass=%0d fail=%0d | ",
          "result_checks=%0d result_pass=%0d result_fail=%0d | ",
          "error_checks=%0d error_pass=%0d error_fail=%0d | ",
          "valid_requests=%0d nop_requests=%0d hold_requests=%0d ",
          "resets=%0d skipped=%0d"
        },
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
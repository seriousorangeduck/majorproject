// Every coin's OPEN value is compared against the expected value;
// the testbench prints PASS/FAIL per check and a final verdict.
`timescale 1ns/1ns
module tb_vending;
    reg  clk = 0, rst = 1, N = 0, D = 0;
    wire OPEN;
    integer errors = 0;
    vending_machine uut (.clk(clk), .rst(rst), .N(N), .D(D), .OPEN(OPEN));
    always #5 clk = ~clk;
    task coin(input n_i, input d_i, input exp_open);
        begin
            @(negedge clk); N = n_i; D = d_i;
            #1;
            if (OPEN !== exp_open) begin
                errors = errors + 1;
                $display("[%0t] *** FAIL *** OPEN=%b (expected %b) state=%b",
                         $time, OPEN, exp_open, uut.state);
            end else
                $display("[%0t] PASS: OPEN=%b (state=%b)",
                         $time, OPEN, uut.state);
            @(negedge clk); N = 0; D = 0;
        end
    endtask

    task idle(input integer cycles);
        integer i;
        for (i = 0; i < cycles; i = i + 1) @(negedge clk);
    endtask

    initial begin
        $dumpfile("vending.vcd");
        $dumpvars(0, tb_vending);

        idle(2); rst = 0; idle(1);

        $display("=== T1: N, N, N = 15c ===");
        coin(1,0,0); coin(1,0,0); coin(1,0,1);

        $display("=== T2: N, D = 15c ===");
        coin(1,0,0); coin(0,1,1);

        $display("=== T3: D, N = 15c ===");
        coin(0,1,0); coin(1,0,1);

        $display("=== T4: D, D = 20c (no change) ===");
        coin(0,1,0); coin(0,1,1);

        $display("=== T5: N, N, D = 20c (>=15c rule) ===");
        coin(1,0,0); coin(1,0,0); coin(0,1,1);

        $display("=== T6: fresh transaction after D, D ===");
        coin(0,1,0); coin(0,1,1);
        coin(1,0,0); coin(0,1,1);

        $display("=== T7: mid-transaction reset recovery ===");
        coin(1,0,0);
        @(negedge clk); rst = 1;
        @(negedge clk); rst = 0; idle(1);
        coin(0,1,0); coin(1,0,1);

        if (errors == 0) $display(">>> ALL TESTS PASSED <<<");
        else             $display(">>> %0d CHECK(S) FAILED <<<", errors);
        $finish;
    end
endmodule

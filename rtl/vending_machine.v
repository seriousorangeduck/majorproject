// Price: 15 cents. Accepts N (nickel, 5c) and D (dime, 10c).
//   N,N,N / N,D / D,N  (15c) -> dispense
//   D,D (20c)-> dispense, extra 5c retained (no change)
// 3-state Mealy machine, async active-high reset,
// unused encoding 2'b11 self-corrects to S0.

module vending_machine (
    input  wire clk,
    input  wire rst,
    input  wire N,       // nickel pulse (one clock)
    input  wire D,       // dime pulse  (one clock)
    output wire OPEN     // 1 = dispense newspaper
);

    localparam S0 = 2'b00,   // 0 cents
               S1 = 2'b01,   // 5 cents
               S2 = 2'b10;   // 10 cents

    reg [1:0] state, next;

    // ---- State register: async reset to S0 ----
    always @(posedge clk or posedge rst)
        if (rst) state <= S0;
        else     state <= next;

    // ---- Next-state logic ----
    always @* begin
        case (state)
            S0: if (D)      next = S2;   // 0 + 10 = 10
                else if (N) next = S1;   // 0 +  5 =  5
                else        next = S0;   // idle

            S1: if (D)      next = S0;   // 5 + 10 = 15 -> paper, reset
                else if (N) next = S2;   // 5 +  5 = 10
                else        next = S1;   // idle

            S2: if (N || D) next = S0;   // 10+5 = 15 -> paper, reset
                                              // 10+10 = 20 -> paper, keep 5c
                else        next = S2;   // idle

            default: next = S0;          // 2'b11 -> safe recovery
        endcase
    end

    // ---- Mealy output: dispense when this coin reaches >= 15c ----
    assign OPEN = (state == S1 &&  D       ) ||   //  5 + 10 = 15
                  (state == S2 && (N || D) );     // 10 + 5/10 = 15/20

endmodule
// Price: 15 cents. Accepts N (nickel, 5c) and D (dime, 10c).
//   N,N,N / N,D / D,N  (15c) -> dispense
//   D,D (20c)-> dispense, extra 5c retained (no change)
// 3-state Mealy machine, async active-high reset,
// unused encoding 2'b11 self-corrects to S0.
module vending_machine (
    input  wire clk,
    input  wire rst,
    input  wire N,
    input  wire D,
    output wire OPEN 
);
    localparam S0 = 2'b00,
               S1 = 2'b01,
               S2 = 2'b10;

    reg [1:0] state, next;
    always @(posedge clk or posedge rst)
        if (rst) state <= S0;
        else     state <= next;
    always @* begin
        case (state)
            S0: if (D)      next = S2;
                else if (N) next = S1;
                else        next = S0;

            S1: if (D)      next = S0;
                else if (N) next = S2;
                else        next = S1;

            S2: if (N || D) next = S0;  
                else        next = S2;

            default: next = S0;
        endcase
    end
    assign OPEN = (state == S1 &&  D       ) ||
                  (state == S2 && (N || D) );

endmodule

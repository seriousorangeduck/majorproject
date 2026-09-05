// Gate-level implementation from the K-map minimized equations:
//   D1   = Q1'Q0'D + Q1'Q0N 
//   D0   = Q1'Q0'N
//   OPEN = Q1'Q0D + Q1(N+D)
module vending_machine_structural (
    input  wire clk, rst, N, D,
    output wire OPEN
);
    wire q1, q0, d1, d0;

    assign d1   = ~q1 & ((~q0 & D) | (q0 & N));
    assign d0   = ~q1 & ~q0 & N;
    assign OPEN = (~q1 & q0 & D) | (q1 & (N | D));

    dff ff1 (.q(q1), .d(d1), .clk(clk), .rst(rst));
    dff ff0 (.q(q0), .d(d0), .clk(clk), .rst(rst));
endmodule

module dff (output reg q, input wire d, clk, rst);
    always @(posedge clk or posedge rst)
        if (rst) q <= 1'b0;
        else     q <= d;
endmodule
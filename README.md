# Design & Verification of Newspaper Vending Machine FSM

The controller for a newspaper vending machine is a digital design project that was created as a finite state machine, implemented in Verilog, and validated using a self-checking testbench. Each of the seven tests is successful.

Live simulation: https://edaplayground.com/x/Nkkd

## Details
The cost of a newspaper is fifteen cents.

Coins that are accepted include nickel (N = 5¢) and dime (D = 10¢).

When credit reaches > 15¢, a newspaper is distributed.

The machine keeps the excess money; no change is given back.

| Sequence | Total | Result |
|----------|-------|--------|
| N, D     | 15¢   |  Dispense |
| D, N     | 15¢   |  Dispense |
| N, N, N  | 15¢   |  Dispense |
| D, D     | 20¢   |  Dispense (extra 5¢ retained) |

## Highlights of design
- **3 states (0¢ / 5¢ / 10¢), provably minimal** – Any coin that increases credit to 15¢ or more instantly terminates the transaction, so {0, 5, 10} are the only credit values ever recorded. Each of the three states can be distinguished in pairs.
Every new transaction provably begins at 0¢ because the **retained 5¢ after D+D needs no extra state** never affects future behavior.
The qualifying coin (the conditional output box on the ASM chart) is asserted in the same clock cycle as the **Mealy output** `OPEN`.The unused encoding is `2'b11`; asynchronous active-high reset
In a single cycle, **self-corrects to S0**.

## Files

| Path | Contents |
|------|----------|
| `rtl/vending_machine.v` | FSM, behavioral RTL |
| `rtl/vending_machine_structural.v` | Gate-level version built from the K-map minimized equations |
| `sim/tb_vending.v` | Self-checking testbench (7 directed tests, automatic pass/fail verdict) |
| `docs/report.pdf` | Full project report |
| `docs/asm_chart.png`, `docs/asm_chart.drawio` | ASM chart figure and its editable source |

## Running the simulation

With Icarus Verilog:

```bash
iverilog -o sim rtl/vending_machine.v sim/tb_vending.v
vvp sim
```


## Verification results

| Test | Stimulus | Verifies | Result |
|------|----------|----------|--------|
| T1 | N, N, N (15¢) | exact-fare combination | PASS |
| T2 | N, D (15¢) | exact-fare combination | PASS |
| T3 | D, N (15¢) | exact-fare combination | PASS |
| T4 | D, D (20¢) | overpayment: dispense once, no change | PASS |
| T5 | N, N, D (20¢) | generalized ≥15¢ rule | PASS |
| T6 | D, D, then N, D | new transaction starts at 0¢ (retained 5¢ ignored) | PASS |
| T7 | mid-transaction reset, then D, N | reset recovery from any state | PASS |

Every coin insertion is checked against the expected `OPEN` value; the
testbench prints a PASS/FAIL line per check and a final verdict:

```
>>> ALL TESTS PASSED <<<
```

# Newspaper Vending Machine FSM — Design & Verification

Digital design project: the controller for a newspaper vending machine, designed as a finite state machine, implemented in Verilog, and verified with a self-checking testbench. **All 7 tests pass.**

**Live simulation:** [[EDA Playground — click Run]](https://edaplayground.com/x/Nkkd)  ← paste your shareable link here

## Specification

- Newspaper price: **15¢**
- Accepted coins: **nickel (N = 5¢)** and **dime (D = 10¢)**
- A newspaper is dispensed when credit reaches **≥ 15¢**
- **No change is returned** — overpayment is retained by the machine

| Sequence | Total | Result |
|----------|-------|--------|
| N, D     | 15¢   |  Dispense |
| D, N     | 15¢   |  Dispense |
| N, N, N  | 15¢   |  Dispense |
| D, D     | 20¢   |  Dispense (extra 5¢ retained) |

## Design highlights

- **3 states (0¢ / 5¢ / 10¢), provably minimal** — any coin that brings credit to
  15¢ or more ends the transaction immediately, so the only credit values ever
  stored are {0, 5, 10}. All three states are pairwise distinguishable.
- The **retained 5¢ after D+D needs no extra state** — it never influences
  future behavior, so every new transaction provably starts at 0¢.
- **Mealy output** `OPEN` — asserts in the same clock cycle as the qualifying
  coin (the conditional output box on the ASM chart).
- Asynchronous active-high reset; the unused encoding `2'b11`
  **self-corrects to S0** in one cycle.

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

# soc_top v1 Implementation Notes

## Scope

This v1 creates the `soc_top` verification framework described in `doc/soc_testbench_plan.md`.
The original `tb/` flow is left unchanged.

## Implemented

- `+CASE_NAME=fm_test*` selects `FM_MODE` and `soc_top_test_fm_base`.
- `+CASE_NAME=soc_top*` selects `UVM_MODE` and `soc_top_test_uvm_base`.
- Invalid `CASE_NAME` is rejected by `soc_top/sim/Makefile` and by `tb_top.sv`.
- Firmware preload is enabled only in `FM_MODE`.
- UVM mode skips firmware preload.
- AHB monitor observes the CPU data AHB master interface listed in the plan.
- Scoreboard detects the existing firmware pass/fail protocol at `0x20007c50`.
- UVM smoke sequence uses `uvm_hdl_force` on the CPU AHB master wires as the v1 active-master hook.

## Remaining Integration Work

- Replace the local AHB monitor/force hook with Cadence AHB VIP wrapper/config once the VIP source list and agent instance policy are finalized.
- Expand `soc_top_reg_access_vseq` from one smoke write into reusable read/write register tasks.
- Add real firmware build wrapper under `soc_top/sw` for `fm_test*` cases.

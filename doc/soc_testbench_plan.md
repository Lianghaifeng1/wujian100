# soc_top SoC Testbench Plan

## 1. Conclusion

The SoC verification environment uses `soc_top` as the environment name. All class names, package names, file prefixes, and directory naming use `soc_top` directly, without any `wujian100_` prefix.

The first version only builds the base framework. It does not add GPIO, UART, SPI, I2C, or any other peripheral-specific testcase.

The testcase name is the only mode selector:

- `fm_test*`: C firmware testcase. The CPU runs normally, and the AHB VIP only monitors the CPU AHB interface.
- `soc_top*`: pure UVM testcase. The AHB VIP takes over the CPU AHB interface and replaces the CPU to configure SoC registers. No C code is compiled or loaded.

## 2. Target Directory

The plan document is stored under the existing project document directory:

```text
doc/soc_testbench_plan.md
```

The future verification environment body should be created under:

```text
soc_top/
├── cfg/
├── common_ifs/
├── tb/
├── uvm/
├── sim/
├── sw/
└── docs/
```

Directory responsibilities:

- `soc_top/cfg`: environment YAML/config files, testcase mapping, address map, and default knobs.
- `soc_top/common_ifs`: common SystemVerilog interfaces such as clock/reset and SoC control interface.
- `soc_top/tb`: `tb_top`, DUT instantiation, CPU AHB force/release logic, and firmware preload logic.
- `soc_top/uvm`: UVM environment, tests, virtual sequences, scoreboard, and shared transaction types.
- `soc_top/sim`: xrun, Verisium, waveform, and regression entry scripts.
- `soc_top/sw`: firmware build wrapper and output area used only by `fm_test*`.
- `soc_top/docs`: later implementation notes and detailed testplan documents.

## 3. Testcase Naming Rule

The environment must parse `+CASE_NAME=<name>` at simulation start.

Valid testcase names:

- `fm_test*`
- `soc_top*`

Invalid testcase names must report a fatal configuration error and stop simulation.

Mode mapping:

| CASE_NAME pattern | Mode | Default UVM test | C build/load | AHB VIP role | CPU role |
|---|---|---|---|---|---|
| `fm_test*` | `FM_MODE` | `soc_top_test_fm_base` | enabled | passive monitor | normal CPU execution |
| `soc_top*` | `UVM_MODE` | `soc_top_test_uvm_base` | disabled | active master | isolated or held in reset |

No additional plusarg should be required to select `FM_MODE` or `UVM_MODE`.

## 4. AHB VIP Connection Strategy

The AHB VIP is connected to the CPU master AHB interface.

The first target interface is the CPU data AHB master port already used by `tb/busmnt.v`:

```text
cpu_hmain0_m2_haddr
cpu_hmain0_m2_hburst
cpu_hmain0_m2_hprot
cpu_hmain0_m2_hsize
cpu_hmain0_m2_htrans
cpu_hmain0_m2_hwdata
cpu_hmain0_m2_hwrite
hmain0_cpu_m2_hrdata
hmain0_cpu_m2_hready
hmain0_cpu_m2_hresp
```

### 4.1 FM_MODE: `fm_test*`

In `FM_MODE`, the CPU owns the AHB interface.

Required behavior:

- Do not force CPU AHB signals.
- Do not isolate the CPU from the SoC.
- Load firmware image if `+SW_PAT=` is provided or resolved by the run script.
- Let CPU fetch and execute firmware normally.
- Configure AHB VIP as passive monitor.
- Use AHB VIP monitor traffic and scoreboard logic to detect firmware pass/fail and collect bus logs.

### 4.2 UVM_MODE: `soc_top*`

In `UVM_MODE`, AHB VIP replaces the CPU as the active register access master.

Required behavior:

- Do not compile C code.
- Do not load `test.pat`.
- Configure AHB VIP as active master.
- Force or mux the CPU AHB master interface so VIP drives the SoC-side AHB signals.
- Prevent CPU and VIP from driving the same AHB master interface at the same time.
- By default, keep the CPU in reset or isolate its AHB output path to avoid bus contention.
- Release all forced CPU AHB signals when switching back to firmware mode in a fresh simulation.

Implementation preference:

- Use `force/release` or a TB-only mux layer.
- Do not modify RTL for v1.
- If direct force is unstable, hold CPU reset in `UVM_MODE` as the default implementation.

## 5. Naming Convention

All class names, package names, type names, and generated file prefixes use `soc_top`.

Packages:

```text
soc_top_env_pkg
soc_top_test_pkg
```

Core classes:

```text
soc_top_cfg
soc_top_dut_cfg
soc_top_env
soc_top_scoreboard
soc_top_common_transaction
```

Test classes:

```text
soc_top_test_common
soc_top_test_base
soc_top_test_fm_base
soc_top_test_uvm_base
```

Virtual sequence classes:

```text
soc_top_test_base_vseq
soc_top_reg_access_vseq
```

Interface and virtual interface names:

```text
soc_top_dut_intf
soc_top_dut_vif
soc_top_ctrl_if
```

Representative file names:

```text
soc_top_cfg.sv
soc_top_dut_cfg.sv
soc_top_env_pkg.sv
soc_top_env.sv
soc_top_scoreboard.sv
soc_top_common_transaction.sv
soc_top_test_pkg.sv
soc_top_test_common.sv
soc_top_test_base.sv
soc_top_test_fm_base.sv
soc_top_test_uvm_base.sv
soc_top_test_base_vseq.sv
soc_top_reg_access_vseq.sv
```

## 6. Top Testbench Behavior

`soc_top/tb/src/tb_top.sv` is responsible for:

- Generate EHS clock, ELS clock, JTAG clock if needed, and SoC reset.
- Instantiate `wujian100_open_top`.
- Parse `+CASE_NAME=<name>`.
- Determine `FM_MODE` or `UVM_MODE` only from `CASE_NAME`.
- Parse `+SW_PAT=<path>` only in `FM_MODE`.
- Load firmware pattern file only in `FM_MODE`.
- Skip firmware preload completely in `UVM_MODE`.
- Configure AHB VIP HDL path and active/passive mode.
- Configure `soc_top_cfg` through `uvm_config_db`.
- Control CPU AHB force/release or TB mux mode.
- Call `run_test()`.

The top testbench must not bind or compile any old peripheral companion testcase such as GPIO, UART, SPI, or I2C helper Verilog modules in v1.

## 7. Firmware Flow

Firmware flow is enabled only for `fm_test*`.

The existing project flow should be reused:

```text
C source -> ELF -> HEX -> PAT -> SRAM preload -> CPU execution
```

Existing files and scripts to reuse:

- `lib/Makefile`
- `lib/crt0.s`
- `lib/linker.lcf`
- `tools/Srec2vmem.py`
- Current SRAM preload logic from `tb/tb.v`

Firmware result protocol remains unchanged:

| Address | Data | Meaning |
|---|---:|---|
| `0x20007c50` | `0x00002002` | firmware pass |
| `0x20007c50` | `0x00001001` | firmware fail |
| `0x20007c50` | other value | printf character or firmware output |
| `0x20007c60` to `0x20007c9c` | register value | GPR dump area |

The UVM scoreboard should detect this protocol through AHB monitor transactions.

## 8. UVM Mode Register Access

Pure UVM testcase flow is enabled only for `soc_top*`.

Required base behavior:

- AHB VIP becomes active master.
- CPU is isolated or held in reset.
- `soc_top_reg_access_vseq` provides basic AHB read/write tasks.
- The base smoke sequence performs a minimal read/write access to prove that VIP can drive the SoC bus path.
- The monitor records all AHB transactions.
- The scoreboard checks timeout, protocol completion, and basic response validity.

No peripheral-specific register sequence is required in v1.

## 9. UVM Components

### 9.1 `soc_top_cfg`

Minimum fields:

```systemverilog
string case_name;
soc_top_mode_e soc_mode;
bit enable_sw_load;
bit enable_ahb_active;
bit enable_ahb_monitor;
bit hold_cpu_in_reset_in_uvm_mode;
string sw_pat_path;
int unsigned timeout_cycles;
int unsigned idle_cycles;
```

Default behavior:

- `fm_test*` sets `soc_mode = FM_MODE`.
- `soc_top*` sets `soc_mode = UVM_MODE`.
- `FM_MODE` sets `enable_sw_load = 1`, `enable_ahb_active = 0`, `enable_ahb_monitor = 1`.
- `UVM_MODE` sets `enable_sw_load = 0`, `enable_ahb_active = 1`, `enable_ahb_monitor = 1`.
- `hold_cpu_in_reset_in_uvm_mode = 1` by default.

### 9.2 `soc_top_env`

Minimum components:

- AHB VIP active/passive master handle.
- AHB VIP passive monitor handle if a separate monitor agent is used.
- `soc_top_scoreboard`.

Do not instantiate GPIO, UART, SPI, I2C, or other peripheral agents in v1.

### 9.3 `soc_top_scoreboard`

Responsibilities:

- In `FM_MODE`, detect firmware pass/fail magic writes.
- In `FM_MODE`, capture firmware printf output.
- In `FM_MODE`, optionally dump GPR values.
- In `UVM_MODE`, check that AHB VIP transactions complete.
- In both modes, check timeout.
- In both modes, write a clear final PASS/FAIL result to simulation log.

No full reference model is required in v1.

## 10. Tests and Sequences

Only base tests are required.

Test classes:

- `soc_top_test_common`: shared case parsing and common final checks.
- `soc_top_test_base`: base build/connect/config logic.
- `soc_top_test_fm_base`: firmware case base test for `fm_test*`.
- `soc_top_test_uvm_base`: pure UVM base test for `soc_top*`.

Virtual sequences:

- `soc_top_test_base_vseq`: common sequence base.
- `soc_top_reg_access_vseq`: basic AHB VIP register access sequence.

Default mapping:

| CASE_NAME pattern | UVM_TESTNAME |
|---|---|
| `fm_test*` | `soc_top_test_fm_base` |
| `soc_top*` | `soc_top_test_uvm_base` |

## 11. Simulation Entry

Example commands:

```bash
cd soc_top/sim
make run CASE_NAME=fm_test_smoke SW_PAT=/abs/path/test.pat
make run CASE_NAME=soc_top_smoke
```

Run script behavior:

- If `CASE_NAME` starts with `fm_test`, use `soc_top_test_fm_base`.
- If `CASE_NAME` starts with `soc_top`, use `soc_top_test_uvm_base`.
- If `CASE_NAME` starts with `fm_test`, allow firmware build or require `SW_PAT`.
- If `CASE_NAME` starts with `soc_top`, skip firmware build and do not require `SW_PAT`.
- If `CASE_NAME` is invalid, stop before running xrun.

Recommended plusargs:

```text
+CASE_NAME=<name>
+SW_PAT=<path>
+UVM_TESTNAME=<test>
+WAVE_DUMP_EN
+UVM_TIMEOUT=<time>,NO
```

## 12. Base Test Plan

| ID | Feature | Scenario | Precondition | Stimulus | Expected Check | Coverage Link | Priority | Status |
|---|---|---|---|---|---|---|---|---|
| SOC_BASE_001 | Case mode select | `CASE_NAME=soc_top_smoke` selects UVM mode | Valid xrun compile | Run `soc_top_smoke` | `soc_mode=UVM_MODE`, no firmware load | mode_cp | P0 | Planned |
| SOC_BASE_002 | Case mode select | `CASE_NAME=fm_test_smoke` selects FM mode | Valid `test.pat` | Run `fm_test_smoke` | `soc_mode=FM_MODE`, firmware load enabled | mode_cp | P0 | Planned |
| SOC_BASE_003 | Invalid case | Unsupported case name | None | Run `CASE_NAME=abc_test` | Fatal configuration error | mode_cp | P0 | Planned |
| SOC_BASE_004 | AHB VIP active | VIP replaces CPU in UVM mode | `soc_top*` case | Start basic AHB write/read vseq | VIP transaction completes, monitor sees access | ahb_mode_cp | P0 | Planned |
| SOC_BASE_005 | CPU isolation | CPU does not contend with VIP | `soc_top*` case | Run active VIP access | No multi-driver or bus contention | ahb_mode_cp | P0 | Planned |
| SOC_BASE_006 | AHB VIP passive | VIP monitors CPU in FM mode | `fm_test*` case | Firmware executes bus accesses | Monitor captures CPU AHB transactions | ahb_mode_cp | P0 | Planned |
| SOC_BASE_007 | Firmware pass | C case reports pass magic | Firmware image exists | Firmware writes `0x2002` to `0x20007c50` twice | Scoreboard reports PASS | fw_status_cp | P0 | Planned |
| SOC_BASE_008 | Firmware fail | C case reports fail magic | Firmware image exists | Firmware writes `0x1001` to `0x20007c50` twice | Scoreboard reports FAIL | fw_status_cp | P0 | Planned |
| SOC_BASE_009 | Firmware printf | Firmware writes printable bytes | FM mode | Firmware writes other data to `0x20007c50` | Characters captured in log | fw_output_cp | P1 | Planned |
| SOC_BASE_010 | Timeout | UVM mode timeout | `soc_top*` case | Force no completion or wait beyond timeout | UVM fatal timeout | timeout_cp | P0 | Planned |
| SOC_BASE_011 | Timeout | FM mode timeout | `fm_test*` case | Firmware never reports pass/fail | UVM fatal timeout | timeout_cp | P0 | Planned |

## 13. Assumptions

- The official environment directory is `soc_top`.
- The official plan document is `doc/soc_testbench_plan.md`.
- All UVM names use `soc_top` without a chip or project prefix.
- C firmware testcase names always start with `fm_test`.
- Pure UVM testcase names always start with `soc_top`.
- Mode selection depends only on `CASE_NAME`.
- `soc_top*` mode may keep CPU in reset by default.
- v1 does not include GPIO, UART, SPI, I2C, timer, WDT, DMA, or other peripheral-specific testcases.
- v1 does not require a full RAL model or full reference model.
- v1 uses xrun/Xcelium as the primary simulator.


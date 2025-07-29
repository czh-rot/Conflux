# Conflux

> **Conflux** is an efficient, update‑resilient **Keyword Private Information Retrieval (PIR)** system designed for dynamic databases. It combines a *two‑phase cryptographic protocol* with a *heterogeneous SmartSSD + GPU accelerator stack* to deliver near–Index‑PIR performance while natively supporting inserts, deletes, and real‑time updates.

------

## ✨ Key Highlights

| Capability                                                   | Why it matters                                               |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Two‑phase retrieval** (oblivious filtering ➜ precise equality) | Removes rigid keyword‑to‑index mappings and cuts query complexity by up to 15×. |
| **SmartSSD offload** for Phase 1                             | Executes lightweight homomorphic operations in‑situ to slash host ↔ storage traffic. |
| **GPU acceleration** for Phase 2                             | Harnesses thousands of cores for expensive equality checks and bootstrapping. |
| **Adaptive bucket tuning**                                   | Automatically re‑balances buckets online to keep latency stable as data evolve. |
| **Horizontal scalability**                                   | Achieves near‑linear speed‑ups with up to 8 SmartSSDs.       |
| **Proven efficiency**                                        | Up to 62 × faster than dynamic‑supporting baselines and 2.5 × faster than static schemes. |

------

## 🔖 Table of Contents

1. [Repository Layout](#repository-layout)
2. [Prerequisites](#prerequisites)
3. [Quick Build](#quick-build)
4. [Running the Demo](#running-the-demo)
5. [Benchmarking](#benchmarking)
6. [Dataset Preparation](#dataset-preparation)
7. [Configuration](#configuration)
8. [Development Guide](#development-guide)
9. [Contributing](#contributing)
10. [License](#license)

------

## Repository Layout

```
conflux/
├── host/           # CPU + SmartSSD orchestration (Phase 1 service)
├── kernel/         # FPGA HLS implementation of BFV primitives (Phase 1)
├── phase2/         # GPU kernels & runtime (Phase 2 equality engine)
├── datasets/       # Dataset generator & loaders (RocksDB format)
├── configs/        # YAML configs (bucket sizes, FHE params, thresholds)
├── scripts/        # Build / flash / benchmark helpers
└── docs/           # Paper, figures, architecture diagrams
```

------

## Prerequisites

- **OS** : Ubuntu 22.04 LTS or CentOS 8 (kernel ≥ 5.15)
- **Build tools** : CMake ≥ 3.26, GCC ≥ 9.4 (C++17), Make
- **Acceleration** :
  - NVIDIA GPU with compute 8.9+ and **CUDA Toolkit ≥ 11.4**
  - Xilinx **SmartSSD** (KU15P) or compatible CSD + **Vitis/XRT 2021.2**
- **Libraries** : [HEonGPU ≥ 1.1](https://github.com/Alisah-Ozcan/HEonGPU) (pulled as sub‑module), RocksDB, spdlog

------

## Quick Build

### ⚙️ Prerequisite: SmartSSD Installation

Before building the project, you must first install and configure the **SmartSSD** device along with its firmware.
Please follow the official installation and configuration guide provided by AMD:

👉 [SmartSSD Firmware and Setup Documentation](https://docs.amd.com/v/u/en-US/ug1382-smartssd-csd)

```bash
# 1. Clone recursively to fetch sub‑modules
$ git clone --recursive https://github.com/<org>/conflux.git
$ cd conflux

# 2. (Optional) Synthesize FPGA bitstream for SmartSSD
$ make all TARGET=hw \
       PLATFORM=xilinx_u2_gen3x4_xdma_gc_2_202110_1
# Pre‑built .xclbin images are available under releases/ if you only need to run.

# 3. Build host + GPU components
$ cmake -S . -B build \
        -D HEonGPU_BUILD_BENCHMARKS=ON \
        -D CMAKE_CUDA_ARCHITECTURES=89
$ cmake --build build -j$(nproc)
```

------

## Running the Demo

1. **Flash** the generated `conflux_phase1.xclbin` onto the SmartSSD using `xbutil`.

2. **Load** the sample dataset (≈ 1 M KV pairs) provided in `datasets/quickstart/`:

   ```bash
   $ python3 datasets/load_dataset.py datasets/quickstart/ /mnt/conflux_kv
   ```

3. **Launch** the server:

   ```bash
   $ sudo ./build/bin/conflux_server --config configs/demo.yaml
   ```

4. **Query** from another terminal:

   ```bash
   $ python3 client/query.py "covid_vaccine"
   > latency: 12.7 ms | bucket=217 | result=0x4a6f...
   ```

------

## Benchmarking

To reproduce the EuroSys ’26 results on 8× SmartSSDs & 1× A100:

```bash
$ sudo ./scripts/run_benchmarks.sh --datasets all --smartssd 8 --gpu a100
```

Raw numbers are written to `results/<timestamp>/` in CSV format.

------

## Dataset Preparation

```bash
$ python3 datasets/make_facebook_like.py --size 2^28 --name meta
```

Datasets are stored as RocksDB column families. The server automatically detects and buckets them on first load.

------

## Configuration

| Parameter                          | Location                | Description                                              |
| ---------------------------------- | ----------------------- | -------------------------------------------------------- |
| `num_buckets`                      | `configs/*.yaml`        | Initial bucket count *m* (power‑of‑two recommended).     |
| `tau_lower / tau_upper`            | `configs/*.yaml`        | Adaptive tuning thresholds controlling bucket rebalance. |
| `plaintext_modulus`, `poly_degree` | `configs/fhe.yaml`      | BFV parameters (`T`, `N`).                               |
| `xclbin_path`                      | `configs/hardware.yaml` | Path to Phase 1 bitstream for SmartSSD.                  |

------

## Development Guide

- **Style** : enforced by `.clang-format`.
- **Logging** : [spdlog](https://github.com/gabime/spdlog).
- **Testing** : GoogleTest (run with `ctest`).
- **CI** : GitHub Actions builds host + GPU targets on every push.

------

## Contributing

Pull requests are welcome! Please open an issue first to discuss major changes or new features. Make sure to follow the coding style and include unit tests.

------

## License

Conflux is released under the **Apache License 2.0**. See [LICENSE](https://chatgpt.com/c/LICENSE) for details.

------

## Acknowledgements

Conflux builds on the excellent work of the SEAL and HEonGPU communities and leverages Samsung SmartSSD technology. We thank all upstream contributors for making this research possible.

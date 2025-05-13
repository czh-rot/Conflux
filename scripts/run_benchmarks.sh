#!/usr/bin/env bash
set -euo pipefail
print_usage() { echo "Usage: $0 --datasets <name|all> [--smartssd N] [--gpu a100|other]"; exit 1; }
DATASET="quickstart"; SSDS=1; GPU="any"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --datasets) DATASET="$2"; shift 2;;
    --smartssd) SSDS="$2";   shift 2;;
    --gpu)      GPU="$2";    shift 2;;
    *) print_usage;;
  esac
done
RESULT_DIR="results/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RESULT_DIR"
echo "?? Running benchmarks on dataset=${DATASET}, SmartSSD=${SSDS}, GPU=${GPU}"
sudo ./build/bin/conflux_server --config configs/demo.yaml --bench \
     --dataset "$DATASET" --smartssd "$SSDS" --gpu "$GPU" | tee "$RESULT_DIR/out.log"

# Conflux Architecture (High-Level)

![architecture diagram](img/arch_placeholder.svg)

1. **Phase 1 �C Oblivious Filtering (SmartSSD)**  
   * In-situ BFV EvalMod() + Rotate() to discard non-matching buckets.

2. **Phase 2 �C Precise Equality (GPU)**  
   * Batched decrypt & compare on CUDA cores; bootstrapping when noise grows.

3. **Adaptive Bucket Tuning**  
   * Server monitors `load_factor = sz_max / sz_avg` and triggers
     `rebalance()` when it leaves [`��_lower`, `��_upper`].

> _Full details in our EuroSys ��26 paper (docs/paper.pdf)._

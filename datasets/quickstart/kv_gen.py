#!/usr/bin/env python3
"""
Generate a tiny RocksDB dataset (1 M KV pairs) for Conflux quick-start.
Key:  fixed-length string   "user:{00000000}"
Value:4-byte little-endian  uint32  (just a counter)
"""
import rocksdb, struct, argparse, tqdm, os
def main(path, n=1_000_000):
    os.makedirs(path, exist_ok=True)
    opts = rocksdb.Options(create_if_missing=True)
    db   = rocksdb.DB(os.path.join(path, "db"), opts)
    batch = rocksdb.WriteBatch()
    for i in tqdm.trange(n):
        k = f"user:{i:08d}".encode()
        v = struct.pack("<I", i)
        batch.put(k, v)
        if i % 100_000 == 99_999:   # flush in chunks to keep RAM low
            db.write(batch); batch = rocksdb.WriteBatch()
    db.write(batch)
if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("out", help="output directory")
    p.add_argument("--n", type=int, default=1_000_000)
    main(**vars(p.parse_args()))

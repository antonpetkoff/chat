#!/bin/bash

for benchmark in logs/benchmark_*.log; do
    echo "$benchmark" | sed 's/^benchmark_[0-9]*_\(.*\)\.log$/\1/g'
    cat $benchmark | tail -n 4 | head -n 3
    echo ''
done


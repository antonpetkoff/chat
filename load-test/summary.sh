#!/bin/bash

for benchmark in logs/benchmark_*.log; do
    echo "$benchmark" | sed 's/^benchmark_[0-9]*_\(.*\)\.log$/\1/g'
    cat $benchmark | tail -n 3 | head -n 2
    echo ''
done


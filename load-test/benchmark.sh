#!/bin/bash

if [ "${1}" -le 0 ]; then
    echo "First argument is the number of clients!"
    exit 1
fi

if [ "${2}" -le 0 ]; then
    echo "Second argument is duration of the load test!"
    exit 1
fi


CLIENTS_COUNT=$1
DURATION=$2
COMMANDS="list\r\nsend_all broadcast message\r\n"

mkdir -p logs/

for i in $(seq 1 "${CLIENTS_COUNT}"); do
    USER_NAME=$(uuidgen)
    FIRST_MSG="user ${USER_NAME}\r\n"

    tcpkali "localhost:4040" \
        -e1 "${FIRST_MSG}" \
        -em "${COMMANDS}" \
        --latency-marker \
        --websocket \
        --connections 1 \
        --message-rate 10000 \
        --duration "${DURATION}" &> "logs/benchmark_${i}_${USER_NAME}.log" &

    echo "${i}: ${USER_NAME} connected"
done

echo "Waiting ${DURATION} seconds for load test to finish..."
sleep "${DURATION}"
echo "Load test finished!"


# Chat

## Running the server

`cd apps/server/`
`CHAT_PORT=4040 mix run --no-halt`

## Running the client

`cd apps/client/`
`SERVER_HOST=localhost SERVER_PORT=4040 mix run --no-halt`

## Running the tests

`mix test` in this directory runs all tests

## Architecture

![alt text](documentation/architecture.png "Architecture")

## Peer-to-peer File Transfer Protocol

![alt text](documentation/p2p-file-transfer-protocol.png "P2P File Transfer Protocol")

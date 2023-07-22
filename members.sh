#!/bin/bash
for i in {1..50}
do
    mkdir member-nodes_$i
    mkdir member-nodes_$i/consensus
    rm -rf member-nodes_$i/consensus/beacondata
    rm -rf member-nodes_$i/consensus/genesis.ssz
    rm -rf member-nodes_$i/consensus/validatordata
    rm -rf member-nodes_$i/execution/geth
    rm member-nodes_$i/.env
    docker stop member-nodes_$i-geth-1 member-nodes_$i-beacon-chain-1 member-nodes_$i-validator-1
    docker rm member-nodes_$i-geth-1 member-nodes_$i-beacon-chain-1 member-nodes_$i-validator-1

    cp consensus/config.yml member-nodes_$i/consensus/config.yml
    cp consensus/genesis.ssz member-nodes_$i/consensus/genesis.ssz
    cp member-nodes/docker-compose.yml member-nodes_$i/docker-compose.yml
    cp -r execution member-nodes_$i
    cp .env member-nodes_$i/.env

    # Get random number from 2 to 98 for client diversity
    random_num=$(py random_number.py)
    if [ $i*2 -gt random_num ]
    then 
        echo test
    fi
    cd member-nodes_$i
    #APP_PORT=80 docker compose up --detach
    cd ..
done

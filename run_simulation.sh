#!/bin/bash
declare -i number_of_members=3
declare -i number_of_runs=2
for (( j=1; j<=$number_of_runs; j++ ))
do
    rm -rf consensus/beacondata
    rm -rf consensus/genesis.ssz
    rm -rf consensus/validatordata
    rm -rf execution/geth
    rm -rf .idea/

    rm -rf execution/geth.ipc
    rm -rf .idea/

    NUMBER_OF_VALIDATORS=$((number_of_members*64+64)) docker compose up --detach
    # Sleep for twenty seconds for bootnode to activate, might need to be increased for slower systems
    sleep 20
    ./reset-p2p.sh
    #GETH_TAG=latest GETH_IP=7 PRYSM_TAG=latest PRYSM_IP=8 VAL_TAG=latest VAL_IP=9 VAL_START=64 ./members_old.sh
    for (( i=1; i<=$number_of_members; i++ ))
    do
        mkdir member-nodes_$i
        mkdir member-nodes_$i/consensus
        rm -rf member-nodes_$i/consensus/beacondata
        rm -rf member-nodes_$i/consensus/genesis.ssz
        rm -rf member-nodes_$i/consensus/validatordata
        rm -rf member-nodes_$i/execution/geth
        rm member-nodes_$i/.env

        cp consensus/config.yml member-nodes_$i/consensus/config.yml
        cp consensus/genesis.ssz member-nodes_$i/consensus/genesis.ssz
        cp -r execution member-nodes_$i
        cp .env member-nodes_$i/.env
        cp member-nodes/jwtsecret member-nodes_$i/jwtsecret

        # Only add monitoring to the first bugged client
        if [ $i -gt 1 ]
        then
            # Copy over client without metrics enabled
            cp member-nodes/docker-compose-no-metrics.yml member-nodes_$i/docker-compose.yml
        else
            cp member-nodes/docker-compose.yml member-nodes_$i/docker-compose.yml
        fi

        # Get random number from 2 to 98 for client diversity
        random_num=$(py random_number.py)
        echo $random_num >> random-numbers.txt
        cd member-nodes_$i
        tag=latest
        if [ $random_num -gt $((i*100/number_of_members)) ]
        then
            # Copy over bugged client
            tag=bug_propose
        fi
        GETH_TAG=latest GETH_IP=$((7+i*3)) PRYSM_TAG=$tag PRYSM_IP=$((8+i*3)) VAL_TAG=$tag VAL_IP=$((9+i*3)) VAL_START=$((i*64)) docker compose up --detach
        cd ..
    done
    # Wait 20 mins for run to complete
    sleep 1200
    # Wind-down
    # Get Prometheus data
    curl -XPOST http://localhost:9090/api/v1/admin/tsdb/snapshot
    mkdir run-prometheus/run-$j
    docker cp eth-pos-devnet-prometheus-1:/prometheus/snapshots ./run-prometheus/run-$j
    # Get block data
    py get-blocks.py > run-blocks/run-$j.txt

    # Stop and delete docker containers
    docker stop eth-pos-devnet-create-beacon-chain-genesis-1 eth-pos-devnet-geth-genesis-1 eth-pos-devnet-geth-1 eth-pos-devnet-beacon-chain-1 eth-pos-devnet-validator-1 eth-pos-devnet-prometheus-1 eth-pos-devnet-docker-exporter-1
    docker rm eth-pos-devnet-create-beacon-chain-genesis-1 eth-pos-devnet-geth-genesis-1 eth-pos-devnet-geth-1 eth-pos-devnet-beacon-chain-1 eth-pos-devnet-validator-1 eth-pos-devnet-prometheus-1 eth-pos-devnet-docker-exporter-1
    for (( k=1; k<=$number_of_members; k++ ))
    do
        docker stop member-nodes_$k-geth-1 member-nodes_$k-beacon-chain-1 member-nodes_$k-validator-1
        docker rm member-nodes_$k-geth-1 member-nodes_$k-beacon-chain-1 member-nodes_$k-validator-1
    done
done

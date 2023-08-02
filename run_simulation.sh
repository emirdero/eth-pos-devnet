#!/bin/bash
declare -i number_of_members=1
declare -i number_of_runs=1
bug_ratio=100/$number_of_members

echo "Enter a bug: [1]: Proposal bug [2]: Slashable bug [3]: Chain split bug"
read bug_choice

case $bug_choice in
    1)
        echo proposal bug
        ;;
    2)
        echo slash bug
        ;;
    3)
        echo split bug
        ;;
    *)
        echo "ERROR: unknown bug specified. Please input either 1, 2 or 3"
        exit 1
        ;;
esac

./docker-rm.sh
docker run -d --restart=always -p 9487:9487 -v /var/run/docker.sock:/var/run/docker.sock wywywywy/docker_stats_exporter:latest

for (( j=1; j<=$number_of_runs; j++ ))
do
    sudo rm -rf consensus/beacondata
    sudo rm -rf consensus/genesis.ssz
    sudo rm -rf consensus/validatordata
    sudo rm -rf execution/geth

    NUMBER_OF_VALIDATORS=$((number_of_members*64+64)) docker compose up --detach
    # Sleep for twenty seconds for bootnode to activate, might need to be increased for slower systems
    sleep 20
    ./reset-p2p.sh
    #GETH_TAG=latest GETH_IP=7 PRYSM_TAG=latest PRYSM_IP=8 VAL_TAG=latest VAL_IP=9 VAL_START=64 ./members_old.sh
    for (( i=1; i<=$number_of_members; i++ ))
    do
        mkdir member-nodes_$i
        mkdir member-nodes_$i/consensus
        sudo rm -rf member-nodes_$i/consensus/beacondata
        sudo rm -rf member-nodes_$i/consensus/genesis.ssz
        sudo rm -rf member-nodes_$i/consensus/validatordata
        sudo rm -rf member-nodes_$i/execution/geth

        cp consensus/config.yml member-nodes_$i/consensus/config.yml
        sudo cp consensus/genesis.ssz member-nodes_$i/consensus/genesis.ssz
        sudo cp -r execution member-nodes_$i
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
        random_num=$(python3 random_number.py)
        echo $random_num >> random-numbers.txt
        cd member-nodes_$i
        vc_tag=latest
        bc_tag=latest
        geth_tag=latest
        if [ $random_num -lt $((i*bug_ratio)) ]
        then
            # Copy over bugged client
            case $bug_choice in
            1)
                vc_tag=bug_propose2
                bc_tag=bug_propose2
                ;;
            2)
                vc_tag=bug_slash5
                bc_tag=bug_slash5
                ;;
            3)
                vc_tag=bug_split5
                bc_tag=bug_split5
                geth_tag=split_bug
                ;;
            *)
                echo "ERROR: unknown bug specified. Please input either 1, 2 or 3"
                ;;
            esac
        fi
        GETH_TAG=$geth_tag GETH_IP=$((7+i*3)) PRYSM_TAG=$bc_tag PRYSM_IP=$((8+i*3)) VAL_TAG=$vc_tag VAL_IP=$((9+i*3)) VAL_START=$((i*64)) docker compose up --detach
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
    python3 get-blocks.py > run-blocks/run-normal-$j.txt
    python3 get-blocks-bugged.py > run-blocks/run-bugged-$j.txt

    # Stop and delete docker containers
    docker stop eth-pos-devnet-create-beacon-chain-genesis-1 eth-pos-devnet-geth-genesis-1 eth-pos-devnet-geth-1 eth-pos-devnet-beacon-chain-1 eth-pos-devnet-validator-1 eth-pos-devnet-prometheus-1 eth-pos-devnet-docker-exporter-1
    docker rm eth-pos-devnet-create-beacon-chain-genesis-1 eth-pos-devnet-geth-genesis-1 eth-pos-devnet-geth-1 eth-pos-devnet-beacon-chain-1 eth-pos-devnet-validator-1 eth-pos-devnet-prometheus-1 eth-pos-devnet-docker-exporter-1
    for (( k=1; k<=$number_of_members; k++ ))
    do
        docker stop member-nodes_$k-geth-1 member-nodes_$k-beacon-chain-1 member-nodes_$k-validator-1
        docker rm member-nodes_$k-geth-1 member-nodes_$k-beacon-chain-1 member-nodes_$k-validator-1
        sudo rm -rf member-nodes_$i/
    done
done

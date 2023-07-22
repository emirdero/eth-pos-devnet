rm -rf consensus/beacondata
rm -rf consensus/genesis.ssz
rm -rf consensus/validatordata
rm -rf execution/geth
rm -rf .idea/
docker stop eth-pos-devnet-create-beacon-chain-genesis-1 eth-pos-devnet-geth-genesis-1 eth-pos-devnet-geth-1 eth-pos-devnet-beacon-chain-1 eth-pos-devnet-validator-1
docker rm eth-pos-devnet-create-beacon-chain-genesis-1 eth-pos-devnet-geth-genesis-1 eth-pos-devnet-geth-1 eth-pos-devnet-beacon-chain-1 eth-pos-devnet-validator-1

rm -rf execution/geth.ipc
rm -rf .idea/

docker compose up --detach
# Sleep for twenty seconds for bootnode to activate, might need to be increased for slower systems
sleep 20
./reset-p2p.sh
./members.sh
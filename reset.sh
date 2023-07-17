rm -rf consensus/beacondata
rm -rf consensus/genesis.ssz
rm -rf consensus/validatordata
rm -rf execution/geth
rm -rf .idea/
docker rm eth-pos-devnet-create-beacon-chain-genesis-1 eth-pos-devnet-geth-genesis-1 eth-pos-devnet-geth-1 eth-pos-devnet-beacon-chain-1 eth-pos-devnet-validator-1


docker compose up
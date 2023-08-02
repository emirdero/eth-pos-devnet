rm -rf lighhouse-node/consensus/beacondata
rm -rf lighhouse-node/consensus/genesis.ssz
rm -rf lighhouse-node/consensus/validatordata
rm -rf lighhouse-node/execution/geth
rm lighhouse-node/.env
docker rm lighhouse-node-geth-1 lighhouse-node-beacon-chain-1 lighhouse-node-validator-1

cp consensus/config.yaml lighhouse-node/consensus
cp consensus/genesis.ssz lighhouse-node/consensus
cp -r execution lighhouse-node
cp .env lighhouse-node/.env

cd lighhouse-node
docker compose up
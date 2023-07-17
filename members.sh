rm -rf member-nodes/consensus/beacondata
rm -rf member-nodes/consensus/genesis.ssz
rm -rf member-nodes/consensus/validatordata
rm -rf member-nodes/execution/geth
rm member-nodes/.env
docker rm member-nodes-geth-1 member-nodes-beacon-chain-1 member-nodes-validator-1

cp consensus/config.yml member-nodes/consensus
cp consensus/genesis.ssz member-nodes/consensus
cp -r execution member-nodes
cp .env member-nodes/.env

cd member-nodes
docker compose up
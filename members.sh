rm -rf member-nodes/consensus/beacondata
rm -rf member-nodes/consensus/genesis.ssz
rm -rf member-nodes/consensus/validatordata
rm -rf member-nodes/execution/geth

cp -r consensus/beacondata member-nodes/consensus/beacondata
cp -r consensus/genesis.ssz member-nodes/consensus/genesis.ssz
cp -r consensus/validatordata member-nodes/consensus/validatordata
cp -r execution/geth member-nodes/execution/geth

cd member-nodes
docker compose up
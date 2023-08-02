docker logs eth-pos-devnet-geth-1 2>&1 | grep "enode" | tail -1 > out.txt
docker logs eth-pos-devnet-beacon-chain-1 2>&1 | grep "enr" | tail -1 > out2.txt
python3 format-peer-adresses.py
python3 format-config.py > consensus/config.yaml
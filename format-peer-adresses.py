env = ""
with open("out.txt", "r+") as f:
    out = f.read() # read everything in the file
    # Substring of the enode adress
    start_index = out.index("self=enode")
    end_index = out.index("@127.0.0.1:30303")
    enode = out[start_index+5:end_index]
    env = "EL_BOOTNODE=" + enode + "@172.19.0.2:30303\n"
with open("out2.txt", "r+") as f:
    out = f.read() # read everything in the file
    start_index = out.index("ENR=\"enr")
    end_index = out.index("\" prefix=p2p")
    # Substring of the enr adress
    enr = out[start_index+5:end_index]
    env += "CL_BOOTNODE=" + enr
with open(".env", "w") as f:
    f.write(env)
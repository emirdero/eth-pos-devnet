import random
import sys
amount_of_members = int(sys.argv[1])
floor = 100/amount_of_members
num = int((floor+random.random()*100)//floor)*floor
print(int(num))
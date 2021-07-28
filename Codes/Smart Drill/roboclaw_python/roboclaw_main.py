from roboclaw_3 import Roboclaw

rc = Roboclaw("COM3",115200)

rc.Open()
address = 0x80

for line in open("abc.csv","r"):
    l = line.rstrip("\n").split(',')
    input = input("")
    if input == "\n":
        print("ID:",l[0])
        print("Distance:",l[1])
        rc.SpeedDistanceM1(address,l[1]*540,4800,1)




#while True:
#    input = input("")
#    if input == "\n":


from roboclaw_3 import Roboclaw

rc = Roboclaw("COM3",115200)

rc.Open()
address = 0x80

file = open("abc.csv","r")
pitch = 1

lines = []

for line in file.readlines():
    l = line.rstrip("\n").split(',')
    lines.append(l)

file.close()

i = 0

while i < len(lines) and i >= 0:
    print("ID:", lines[i][0])
    print("Distance:", lines[i][1])
    rc.SpeedDistanceM1(address, 4800, int(float(lines[i][1]) * pitch * 540), 1)
    inp = input("Next step: ")
    if "a" in inp:
        i -= inp.count("a")
    if "d" in inp:
        i += inp.count("d")

print("Program Stops")

import time
from roboclaw_3 import Roboclaw

#Windows comport name
rc = Roboclaw("COM3",115200)
#Linux comport name
#rc = Roboclaw("/dev/ttyACM0",115200)

rc.Open()

#Get version string
for x in range(0,255):
	value = rc.ReadEeprom(0x80,x)
	print("EEPROM:")
	print(x)
	print(" ")
	if value[0]==False:
		print("Failed")
	else:
		print(value[1])
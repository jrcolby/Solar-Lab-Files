from tkinter import *
from roboclaw_3 import Roboclaw
import time

# make sure you have pyserial installed!

def con():
    com_port.set(ce1.get())
    baud_rate.set(ce2.get())

    global rc
    rc = Roboclaw(com_port.get(), int(baud_rate.get()))
    rc.Open()

    print(com_port.get())
    print(baud_rate.get())
    print(rc.Open())
    
def rea():
    file = open(re1.get(), "r")

    global linesDict
    linesDict = dict()

    global lines
    lines = []

    for line in file.readlines():
        l = line.rstrip("\n").split(',')
        linesDict[l[0]] = l[1]
        lines.append(l)

    file.close()
    Id.set(lines[0][0])
    Di.set(lines[0][1])

def setId():
    if e1.get() in linesDict:
        Id.set(e1.get())
        Di.set(linesDict[e1.get()])
    else:
        list1.insert(END, "Error: Invalid ID!")

def runDi():
    list1.insert(END, "Commanded Distance: " + e2.get())
    rot_count = int(float(e2.get()) * 2160 / float(pitch.get()))
    rc.ResetEncoders(int(address.get()))
    rc.SpeedAccelDeccelPositionM1(int(address.get()), int(accel.get()), int(speed.get()), int(accel.get()), rot_count, 0)
    time.sleep(abs(rot_count)//2160)

def setSp():
    speed.set(e3.get())

def setAd():
    address.set(e4.get())

def setPi():
    pitch.set(e5.get())

def setAc():
    accel.set(e6.get())

def bac():
    i.set(i.get() - 1)

    Id.set(str(lines[(i.get()) % len(lines)][0]))
    Di.set(str(lines[(i.get()) % len(lines)][1]))


def nex():
    i.set(i.get() + 1)

    Id.set(str(lines[(i.get()) % len(lines)][0]))
    Di.set(str(lines[(i.get()) % len(lines)][1]))


def ent():
    list1.insert(END, "ID: " + Id.get() + "     " + Di.get())
    rot_count = int(float(Di.get())*2160/float(pitch.get()))
    rc.ResetEncoders(int(address.get()))
    rc.SpeedAccelDeccelPositionM1(int(address.get()), int(accel.get()), int(speed.get()), int(accel.get()), rot_count, 0)
    time.sleep(abs(rot_count) // 2160)

def twk():
    rc.ResetEncoders(int(address.get()))
    rc.SpeedAccelDeccelPositionM1(int(address.get()), int(accel.get()), int(speed.get()), int(accel.get()), 270, 0)

rc = NONE
linesDict = ""
lines = []

gui = Tk()

i = IntVar()
i.set(0)

gui.title("Motor Drill")

# Connection port container
ComConf = LabelFrame(gui, text="Serial COM config")
ComConf.pack(fill="both", expand="yes")

c1 = Label(ComConf, text="Com Port:")
c1.grid(row=0, column=0)

com_port = StringVar()
com_port.set('COM4')
ce1 = Entry(ComConf, textvariable=com_port, width=10)
ce1.grid(row=0, column=1)

c2 = Label(ComConf, text="Baud rate:")
c2.grid(row=0, column=2)

baud_rate = StringVar()
baud_rate.set(str(115200))
ce2 = Entry(ComConf, textvariable=baud_rate, width=10)
ce2.grid(row=0, column=3)

be0 = Button(ComConf, text="Connect", width=12, command=con)
be0.grid(row=0, column=8)

FileRead = LabelFrame(gui, text="File Input")
FileRead.pack(fill="both", expand="yes")

r1 = Label(FileRead, text="File Name:")
r1.grid(row=0, column=0)

re1 = Entry(FileRead, width=10)
re1.grid(row=0, column=1)

be1 = Button(FileRead, text="Read", width=12, command=rea)
be1.grid(row=0, column=2)

CommandPos = LabelFrame(gui, text="Command position")
CommandPos.pack(fill="both", expand="yes")

l1 = Label(CommandPos, text="ID")
l1.grid(row=1, column=0)

e1 = Entry(CommandPos, width=10)
e1.grid(row=1, column=1)

b1 = Button(CommandPos, text="Set", width=7, command=setId)
b1.grid(row=1, column=2)

l2 = Label(CommandPos, text="Distance")
l2.grid(row=1, column=3)

e2 = Entry(CommandPos, width=10)
e2.grid(row=1, column=4)

b2 = Button(CommandPos, text="Run", width=7, command=runDi)
b2.grid(row=1, column=5)

l3 = Label(CommandPos, text="Speed")
l3.grid(row=2, column=0)

speed = StringVar()
speed.set(str(2500))
e3 = Entry(CommandPos, text=speed, width=10)
e3.grid(row=2, column=1)

b3 = Button(CommandPos, text="Set", width=7, command=setSp)
b3.grid(row=2, column=2)

l4 = Label(CommandPos, text="Address")
l4.grid(row=2, column=3)

address = StringVar()
address.set(str(0x80))
e4 = Entry(CommandPos, text=address, width=10)
e4.grid(row=2, column=4)

b4 = Button(CommandPos, text="Set", width=7, command=setAd)
b4.grid(row=2, column=5)

l5 = Label(CommandPos, text="Pitch")
l5.grid(row=1, column=6)

pitch = StringVar()
pitch.set(str(1.411))
e5 = Entry(CommandPos, text=pitch, width=10)
e5.grid(row=1, column=7)

b5 = Button(CommandPos, text="Set", width=7, command=setPi)
b5.grid(row=1, column=8)

l6 = Label(CommandPos, text="Accel/Deccel")
l6.grid(row=2, column=6)

accel = StringVar()
accel.set(str(25000))
e6 = Entry(CommandPos, text=accel, width=10)
e6.grid(row=2, column=7)

b6 = Button(CommandPos, text="Set", width=7, command=setAc)
b6.grid(row=2, column=8)

PresetPos = LabelFrame(gui, text="Preset positions")
PresetPos.pack(fill="both", expand="yes")

list1 = Listbox(PresetPos, heigh=6, width=61)
list1.grid(row=0, column=0, rowspan=6, columnspan=1)

sb1 = Scrollbar(PresetPos)
sb1.grid(row=0, column=7, rowspan=3)

list1.configure(yscrollcommand=sb1.set)
sb1.configure(command=list1.yview)

CurrentPos = LabelFrame(gui, text="Current Position ")
CurrentPos.pack(fill="both", expand="yes")

l10 = Label(CurrentPos, text="ID: ")
l10.grid(row=0, column=0)

Id = StringVar()
e10 = Entry(CurrentPos, textvariable=Id, width=10)
e10.grid(row=0, column=1)

l11 = Label(CurrentPos, text="Distance: ")
l11.grid(row=0, column=2)

Di = StringVar()
e11 = Entry(CurrentPos, textvariable=Di, width=10)
e11.grid(row=0, column=3)

DetPos = LabelFrame(gui, text="Determine the Position ")
DetPos.pack(fill="both", expand="yes")

but_back = Button(DetPos, text="Back", width=7, command=bac)
but_back.grid(row=0, column=0)

but_next = Button(DetPos, text="Next", width=7, command=nex)
but_next.grid(row=0, column=1)

but_enter = Button(DetPos, text="Go", width=7, command=ent)
but_enter.grid(row=0, column=2)

but_tweak = Button(DetPos, text="Tweak", width=7, command=twk)
but_tweak.grid(row=0, column=4)

gui.mainloop()

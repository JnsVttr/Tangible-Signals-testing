#!/usr/local/bin/python3
# start script with "python3 tangible_wheel.py"
# check the serial address, set individual address below, e.g. cu.SLAB_USBtoUART

# SERIAL: receive serial messages from device
# /wheel, 213, 3, 0						// wheel, position, revolution
# /wheel/btnPress, num
# /wheel/btnRelease, num
# /wheel/touchPress, num
# /wheel/touchRelease, num
# /wheel/pushpoint, 2					// wheel crossed pushpoint, with number

# SERIAL: send commands via serial to device:
# /wheel/startPos, 300, 0, 400, 2000     // pos, rev, speed, acc
# /wheel/setRev, 1                       // revolution
# /wheel/clearPush,                      // clear push array
# /wheel/setPush,                        // set push point at current position
# /wheel/addPush, 120, 3                 // pos, rev - add push point to array



from time import sleep
import serial
import re

# Import needed modules from osc4py3
from osc4py3.as_eventloop import *
from osc4py3 import oscbuildparse
from osc4py3 import oscmethod as osm
from osc4py3.as_allthreads import * # does osc_method
from osc4py3.oscmethod import * # does OSCARG_XXX


##################################### OSC #############################

# OSC: Start the system.
osc_startup()

# SERIAL
ser = serial.Serial('/dev/cu.SLAB_USBtoUART6', 115200)
command_wheel = str.encode("/wheel") # command 'wheel'

for _ in range(10):
	print()
print("	python3 script")
print("- - - - - - - - ")
print("-> tangible wheel to serialOSC SuperCollider. ")
print("<- OSC SuperCollider to tangible wheel serial.")
print("messages send directly to OSC port 127.0.0.1 - 3333")
print()
sleep(1)




# OSC: Make client channels to send packets & Make Server to receive
osc_udp_client("127.0.0.1", 12345, "SC")
osc_udp_server("127.0.0.1", 3333, "server")

# OSC: receiving OSC messages from SuperCollider
def osc_receive_function(address, a,b,c,d):
	# Will receive message address, and message data flattened in s, x, y
	# print("osc client receive:", address,a,b,c,d)
	string = [address, a,b,c,d]
	messageString = ""
	for i in string:
		i = str(i)
		messageString += i
		messageString += ","
	messageString += "\n"
	messageString = str(messageString).encode()
	print("serial command to device: ", messageString)
	ser.write(messageString)


# OSC: remember: always the exact number of arguments while sending from SC
osc_method("/wheel", osc_receive_function, argscheme=osm.OSCARG_ADDRESS + osm.OSCARG_DATAUNPACK)
    
#####################################  SERIAL #############################


while True:
	incomingFader = ""
	t = 0
	while t == 0:
		delimiter = str.encode(",")  # delimiter for this device is ","
		serialMessage = ser.readline() # store all serial message in a string
		msg = ''
		if command_wheel in serialMessage: # commands are from wheel
			serialContent = serialMessage.split(delimiter) # split serial string into an array by delimiter
			#print(serialContent)
			command = serialContent[0]
			if command.decode("utf-8") == "/wheel":
				pos = str(serialContent[1], 'utf-8')
				rev = str(serialContent[2], 'utf-8')
				print("/wheel,", pos, ",", rev) # print the array
				msg = oscbuildparse.OSCMessage("/wheel", None, [int(pos), int(rev) ])
			if command.decode("utf-8") == "/wheel/btnPress":
				btnNum = str(serialContent[1], 'utf-8')
				print("/wheel/btnPress,", btnNum) # print the array
				msg = oscbuildparse.OSCMessage("/button", None, [int(btnNum), int(1) ])
			if command.decode("utf-8") == "/wheel/btnRelease":
				btnNum = str(serialContent[1], 'utf-8')
				print("/wheel/btnRelease,", btnNum) # print the array
				msg = oscbuildparse.OSCMessage("/button", None, [int(btnNum), int(0) ])
			if command.decode("utf-8") == "/wheel/touchPress":
				print("/wheel/touchPress,") # print the array
				msg = oscbuildparse.OSCMessage("/touch", None, [ int(1) ])
			if command.decode("utf-8") == "/wheel/touchRelease":
				print("/wheel/touchRelease,") # print the array
				msg = oscbuildparse.OSCMessage("/touch", None, [ int(0) ])
			if command.decode("utf-8") == "/wheel/pushpoint":
				num = str(serialContent[1], 'utf-8')
				print("/wheel/pushpoint,", num) # print the array
				msg = oscbuildparse.OSCMessage("/push", None, [int(num) ])
			if command.decode("utf-8") == "/wheel/startpoint":
				print("/wheel/startpoint - /done") # print the array
				msg = oscbuildparse.OSCMessage("/done", None, [ ])

			
			if msg != '':           # if message not empty, then send to SC
				osc_send(msg, "SC")
				osc_process() 
			t = 1
		else:
			print('***DROPPED - GARBAGE DETECTED****')
	



#####################################  PROCESS #############################

# Periodically call osc4py3 processing method in your event loop.
finished = False
while not finished:
    # You can send OSC messages from your event loop too…
    # …
    osc_process()
    # …

#!/usr/local/bin/python3
# start script with "python3 tangible_pins.py" 
import time
from time import sleep
# Import needed modules from osc4py3
from osc4py3.as_eventloop import *
from osc4py3 import oscbuildparse
from osc4py3 import oscmethod as osm
from osc4py3.as_allthreads import * # does osc_method
from osc4py3.oscmethod import * # does OSCARG_XXX
import serial
import re


# Start the system.
osc_startup()

# SERIAL
ser = serial.Serial('/dev/cu.SLAB_USBtoUART10', 115200)
pattern = str.encode("/pin")

print ("")
print("Receiving Serial Pins...")
print ("")
sleep(1)



received = False
posStringEncoded = ""

# receiving OSC messages
def osc_receive_function(address, a,b,c,d,e,f,g,h):
	# Will receive message address, and message data flattened in s, x, y
	print("osc client receive:", address,a,b,c,d,e,f,g,h)
	pos = [a,b,c,d,e,f,g,h]
	posString = ""
	for i in pos:
	  i = str(i)
	  posString += i
	# this is for arduino processing
	posString += "!"  
	posStringEncoded = str(posString).encode()
	ser.write(posStringEncoded)
	print("sending to serial")

	

# Make client channels to send packets & Make Server to receive
osc_udp_client("127.0.0.1", 12345, "SC")
osc_udp_server("127.0.0.1", 2222, "server")
# remember: always the exact number of arguments while sending from SC



# send the character to the device
osc_method("/pinPosition", osc_receive_function, argscheme=osm.OSCARG_ADDRESS + osm.OSCARG_DATAUNPACK)


while True:
	incomingPin = ""
	t = 0
	while t == 0:
		marker = str.encode(" ")
		check = ser.readline()
		if pattern in check:
			resultPin = check.split(marker)
			# print(resultPin)
			for i in range(1,9):
				incomingPin += str(resultPin[i], 'utf-8')
				incomingPin += ", "
			print("Tangible Pins In: /pin, ", incomingPin)	
			msg = oscbuildparse.OSCMessage("/pin", None, [int(resultPin[1]), int(resultPin[2]), int(resultPin[3]), int(resultPin[4]), int(resultPin[5]), int(resultPin[6]), int(resultPin[7]), int(resultPin[8]) ])
			osc_send(msg, "SC")
			osc_process() 
			t = 1
		else:
			print('***DROPPED - GARBAGE DETECTED****')
		
		
# Periodically call osc4py3 processing method in your event loop.
finished = False
while not finished:
    # You can send OSC messages from your event loop too…
    # …
	osc_process()
    # …

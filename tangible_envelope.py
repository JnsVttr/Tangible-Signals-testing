#!/usr/local/bin/python3
# start script with "python3 tangible_envelope.py" 
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
ser = serial.Serial('/dev/cu.SLAB_USBtoUART', 115200)
pattern = str.encode("/fader")
sleep(1)


# receiving OSC messages
def osc_receive_function(address, a,b,c,d,e,f):
	# Will receive message address, and message data flattened in s, x, y
	print("osc client receive:", address,a,b,c,d,e,f)
	pos = [a,b,c,d,e,f]
	posString = ""
	for i in pos:
	  if i < 10:
	    i = "0"+str(i)
	    posString += i
	  else:
	    i = str(i)
	    posString += i
	# this is for arduino processing
	posString += "!"  
	posStringEncoded = str(posString).encode()
	ser.write(posStringEncoded)
    
# Make client channels to send packets & Make Server to receive
osc_udp_client("127.0.0.1", 12345, "SC")
osc_udp_server("127.0.0.1", 1111, "server")

# remember: always the exact number of arguments while sending from SC
osc_method("/position", osc_receive_function, argscheme=osm.OSCARG_ADDRESS + osm.OSCARG_DATAUNPACK)



while True:
	incomingFader = ""
	t = 0
	while t == 0:
		marker = str.encode(" ")
		check = ser.readline()
		if pattern in check:
			resultFader = check.split(marker)
			# print(resultFader)
			for i in range(1,7):
				incomingFader += str(resultFader[i], 'utf-8')
				incomingFader += ", "
			print("Tangible Envelope In: /fader, ", incomingFader)	
			msg = oscbuildparse.OSCMessage("/fader", None, [int(resultFader[1]), int(resultFader[2]), int(resultFader[3]), int(resultFader[4]), int(resultFader[5]), int(resultFader[6]) ])
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

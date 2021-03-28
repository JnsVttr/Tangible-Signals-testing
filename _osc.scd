(


///////// TANGIBLE SIGNALS - OSC COMMUNICATION ////////////////


// start Python scripts + receiving from all addresses


// WHEEL  ========================================================

// control mappings
~wheelCurve = ControlSpec(0, 425, \lin, 0.0, 1.0);  // minVal, maxVal, curve, smallest step, default
~wheelCurveFine = ControlSpec(0.1, 0.9, \lin, 0.0, 1.0);  // minVal, maxVal, curve, smallest step, default

// array for wheel [val 0-424], [map val 0.0 - 1.0], [val gap 0.1-0.9], [volume from gap]
// gap lowest=44, highest=381
~wheelValArray = Array2D.new(4, 500);

~limitWheelVolume = {|volume|
	var result = 0;
	volume = volume.value;
	if ( (volume<0.1), {result = 0}, {result = volume});
	if ( (volume>0.9), {result = 1}, {result = volume});
	result;
};

// fill the wheel array once with pre-calculated values
500.do({|val|
	var mapVal = 0, volumeGap = 0, volume = 0;
	mapVal = ~wheelCurve.unmap(val).round(0.01);
	volumeGap = ~limitWheelVolume.value(mapVal);
	volume = ~wheelCurveFine.unmap(volumeGap).round(0.01);
	~wheelValArray[0, val] = val;
	~wheelValArray[1, val] = mapVal;
	~wheelValArray[2, val] = volumeGap;
	~wheelValArray[3, val] = volume;
	~postVals.value(val);
});

~postVals = {|val|
	val = val.value;
	("~wheelValArray: " +
		"r" + ~wheelValArray[0, val] + ", " +
		"s" + ~wheelValArray[1, val] + ", " +
		"f" + ~wheelValArray[2, val] + ", " +
		"c" + ~wheelValArray[3, val]
	).postln;
};



OSCdef(\wheel, {|msg, time, addr, recvPort|
	var val = msg[1];
	var revolutions = msg[2];
	var mapVal = 0, volume = 0;
	// take values from pre-calculated array
	mapVal = ~wheelValArray[1, val];
	volume = ~wheelValArray[3, val];

	// ~postVals.value(val);
	// update volume only, if wheel is not moved after preset change
	if (~updateWheelProcess==false, {
		// if ~activeTrack is instrument track 0-3
		if (~activeTrack < 4, {
			~setVolume.value(volume, ~activeTrack);
		});
	});
}, '/wheel'); // def style


// /done
OSCdef(\wheelDone, {|msg, time, addr, recvPort|
	// msg.postln;
	// if the wheel is set, then open up the volume update process again
	~updateWheelProcess = false;
}, '/done'); // def style



~buttonPressed = Array.fill(3, false);
~buttonPressedActive = Array.fill(3, false);
~buttonFunction = Array.fill(3, {("btn").postln;});
~buttonFunction[0] = { if (Tdef(\sequencer).isPlaying, {~stopFunction.value;}, {~playFunction.value;})};
~buttonFunction[1] = {
	var prevTrack;
	prevTrack = ~activeTrack - 1;
	if (~activeTrack>0, {~setCheckBoxes.value(prevTrack);})
};
~buttonFunction[2] = {
	var nextTrack;
	nextTrack = ~activeTrack + 1;
	if (~activeTrack<4, {~setCheckBoxes.value(nextTrack);})
};

// Button logic
OSCdef(\wheelButton, {|msg, time, addr, recvPort|
	var button, press;
	// msg.postln;
	button = msg[1];
	press = msg[2];
	switch (button,
		1, { if (press==0, {~buttonPressed[0] = false;}, {~buttonPressed[0] = true; ~buttonPressedActive[0] = true;});  },
		2, { if (press==0, {~buttonPressed[1] = false;}, {~buttonPressed[1] = true; ~buttonPressedActive[1] = true;});  },
		3, { if (press==0, {~buttonPressed[2] = false;}, {~buttonPressed[2] = true; ~buttonPressedActive[2] = true;});  },
	);
	for (0, 2, {|c|
		if (~buttonPressedActive[c] == true, { ~buttonFunction[c].value; ~buttonPressedActive[c] = false; })
	});

}, '/button'); // def style


// WHEEL PUSHPOINTS  ========================================================
// set push points to the gap area
~setPushPoints = {
	var storedVar = 0;
	Routine{
		3.wait;
		~pythonWheel.sendMsg("/wheel/clearPush", 0,0,0,0);                      // clear push array
		0.5.wait;
		storedVar = ~wheelValArray[0, 40];
		// add multiple pushpoints inside the gap 44-381
		~pythonWheel.sendMsg("/wheel/addPush", storedVar, 0, 1, 1);                   // pos, rev, all , revAll - add push point to array
		0.5.wait;
		storedVar = ~wheelValArray[0, 381];
		// add multiple pushpoints inside the gap 44-381
		~pythonWheel.sendMsg("/wheel/addPush", storedVar, 0, 1, 1);                   // pos, rev, all , revAll - add push point to array
		0.5.wait;
	}.play;
};
~setPushPoints.value();























// FADERS  ========================================================

OSCdef(\faderInput, {|msg, time, addr, recvPort|
	if (~updateFadersProcess == false, {
		~envLevels[~activeTrack][0] = ~faderCurve.unmap(msg[1]); // atk level
		~envLevels[~activeTrack][1] = ~faderCurve.unmap(msg[2]); // decay level
		~envLevels[~activeTrack][2] = ~faderCurve.unmap(msg[3]); // sustain level
		~envLevels[~activeTrack][3] = ~faderCurve.unmap(msg[4]); // decay level
		~envLevels[~activeTrack][4] = ~faderCurveSlider1.unmap(msg[5]); // atk time
		~envLevels[~activeTrack][5] = ~faderCurveSlider2.unmap(msg[6]); // decay time
	});
	//~envLevels[~faderAssign].postln;
	//msg.postln
}, '/fader', recvPort: ~port); // def style
//OSCdef(\faderInput).clear




// PINS ========================================================

OSCdef(\pinInput, {|msg, time, addr, recvPort|
	if (~updatePinsProcess == false, {
		for (0,7, {|i|
			switch(~activeTrack,
				0, {~durs[0][i] = msg[i+1]},
				1, {~durs[1][i] = msg[i+1]},
				2, {~durs[2][i] = msg[i+1]},
				3, {~durs[3][i] = msg[i+1]},
			);
		});
		//msg.postln
	});

}, '/pin', recvPort: ~port); // def style
//OSCdef(\pinInput).clear



)

///////// TANGIBLE SIGNALS - ENGINE ////////////////





// SEQUENCER LOOP  TDEF  ========================================================

(

~step = 0; // step indicates step of the sequence
// play + stop functions, reassigned and triggered by the window
~playFunction = {Tdef(\sequencer).play;};
~stopFunction = {Tdef(\sequencer).stop; ~step = 8;};


// Sequencer Loop =================================
Tdef(\sequencer, { loop {
	0.5.wait;
	// modulo step
	~step = ~step % 8;

	// show steps as colors, I don't know why steps increase more than 7
	defer {~setBar.value(~step-1);};


	// play the SYNTHS
	if (~durs[0][~step]==1, { ~playSynth[0].value; });
	if (~durs[1][~step]==1, { ~playSynth[1].value; });
	if (~durs[2][~step]==1, { ~playSynth[2].value; });
	if (~durs[3][~step]==1, { ~playSynth[3].value; });

	// increase step sequence:
	~step = ~step + 1;
}});

/*
Tdef(\sequencer).play;
Tdef(\sequencer).isPlaying;
*/



// WINDOW + OSC SYSTEM LOOP  TDEF  ========================================================

~systemCounter = 0;
~prevActiveTrack = 0;
~prevStep = 0;
~updateWheelProcess = false;
~updatePinsProcess = false;
~updateFadersProcess = false;

// OSC
~faderCurve = ControlSpec(0, 99, \lin, 1, 1);  // minVal, maxVal, curve, smallest step, default
~faderCurveSlider1 = ControlSpec(-50, 200, \lin, 1, 1);  // minVal, maxVal, curve, smallest step, default
~faderCurveSlider2 = ControlSpec(-80, 170, \lin, 1, 1);  // minVal, maxVal, curve, smallest step, default


// system TDEF loop
Tdef(\updateLoop, { loop {
	0.01.wait;
	~systemCounter = ~systemCounter % 8;
	// set buttons constantly according to array, which can be changed
	defer { ~setButtonsAfterDurs.value;  };
	// set envelope levels
	defer { ~setEncLevelsAfterArray.value;  };
	// set master EQ
	defer { ~setMasterEqualizerAfterArray.value  };
	// set markers according to active track
	defer { ~setTrackMarkerAfterArray.value(~activeTrack); };
	// increase counter
	~systemCounter = ~systemCounter + 1;

	// define what happens, when active track changes
	if (~prevActiveTrack != ~activeTrack){
		// ("active track changed via checkboxes to track: " + ~activeTrack).postln;
		// if active track changed to one of the 4 tracks:
		if (~activeTrack < 4, {
			~setPins.value(~activeTrack);
			~setFaders.value(~activeTrack);
			~setWheel.value(~trackVolume[~activeTrack]);
		}, {
			// if active track changed to the 5th track - master EQ:
			~setFaders.value(~activeTrack);
		});
		~prevActiveTrack = ~activeTrack;
	};
}});

1.do({ Tdef(\updateLoop).stop; Tdef(\updateLoop).play;});





// UPDATE SERIAL DEVICES ========================================================

~wheelValArray = Array2D.new(4, 500);   // init var also here to prevent errors

~postVals.value(322);
~trackVolume[~activeTrack];

~setWheel = {|trackVolume|
	var storedVar = 0, counter = 0;
	("SERIAL OSC - updating Wheel").postln;
	~updateWheelProcess = true;
	trackVolume = trackVolume.value; // always convert argument with .value
	// search for wheel value in array, start with value 44, since there is a gap 44-381 == 0.0-1.0
	340.do({|c|
		var stored;
		c=c+43;
		stored = ~wheelValArray[3, c];
		if (stored == trackVolume, {
			if (counter == 0, {  // use counter, so that always only first of multiple results is detected
				// ("stored var == " + stored).postln;
				// assign wheel position from array to var
				storedVar = ~wheelValArray[0, c];
			});
			counter = counter + 1;
		});
	});
	// set revolution to zero -> since only needed as volume control
	~pythonWheel.sendMsg("/wheel/setRev", 0, 0,0,0);
	// set wheel to the stored value of activated track
	~pythonWheel.sendMsg("/wheel/startPos", storedVar, 0, 550, 8200);
};




~setPins = {|i|
	~updatePinsProcess = true;
	("SERIAL OSC - updating Pins").postln;
	~pythonPin.sendMsg("/pinPosition",
		~durs[i][0],
		~durs[i][1],
		~durs[i][2],
		~durs[i][3],
		~durs[i][4],
		~durs[i][5],
		~durs[i][6],
		~durs[i][7]
	);
	~updatePinsProcess = false;
	("continue OSC update").postln;
};


~setFaders = {|i|
	~updateFadersProcess = true;
	("SERIAL OSC -  updating Faders at: "+ i).postln;
	~pythonFader.sendMsg("/position",
		(~faderCurve.map( ~envLevels[i][0] ) ).asInteger,
		(~faderCurve.map( ~envLevels[i][1] ) ).asInteger,
		(~faderCurve.map( ~envLevels[i][2] ) ).asInteger,
		(~faderCurve.map( ~envLevels[i][3] ) ).asInteger,
		(~faderCurveSlider1.map( ~envLevels[i][4] ) ).asInteger,
		(~faderCurveSlider2.map( ~envLevels[i][5] ) ).asInteger,
	);
	Routine{
		1.wait;
		~updateFadersProcess = false;
	}.play;
};





);








(

///////// TANGIBLE SIGNALS - NO WINDOW ////////////////
//
// replace window for macbook

/*
OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting off
*/


// global vars from system

// assign incoming pin/fader to squences
~pinAssign = 0;
~faderAssign = 0;
// fader curve
~faderCurve = ControlSpec(0, 100, \lin, 1, 1);  // minVal, maxVal, curve, smallest step, default



// SOUND VARIABLES ========================================================

// 4 collections of steps in sequence
~durs = Array.fill(4, [0,0,0,0,0,0,0,0]);
// set each entry to array [0]
4.do({|c| ~durs[c] = [0,0,0,0,0,0,0,0];  });


~envLevels = Array.fill(5, [0,0,0,0,0,0]);
~envLevels[0] = [0.01, 1, 0.4, 0.004, 0.2, 0.4];
~envLevels[1] = [0.01, 1, 0.02, 0.004, 0.1, 0.4];
~envLevels[2] = [0.01, 1, 0.4, 0.004, 0.2, 0.4];
~envLevels[3] = [0.01, 1, 0.4, 0.004, 0.2, 0.4];
~envLevels[4] = [0.5, 0.5, 0.5, 0.5, 0.2, 0.4];

~trackVolume = [0.6, 0.2, 0.2, 0.4];
~trackMutes = [1,1,1,1];  // integers not booleans, because in synthdef used to multiply volume value
~trackMarker = Array.fill(4, nil);



// empty functions, will be filled later
~stopFunction = {};
~playFunction = {};

// vars
~envs = Array.fill(5, nil); // array for envelopes
~bpm = 130;
~activeTrack = 0;




// ~setBPM.value(v.value);

// set BPM
/*~setBPM = {|k|
	~bpm = 10*k.value;
	defer {
		~ctrlTempoKnob.value = k.value;
		TempoClock.default.tempo = ~bpm+0.01;
	};
	postf("Set tempoclock to: %\n", (30*~bpm).round(10));
};
~setBPM.value(0.4);*/


// ~setCheckBoxes.value(4);



/*// set the volume from track vol knob, e.g. ~setVolume.value(0.6, 0)
~setVolume = {|val, track|
	~trackVolume[track]=val.value;
	defer{
		~volumeKnob[track].value_(~trackVolume[track])
	}
};


// set the checkboxes to activate a track
~setCheckBoxes = {|i|
	for (0,4, {|j|
		defer { ~checkBoxes[j].value = false; };
	});
	defer { ~checkBoxes[i].value = true; };
	// ("setting checkboxes to active track: " + i).postln;
	~activeTrack = i;
};
// set first checkbox at start
~setCheckBoxes.value(0);


// set the mutes to checkboxes, e.g. ~setMute.value(1, true);
~setMute = {|num, i|
	if (i==true, {
		~trackMutes[num] = 0;
	}, {
		~trackMutes[num] = 1;
	});

	for (0, 3, {|j|
		defer {
			if (~trackMutes[j].value == 0, {
				~muteChecks[j].value = true;
			}, {
				~muteChecks[j].value = false;
			});
		};
	});
	("setting ~muteChecks at : " + ~trackMutes).postln;
};
// ~setMute.value(0, true);*/











)
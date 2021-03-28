(

///////// TANGIBLE SIGNALS - WINDOW ////////////////



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




// window
~w = 1100;
~h = 750;
~space = 10;
~sequenceRow = Array.fill(5, nil); // array for btn lines
~sSpace = 0;
~ctrlBtn = Array.fill(3, nil);


// interactive elements
~checkBoxes = Array.fill(5, nil); // array for checkboxes
~activeTrack = 0;
~muteChecks = Array.fill(4, nil); // array for checkboxes
~volumeKnob = Array.fill(4, nil); // array for checkboxes
~bars = Array.fill(8, nil); // array for light
~barStates = Array.fill(8, false); // array for light
~buttons = Array2D.new(~sequenceRow.size, 8); // array for buttons
~envs = Array.fill(5, nil); // array for envelopes
~bpm = 130;




~makeWindow = {

	// WINDOW ========================================================

	~window = Window.new("Tangible Signals - experimental software", Rect(100, 600, ~w, ~h))
	.front
	.background_(Color.white);

	// Headline
	r = StaticText.new(~window, Rect(270, 12, ~w, 70)).background_(Color.white).stringColor_(Color.black);
	r.font = Font("Helvetica", 28);
	//r.align = \center;
	r.string = "TANGIBLE SIGNALS";

	// Headline
	e = StaticText.new(~window, Rect(340, 70, ~w, 20)).background_(Color.white).stringColor_(Color.black);
	e.font = Font("Helvetica", 21);
	//e.align = \center;
	e.string = "prototyping interactive physical sound displays";



	// PART - Sequencer window
	// ========================================================
	~sequenceWindow = UserView.new(~window, Rect(~space, 120, ~w-(~space*2), 395))
	.background_(Color.white);

	for (0, 4, {|i|

		// horizontal spaces for 4 instruments + 1 sequencer lights
		~sSpace = ~sSpace + 5;
		~sequenceRow[i] = HLayoutView(~sequenceWindow, Rect(10,~sSpace,1000,70)); //.background_(Color.green);
		~sSpace = ~sSpace + 80;
		c = CompositeView(~sequenceWindow, Rect(10,~sSpace,1000,2) ).background_(Color.black);
		~sSpace = ~sSpace + 10;


		// sequence rows and items: marker + checkbox + vol slider + mute checkbox
		if (i<4, {
			// add a marker to the left of each row, so that its color indicates, which instrument is currently active
			~trackMarker[i] = CompositeView(~sequenceRow[i], Rect(0, 0, 12, 30)); // .background_(Color.yellow);

			// add a vertical space to the next item
			c = CompositeView(~sequenceRow[i], Rect(0, 0, 25, 30)); // .background_(Color.red);

			t = StaticText(~sequenceRow[i], Rect(0,0, 60, 23))
			.string_("T" + (i).asString)
			.font = Font("Helvetica", 21);

			// add a checkbox for each instrument to activate the row
			~checkBoxes[i] = CheckBox.new(~sequenceRow[i], Rect(0,0,50,10))
			.action_({
				~setCheckBoxes.value(i);
			});

			// add a vertical volume slider for each row
			~volumeKnob[i] = Knob(~sequenceRow[i], Rect(60, 10, 50, 50))    // Knob.new(~controlWindow, Rect(60, 10, 40, 40))
			.value_(~trackVolume[i])
			.action_({|j|
				~setVolume.value(j.value, i);
			});


			// add a vertical space to the next item
			c = CompositeView(~sequenceRow[i], Rect(0, 0, 10, 30));

			// add a mute-checkbox to each row
			~muteChecks[i] = CheckBox.new(~sequenceRow[i], Rect(0,0,80,50), "M")
			.action_({|j|
				~setMute.value(i, j.value);
				//if (j.value==true, {~trackMutes[i]=true}, {~trackMutes[i]=false})
			});


			// add 8 buttons to each row, that will display the sequencer for each instrument by color change
			for (0, 7, {|k|
				~buttons[i, k] = Button(~sequenceRow[i],Rect(0,0,40,50)).states_([["", Color.grey, Color.white]])
				.action_({
					("set button, row:" + i + " btn:" + k ).postln;
					defer {
						// set duration array
						if (~durs[i][k]==0, {
							~durs[i][k]=1;
							//~setButton.value(1, i, k);
						}, {
							~durs[i][k]=0;
							//~setButton.value(0, i, k);
						});
						// if row is active, then set pins
						if (i == ~activeTrack, {~setPins.value(i)});
					};
					// ~durs.postln;
				});
				// add a vertical space to the next item
				c = CompositeView(~sequenceRow[i], Rect(0, 0, 10, 30));
			});

			// add some space
			c = CompositeView(~sequenceRow[i], Rect(0, 0, 90, 100));


			// add the envelope view for each instrument
			~envs[i] = EnvelopeView(~sequenceRow[i], Rect(0, 0, 230, 80))
			.drawLines_(true)
			.selectionColor_(Color.red)
			.drawRects_(true)
			.resize_(5)
			.step_(0.05)
			.action_({arg b; [b.index, b.value].postln})
			.thumbSize_(12)
			.value_([[0.0, 0.1, 0.5, 1.0],[0.0,1.0,0.8,0.0]]);

			// add some space
			c = CompositeView(~sequenceRow[i], Rect(0, 0, 30, 100));
		}, {
			// Sequencer light feedback ~bars
			// distance to left border in the sequencer row
			c = CompositeView(~sequenceRow[i], Rect(0, 0, 287, 100)); // .background_(Color.blue);
			// create 8 sequencer fields
			for (0, 7, {|k|
				~bars[k] = Button(~sequenceRow[i],Rect(0,0,40,50))
				.action_({
					~setBar.value(k);
				});
				// add a vertical space to the next item
				c = CompositeView(~sequenceRow[i], Rect(0, 0, 10, 30));
			});
			~setBar.value(0);
		});
	});






	// CONTROL WINDOW
	// ========================================================

	~controlWindow = UserView.new(~window, Rect(~space, 600, ~w-(~space*2), 80))
	//.background_(Color.new255(216, 231, 255));
	.background_(Color.white);

	// BPM
	// display BPM Text
	StaticText.new(~controlWindow, Rect(0, 0, 50, 60)).background_(Color.white).stringColor_(Color.black).string_("BPM");
	// display BPM knob and assign action
	~ctrlTempoKnob = Knob.new(~controlWindow, Rect(60, 10, 40, 40))
	.action_({|v|
		~setBPM.value(v.value);
	}).value_(0.4);


	// display checkbox for Master EQ and assign action
	~checkBoxes[4] = CheckBox.new(~controlWindow, Rect(180,0,120,20), "MASTER-EQ")
	.action_({
		defer {
			~setCheckBoxes.value(4);
		}
	});

	// display envelope for master EQ and assign action
	~envs[4] = EnvelopeView(~controlWindow, Rect(300, 0, 310, 80))
	.drawLines_(true)
	.selectionColor_(Color.red)
	.drawRects_(true)
	.resize_(5)
	.step_(0.05)
	//.action_({arg b; [b.index, b.value].postln})
	.thumbSize_(5)
	.value_([[0.0, 0.3, 0.6, 1.0],[0.5,0.5,0.5,0.5]]);


	// display stop/plax buttons and assign actions
	~ctrlBtn[0] = Button(~controlWindow,Rect(800,0,50,50)).states_([["stop", Color.black, Color.white]])
	.action_({
		defer{
			~stopFunction.value;
		};
		("stop").postln;
	});
	~ctrlBtn[1] = Button(~controlWindow,Rect(860,0,50,50)).states_([["play", Color.black, Color.white]])
	.action_({
		defer{
			~playFunction.value;
		};
		("play").postln;
	});
};

// ~makeWindow.value;










// HELPER FUNCTIONS
// ========================================================


// set a button (color), e.g.  ~setButton.value(1, 2, 3);
~setButtonsAfterDurs = {
	for (0,3, {|i|
		for (0,7, {|k|
			if (~durs[i][k]==1, {
				//~buttons[i, k].states_([["", Color.white, Color.new255(37, 37, 37)]]);
				~buttons[i, k].states_([["", Color.white, Color.black]]);
			}, {
				~buttons[i, k].states_([["", Color.white, Color.white]]);
			});
		});
	});
};

~setEncLevelsAfterArray = {
	for (0,4, {|i|
		// set env levelsafter array
		defer {
			~envs[i].value_(
				[
					[0.0, ~envLevels[i][4], ~envLevels[i][5], 1.0],
					[~envLevels[i][0], ~envLevels[i][1], ~envLevels[i][2], ~envLevels[i][3]]
				]
		)};
	});
};


// set the volume from track vol knob, e.g. ~setVolume.value(0.6, 0)
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
// ~setMute.value(0, true);


// set the sequencer bars at the bottom in white or red, e.g. ~setBar.value(1)
~setBar = {|k|
	// reset all bars
	for (0, 7, {|i|
		~barStates[i] = false;
	});
	// set active bar
	~barStates[k] = true;
	// update all bars
	for (0, 7, {|i|
		if (~barStates[i]==false, {
			~bars[i].states_([["no", Color.grey, Color.white]]);
		}, {
			~bars[i].states_([["", Color.red, Color.red]]);
		});
	});
};




// set BPM
~setBPM = {|k|
	~bpm = 10*k.value;
	defer {
		~ctrlTempoKnob.value = k.value;
		TempoClock.default.tempo = ~bpm+0.01;
	};
	postf("Set tempoclock to: %\n", (30*~bpm).round(10));
};
~setBPM.value(0.4);



~setTrackMarkerAfterArray = {|sel|
	// sel.postln;
	for (0,3, {|j|
		if (j == sel.value, {
			defer{
				~trackMarker[j].background_(Color.new255(11, 21, 15));
				~sequenceRow[j].background_(Color.new255(158,226,255));  // rgb(158,226,255)
			};
		}, {
			defer{
				~trackMarker[j].background_(Color.white);
				~sequenceRow[j].background_(Color.white);
			}
		})
	});
};


)
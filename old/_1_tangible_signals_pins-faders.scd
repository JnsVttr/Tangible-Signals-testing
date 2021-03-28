
// TANGIBLE SIGNALS /////////////////////////////////////////////

(
// SYSTEM ========================================================
i = ();
i.startServer = {s.waitForBoot};    // start the server
i.startServer.value;
TempoClock.default.tempo = (120/30);
thisProcess.openUDPPort(12345); // attempt to open 57120
thisProcess.openPorts; // list all open ports
~port = 12345; // 57120 is sclang default port
~pythonFader = NetAddr.new("127.0.0.1", 1111);    // netAddr for fader python3 script
~pythonPin = NetAddr.new("127.0.0.1", 2222);    // netAddr for fader python3 script


// MASTER SYNTH
SynthDef(\masterOutSynth, {|out=0, inBus=120, amp=0.97, eqVol=0.8, eqQ = 0.8,
	freq1 = 70, gain1 = 0, q1= 1,
	freq2 = 200, gain2 = 0, q2= 1,
	freq3 = 4000, gain3 = 0, q3= 1,
	freq4 = 12000, gain4 = 0, q4= 1|

	var sig, band1, band2, band3, band4;
	sig = In.ar(inBus, 2);
	sig = Compander.ar(sig) * amp;

	sig = BPeakEQ.ar(
		BPeakEQ.ar(
			BPeakEQ.ar(
				BPeakEQ.ar(sig, freq4, eqQ, gain4, eqVol),
				freq3, eqQ, gain3, eqVol),
			freq2, eqQ, gain2, eqVol),
		freq1, eqQ, gain1, eqVol);
	//sig = BPeakEQ.ar(sig, freq2, eqQ, gain2, eqVol);
	//sig = BPeakEQ.ar(sig, freq3, eqQ, gain3, eqVol);
	//sig = BPeakEQ.ar(sig, freq4, eqQ, gain4, eqVol);

	//sig = Mix.ar([band1, band2, band3, band4]);
	Out.ar(out, sig)
}).add;



// SOUND VARIABLES ========================================================
~durs = Array.fill(4, [0,0,0,0,0,0,0,0]);
~durs[0] = [1,0,0,0,0,0,0,0];
~durs[1] = [1,0,0,0,1,0,0,0];
~durs[2] = [0,0,0,0,1,0,0,0];
~durs[3] = [0,0,0,0,0,1,0,0];

~envLevels = Array.fill(5, [0,0,0,0,0,0]);
~envLevels[0] = [0.01, 1, 0.4, 0.004, 0.2, 0.4];
~envLevels[1] = [0.01, 1, 0.02, 0.004, 0.1, 0.4];
~envLevels[2] = [0.01, 1, 0.4, 0.004, 0.2, 0.4];
~envLevels[3] = [0.01, 1, 0.4, 0.004, 0.2, 0.4];
~envLevels[4] = [0.5, 0.5, 0.5, 0.5, 0.2, 0.4];

~synthLevels = [0.6, 0.2, 0.2, 0.4];
~mutes = [1,1,1,1];
~marker = Array.fill(4, nil);

// assign incoming pin/fader to squences
~pinAssign = 0;
~faderAssign = 0;
// fader curve
~faderCurve = ControlSpec(0, 100, \lin, 1, 1);  // minVal, maxVal, curve, smallest step, default

// window
~w = 950;
~h = 750;
~space = 10;
~btnViews = Array.fill(5, nil); // array for btn lines
~checks = Array.fill(5, nil); // array for checkboxes
~muteChecks = Array.fill(4, nil); // array for checkboxes
~vol = Array.fill(4, nil); // array for checkboxes
~bars = Array.fill(8, nil); // array for light
~btns = Array2D.new(~btnViews.size, 8); // array for buttons
~envs = Array.fill(5, nil); // array for envelopes
~btnViewSpace = 0;
~ctrlBtn = Array.fill(3, nil);

// SOUND LOOP ========================================================
~patCounter = 0;
~play = {Tdef(\pattern).play;};
~stop = {Tdef(\pattern).stop; ~patCounter = 0;};

~masterBus = Bus.audio(numChannels:2);
~masterGroup = Group.new(addAction:\addToTail);
~masterOut = Synth(\masterOutSynth, [
	\inBus, ~masterBus.index,
	\out, 0,
	\compression, 0.5,
	\release, 0.15,
	\amp, 1.3],
target:~masterGroup);




// SYSTEM LOOP ========================================================
~systemCounter = 0;
~checkActive = 0;

Tdef(\pattern, { loop {
	0.5.wait;
	~step = ~patCounter%8;
	~patCounter = ~patCounter + 1;

	// show steps as colors
	for (0,7, {|i|
		if (i == ~step, {
			defer { ~bars[i].states_([["", Color.red, Color.red]]) };
		}, {
			defer { ~bars[i].states_([["no", Color.grey, Color.white]]) };
		});
	});

	if (~durs[0][~step]==1, {
		Synth(\kick, [
			\out, ~masterBus.index,
			\amp, ~synthLevels[0] * ~mutes[0],
			\atkLevel, ~envLevels[0][0],
			\decLevel, ~envLevels[0][1],
			\susLevel, ~envLevels[0][2],
			\atkTime,  ~envLevels[0][3],
			\decTime,  ~envLevels[0][4],
			\relTime,  ~envLevels[0][5],
		]);
	});
	if (~durs[1][~step]==1, {
		Synth(\hh, [
			\out, ~masterBus.index,
			\amp, ~synthLevels[1] * ~mutes[1],
			\atkLevel, ~envLevels[1][0],
			\decLevel, ~envLevels[1][1],
			\susLevel, ~envLevels[1][2],
			\atkTime,  ~envLevels[1][3],
			\decTime,  ~envLevels[1][4],
			\relTime,  ~envLevels[1][5],
		]);
	});
	if (~durs[2][~step]==1, {
		Synth(\quietsch, [
			\out, ~masterBus.index,
			\amp, ~synthLevels[2] * ~mutes[2],
			\atkLevel, ~envLevels[2][0],
			\decLevel, ~envLevels[2][1],
			\susLevel, ~envLevels[2][2],
			\atkTime,  ~envLevels[2][3],
			\decTime,  ~envLevels[2][4],
			\relTime,  ~envLevels[2][5],
		]);

	});
	if (~durs[3][~step]==1, {
		Synth(\done, [
			\out, ~masterBus.index,
			\amp, ~synthLevels[3] * ~mutes[3],
			\atkLevel, ~envLevels[3][0],
			\decLevel, ~envLevels[3][1],
			\susLevel, ~envLevels[3][2],
			\atkTime,  ~envLevels[3][3],
			\decTime,  ~envLevels[3][4],
			\relTime,  ~envLevels[3][5],
		]);
	});
}});




~updatePinsProcess = false;
~updateFadersProcess = false;
~pinReminder = 0;



Tdef(\system, { loop {
	0.1.wait;
	~step = ~systemCounter % 8;
	~systemCounter = ~systemCounter + 1;
	for (0,3, {|i|
		for (0,7, {|j|
			if (~durs[i][j]==1, {
				defer { ~btns[i, j].states_([["", Color.white, Color.new255(37, 37, 37)]]) };
			}, {
				defer { ~btns[i, j].states_([["", Color.white, Color.white]]) };
			});
		});
	});
	for (0,4, {|i|
		// Levels + Time
		defer { ~envs[i].value_([[0.0, ~envLevels[i][4], ~envLevels[i][5], 1.0],[~envLevels[i][0],~envLevels[i][1],~envLevels[i][2],~envLevels[i][3]]])};
	});
	~masterOut.set(
		\freq1, 70,
		\gain1, (~envLevels[4][0]).linlin(0, 1, -12, 12),
		\freq2, (~envLevels[4][4]).linlin(0.2, 0.6, 200, 800),
		\gain2, (~envLevels[4][1]).linlin(0, 1, -12, 12),
		\freq3, (~envLevels[4][5]).linlin(0.3, 0.7, 800, 6000),
		\gain3, (~envLevels[4][2]).linlin(0, 1, -12, 12),
		\freq4, 12000,
		\gain4, (~envLevels[4][3]).linlin(0, 1, -12, 12),
	);
	for (0,3, {|j|
		if (j==~faderAssign, {
			defer{ ~marker[j].background_(Color.red) };
		}, {
			defer{ ~marker[j].background_(Color.white) }
		})
	});
}});

1.do({ Tdef(\system).stop; Tdef(\system).play;});
/*
~envLevels[4][5]
(~envLevels[4][4]).linlin(0.3, 0.7, 800, 6000);
(0).linlin(1, 0, 6, -6, clip:'minmax')

~masterOut.set(\freq1, 70, \q1, 0.3, \gain1, -12, \freq2, 500, \gain2, 3, \freq3, 4000, \gain3, 3, \freq4, 12000, \gain4, -12, \eqVol, 0.9)
*/


~setCheckBoxes = {|i|
	("setting checkboxes to: " + i).postln;
	if (i<4, {
		~updatePinsProcess = true;
		~setPins.value(i);
		~updateFadersProcess = true;
		~setFaders.value(i);
	}, {
		~updateFadersProcess = true;
		~setFaders.value(i);
	});
	for (0,4, {|j|
		defer { ~checks[j].value = false; };
	});
	defer { ~checks[i].value = true; };
};


~setPins = {|i|
	("updating Pins").postln;
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
	~pinAssign = i;
	~updatePinsProcess = false; ("continue OSC update").postln;
};


~setFaders = {|i|
	("updating Faders at: "+ i).postln;
	~pythonFader.sendMsg("/position",
		(~faderCurve.map( ~envLevels[i][0] ) ).asInt,
		(~faderCurve.map( ~envLevels[i][1] ) ).asInt,
		(~faderCurve.map( ~envLevels[i][2] ) ).asInt,
		(~faderCurve.map( ~envLevels[i][3] ) ).asInt,
		(~faderCurveSlider1.map( ~envLevels[i][4] ) ).asInt,
		(~faderCurveSlider2.map( ~envLevels[i][5] ) ).asInt,
	);
	~faderAssign = i;
	Routine{
		1.wait;
		~updateFadersProcess = false;
	}.play;
};

/*
~envLevels[0][2]
~faderCurve.map( ~envLevels[0][2] )
~setFaders.value(1);
~updateFadersProcess = false;

(2.2).asInt

*/







// OSC Communication ========================================================
// receiving from all addresses:
~faderCurve = ControlSpec(0, 99, \lin, 1, 1);  // minVal, maxVal, curve, smallest step, default
~faderCurveSlider1 = ControlSpec(-50, 200, \lin, 1, 1);  // minVal, maxVal, curve, smallest step, default
~faderCurveSlider2 = ControlSpec(-80, 170, \lin, 1, 1);  // minVal, maxVal, curve, smallest step, default
// faders
OSCdef(\faderInput, {|msg, time, addr, recvPort|
	if (~updateFadersProcess == false, {
		~envLevels[~faderAssign][0] = ~faderCurve.unmap(msg[1]); // atk level
		~envLevels[~faderAssign][1] = ~faderCurve.unmap(msg[2]); // decay level
		~envLevels[~faderAssign][2] = ~faderCurve.unmap(msg[3]); // sustain level
		~envLevels[~faderAssign][3] = ~faderCurve.unmap(msg[4]); // decay level
		~envLevels[~faderAssign][4] = ~faderCurveSlider1.unmap(msg[5]); // atk time
		~envLevels[~faderAssign][5] = ~faderCurveSlider2.unmap(msg[6]); // decay time
	});
	//~envLevels[~faderAssign].postln;
	//msg.postln
}, '/fader', recvPort: ~port); // def style
//OSCdef(\faderInput).clear



// pins
OSCdef(\pinInput, {|msg, time, addr, recvPort|
	if (~updatePinsProcess == false, {
		for (0,7, {|i|
			switch(~faderAssign,
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










// WINDOW ========================================================

~window = Window.new("Tangible Signals", Rect(100, 700, ~w, ~h))
.front
.background_(Color.white);

r = StaticText.new(~window, Rect(0, 18, ~w, 70)).background_(Color.white).stringColor_(Color.black);
r.font = Font("Helvetica", 21);
r.align = \center;
r.string = "TANGIBLE SIGNALS";



// INTERACTION WINDOW
~btnWindow= UserView.new(~window, Rect(~space, 120, ~w-(~space*2), 400))
.background_(Color.white);



for (0, 4, {|i|
	~btnViewSpace = ~btnViewSpace + 5;
	~btnViews[i] = HLayoutView(~btnWindow,Rect(10,~btnViewSpace,910,70));
	~btnViewSpace = ~btnViewSpace + 90;

	// make space for status bars
	if (i<4, {
		~marker[i] = CompositeView(~btnViews[i], Rect(0, 0, 10, 30));
		c = CompositeView(~btnViews[i], Rect(0, 0, 10, 30));
		~checks[i] = CheckBox.new(~btnViews[i], Rect(0,0,80,50), ("SEQ " + (i).asString))
		.action_({ defer {~setCheckBoxes.value(i);} });
		~vol[i] = Slider(~btnViews[i], Rect(0, 0, 15, 120))
		.value_(~synthLevels[i])
		.action_({|j| (~vol[i].value).postln; defer{ ~synthLevels[i]=j.value}})
		.background_(Color.black);
		c = CompositeView(~btnViews[i], Rect(0, 0, 10, 30));
		~muteChecks[i] = CheckBox.new(~btnViews[i], Rect(0,0,80,50), "M")
		.action_({|j|
			if (j.value==true, {~mutes[i]=0}, {~mutes[i]=1})
		});


		for (0, 7, {|k|
			~btns[i, k] = Button(~btnViews[i],Rect(0,0,50,50)).states_([["", Color.grey, Color.white]])
			.action_({
				("action").postln;
				defer {
					// set duration array
					if (~durs[i][k]==0, {~durs[i][k]=1}, {~durs[i][k]=0});
					// if row is active, then set pins
					if (i==~pinAssign, {~setPins.value(i)});
				};
			});
		});
		c = CompositeView(~btnViews[i], Rect(0, 0, 100, 100));
		~envs[i] = EnvelopeView(~btnViews[i], Rect(0, 0, 230, 80))
		    .drawLines_(true)
		    .selectionColor_(Color.red)
		    .drawRects_(true)
		    .resize_(5)
		    .step_(0.05)
		    .action_({arg b; [b.index, b.value].postln})
		    .thumbSize_(5)
		    .value_([[0.0, 0.1, 0.5, 1.0],[0.0,1.0,0.8,0.0]]);
	}, {
		c = CompositeView(~btnViews[i], Rect(0, 0, 200, 100));
		for (0, 7, {|k|
			~bars[k] = Button(~btnViews[i],Rect(0,0,50,50)).states_([["", Color.grey, Color.white]]).action_({ ("action").postln; });
		});
	})
});

~checks[~pinAssign].value_(true);

// CONTROL WINDOW

~controlWindow = UserView.new(~window, Rect(~space, 600, ~w-(~space*2), 80))
//.background_(Color.new255(216, 231, 255));
.background_(Color.white);

StaticText.new(~controlWindow, Rect(0, 0, 50, 60)).background_(Color.white).stringColor_(Color.black).string_("BPM");
~ctrlTempoKnob = Knob.new(~controlWindow, Rect(60, 10, 40, 40))
.action_({|v|
	postf("action func called: %\n", v.value);
	defer {
		TempoClock.default.tempo = 10*v.value;
	}

})
.value_(0.4);


~ctrlBtn[0] = Button(~controlWindow,Rect(700,0,50,50)).states_([["stop", Color.black, Color.white]]).action_({ defer{~stop.value}; ("stop").postln; });
~ctrlBtn[1] = Button(~controlWindow,Rect(760,0,50,50)).states_([["play", Color.black, Color.white]]).action_({ defer{~play.value}; ("play").postln; });

~checks[4] = CheckBox.new(~controlWindow, Rect(180,0,120,20), "MASTER-EQ").action_({ defer {defer {~setCheckBoxes.value(4) }} });
~envs[4] = EnvelopeView(~controlWindow, Rect(300, 0, 310, 80))
		    .drawLines_(true)
		    .selectionColor_(Color.red)
		    .drawRects_(true)
		    .resize_(5)
		    .step_(0.05)
		    .action_({arg b; [b.index, b.value].postln})
		    .thumbSize_(5)
		    .value_([[0.0, 0.3, 0.6, 1.0],[0.5,0.5,0.5,0.5]]);














// SYNTH DEFS ========================================================




SynthDef("kick", {
	arg out=0, amp=0.6, bd=0.9, lp=100,
	atkLevel=0.4, decLevel=1, susLevel=0.5, relLevel=0,
	atkTime=0.004, decTime=0.04, relTime=0.2;
	var env0, env1, env1m, sig;

	env0 =  EnvGen.ar(
		Env.new([atkLevel, decLevel, susLevel, relLevel],
		[atkTime, decTime, relTime],
		[-4, -2, -4]),
		doneAction:2);
	env1 = EnvGen.ar(
		Env.new([110, 59, 29],
		[0.003, 0.29], [-4, -5]));
	env1m = env1.midicps;

	sig = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(1);
	sig = LPF.ar(sig, lp, env0);
	sig = sig + SinOsc.ar(env1m*bd, 0, env0);

	sig = sig * 1.2 * amp;
	sig = sig.clip2(1);
	sig = Pan2.ar(sig);

	Out.ar(out, sig);
}).add;
/*
x = Synth(\kick, [\atkLevel, 0.7, \decLevel, 1, \susLevel, 0.9, \atkTime, 0.004, \decTime, 0.2, \relTime, 0.1]);
x = Synth(\kick);
*/


SynthDef(\hh, {
	|out = 0, amp = 0.9, pan = 0.3, hp = 2000, rel=1,
	atkLevel=0.4, decLevel=1, susLevel=0.5, relLevel=0,
	atkTime=0.004, decTime=0.04, relTime=0.2|
	var sig, env;
	env =  EnvGen.kr(
		Env.new([atkLevel, decLevel, susLevel, relLevel],
		[atkTime, decTime, relTime],
		[-4, -2, -4]),
		doneAction:2);
	sig = BrownNoise.ar(amp) + PinkNoise.ar(amp) + WhiteNoise.ar(amp/3);
	sig = HPF.ar(sig, hp);
	sig = LPF.ar(sig, 10012310000);
	sig = sig * env;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
/*
a = Synth(\hh, [\atkLevel, 0.01, \decLevel, 1, \susLevel, 0.3, \atkTime, 0.04, \decTime, 0.2, \relTime, 0.81]);
*/


SynthDef(\quietsch, {
	|out=0, amp = 1, freq = 1200, rel=1,
	atkLevel=0.4, decLevel=1, susLevel=0.5, relLevel=0,
	atkTime=0.004, decTime=0.04, relTime=0.2|
	var sig, env, env1, env2;

	env =  EnvGen.kr(
		Env.new([atkLevel, decLevel, susLevel, relLevel],
		[atkTime, decTime, relTime],
		[-4, -2, -4]),
		doneAction:2);
	sig = SinOsc.ar([freq, freq+432])
	+ Saw.ar([freq + env, freq + env]*0.3)
	+ WhiteNoise.ar(0.8) * env;

	sig = LPF.ar(sig, 4000);
	sig = HPF.ar(sig, 100);

	sig = GVerb.ar(sig, 2) * env * amp * 0.1;
	Out.ar(out, sig);
}).add;
/*
u = Synth(\quietsch, [\atkLevel, 0.01, \decLevel, 1, \susLevel, 0.1, \atkTime, 0.9, \decTime, 0.5, \relTime, 0.2]);
*/



SynthDef(\done, {
	|out=0, freq=50, rel=0.9, amp= 0.9, pan=0, vib=3.2, ff=6800, fg=1,
	atkLevel=0.4, decLevel=1, susLevel=0.5, relLevel=0,
	atkTime=0.004, decTime=0.04, relTime=0.2|
	var sig, env, noise;
	env =  EnvGen.kr(
		Env.new([atkLevel, decLevel, susLevel, relLevel],
		[atkTime, decTime, relTime],
		[-4, -2, -4]),
		doneAction:2);
	sig = Mix.ar([
		SinOsc.ar(freq + 20),
		SinOsc.ar(freq + 40),
		SinOsc.ar(freq + 60),
	]) *0.4;
	sig = Mix.ar(Array.fill(20, {
		|count|
		var harm;
		harm = count + 1 *freq;
		SinOscFB.ar(harm,
			feedback: 0,
			mul: max([0, 0], SinOsc.kr(count+1/vib))
		) * 1/(count+1) + BrownNoise.ar(count+1/3000);
	}));
	noise = WhiteNoise.ar(Rand(0.01, 0.04)) * EnvGen.kr(Env.perc(0.001, Rand(0.01, 0.2)));
	sig = sig + noise;
	sig = MoogFF.ar(sig, ff, fg);
	sig = sig.distort * amp;
	sig = sig * env;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

/*
q = Synth(\done, [\atkLevel, 0.9, \decLevel, 1, \susLevel, 0.9, \atkTime, 1, \decTime, 0.2, \relTime, 0.81]);
Env.new([0, 1, 0.9, 0], [2.9, 2.5, 0.2],[-5, 0, -5]).plot;
*/




)
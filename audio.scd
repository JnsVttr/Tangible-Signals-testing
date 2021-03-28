
(
i = ();
i.startServer = {s.waitForBoot};    // start the server
i.startServer.value;
TempoClock.default.tempo = (120/30);













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

x = Synth(\kick, [\atkLevel, 0.7, \decLevel, 1, \susLevel, 0.9, \atkTime, 0.004, \decTime, 0.2, \relTime, 0.1]);
x = Synth(\kick);





SynthDef(\hh, {
	|out = 0, amp = 0.9, pan = 0.3, hp = 2000, rel=1,
	atkLevel=0.4, decLevel=1, susLevel=0.5, relLevel=0,
	atkTime=0.004, decTime=0.04, relTime=0.2|
	var sig, env;
	//env = Env.perc(0.01, rel);
	env =  EnvGen.kr(
		Env.new([atkLevel, decLevel, susLevel, relLevel],
		[atkTime, decTime, relTime],
		[-4, -2, -4]),
		doneAction:2);

	sig = BrownNoise.ar(amp) + PinkNoise.ar(amp) + WhiteNoise.ar(amp/3);
	//sig = Pan2.ar(sig, Rand(0-pan, pan));
	sig = HPF.ar(sig, hp);
	sig = LPF.ar(sig, 10012310000);
	sig = sig * env;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

a = Synth(\hh, [\atkLevel, 0.01, \decLevel, 1, \susLevel, 0.3, \atkTime, 0.04, \decTime, 0.2, \relTime, 0.81]);






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

u = Synth(\quietsch, [\atkLevel, 0.01, \decLevel, 1, \susLevel, 0.1, \atkTime, 0.9, \decTime, 0.5, \relTime, 0.2]);







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


q = Synth(\done, [\atkLevel, 0.9, \decLevel, 1, \susLevel, 0.9, \atkTime, 1, \decTime, 0.2, \relTime, 0.81]);


/*
Env.new([0, 1, 0.9, 0], [0.9, 2.5, 0.2],[-5, 0, -5]).plot;
*/





~durs = Array.fill(4, [0,0,0,0,0,0,0,0]);
~durs[0] = [1,0,0,0,0,0,0,0];
~durs[1] = [1,0,0,0,1,0,0,0];
~durs[2] = [0,0,0,0,1,0,0,0];
~durs[3] = [0,0,0,0,0,1,0,0];

)



Tdef(\pattern).play;
Tdef(\pattern).stop; ~patCounter = 0;
~envLevels = Array.fill(4, [0,0,0,0,0,0]);
~envLevels[0] = [0.01, 1, 0.4, 0.004, 0.2, 0.1];
~envLevels[1] = [0.01, 1, 0.02, 0.004, 0.1, 0.01];
~envLevels[2] = [0.01, 1, 0.4, 0.004, 0.2, 0.1];
~envLevels[3] = [0.01, 1, 0.4, 0.004, 0.2, 0.1];
~synthLevels = [0.6, 0.2, 0.2, 0.4];


(

Tdef(\pattern, { loop {
	0.5.wait;
	~step = ~patCounter%8;
	~patCounter = ~patCounter + 1;
	if (~durs[0][~step]==1, {
		Synth(\kick, [\amp, ~synthLevels[0],
			\atkLevel, ~envLevels[0][0],
			\decLevel, ~envLevels[0][1],
			\susLevel, ~envLevels[0][2],
			\atkTime,  ~envLevels[0][3],
			\decTime,  ~envLevels[0][4],
			\relTime,  ~envLevels[0][5],
		]);
	});
	if (~durs[1][~step]==1, {
		Synth(\hh, [\amp, ~synthLevels[1],
			\atkLevel, ~envLevels[1][0],
			\decLevel, ~envLevels[1][1],
			\susLevel, ~envLevels[1][2],
			\atkTime,  ~envLevels[1][3],
			\decTime,  ~envLevels[1][4],
			\relTime,  ~envLevels[1][5],
		]);
	});
	if (~durs[2][~step]==1, {
		Synth(\quietsch, [\amp, ~synthLevels[2],
			\atkLevel, ~envLevels[2][0],
			\decLevel, ~envLevels[2][1],
			\susLevel, ~envLevels[2][2],
			\atkTime,  ~envLevels[2][3],
			\decTime,  ~envLevels[2][4],
			\relTime,  ~envLevels[2][5],
		]);

	});
	if (~durs[3][~step]==1, {
		Synth(\done, [\amp, ~synthLevels[3],
			\atkLevel, ~envLevels[3][0],
			\decLevel, ~envLevels[3][1],
			\susLevel, ~envLevels[3][2],
			\atkTime,  ~envLevels[3][3],
			\decTime,  ~envLevels[3][4],
			\relTime,  ~envLevels[3][5],
		]);
	});
}});
)


(
// OSC Communication
~pinAssign = 3;
~faderAssign = 1;
~faderCurve = ControlSpec(0, 100, \lin, 1, 1);  // minVal, maxVal, curve, smallest step, default

// receiving from all addresses
// faders
OSCdef(\faderInput, {|msg, time, addr, recvPort|
	~envLevels[~faderAssign][0] = ~faderCurve.unmap(msg[1]); // atk level
	~envLevels[~faderAssign][1] = ~faderCurve.unmap(msg[2]); // decay level
	~envLevels[~faderAssign][2] = ~faderCurve.unmap(msg[3]); // sustain level
	//~envLevels[~faderAssign][3] = ~faderCurve.unmap(msg[4]); // decay level
	~envLevels[~faderAssign][4] = ~faderCurve.unmap(msg[5]); // atk time
	~envLevels[~faderAssign][5] = ~faderCurve.unmap(msg[6]); // decay time
	//msg.postln
}, '/fader'); // def style
//OSCdef(\faderInput).clear



// pins
OSCdef(\pinInput, {|msg, time, addr, recvPort|
	for (0,7, {|i|
		switch(~pinAssign,
			0, {~durs[0][i] = msg[i+1]},
			1, {~durs[1][i] = msg[i+1]},
			2, {~durs[2][i] = msg[i+1]},
			3, {~durs[3][i] = msg[i+1]},
			{~durs[0][i] = msg[i+1]}
		);

	});
	//msg.postln
}, '/pin'); // def style
//OSCdef(\pinInput).clear
)

















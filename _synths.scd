
///////// TANGIBLE SIGNALS - SYNTH DEFINITIONS ////////////////


// MASTER SYNTH //////////////////////////////////////////////////////////////////

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






// TRACK SOUND SYNTH DEFS //////////////////////////////////////////////////////////////////




SynthDef("kick", {
	arg out=0, amp=0.6, bd=1.0, lp=900,
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















("> file \"synths.scd\" ").postln



// SOUND SYSTEM ========================================================


// MASTER AUDIO

// Create master bus + group + mastersynth
~masterBus = Bus.audio(numChannels:2);
~masterGroup = Group.new(addAction:\addToTail);
~masterOut = Synth(\masterOutSynth, [
	\inBus, ~masterBus.index,
	\out, 0,
	\compression, 0.5,
	\release, 0.15,
	\amp, 1.3],
target:~masterGroup);


~setMasterEqualizerAfterArray = {
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
};




// STORE SYNTHS IN ARRAY

~playSynth = Array.fill(4, nil);

~playSynth[0] = {
	Synth(\kick, [
		\out, ~masterBus.index,
		\amp, ~trackVolume[0] * ~trackMutes[0],
		\atkLevel, ~envLevels[0][0],
		\decLevel, ~envLevels[0][1],
		\susLevel, ~envLevels[0][2],
		\atkTime,  ~envLevels[0][3],
		\decTime,  ~envLevels[0][4],
		\relTime,  ~envLevels[0][5],
	]);
};

~playSynth[1] = {
	Synth(\hh, [
		\out, ~masterBus.index,
		\amp, ~trackVolume[1] * ~trackMutes[1],
		\atkLevel, ~envLevels[1][0],
		\decLevel, ~envLevels[1][1],
		\susLevel, ~envLevels[1][2],
		\atkTime,  ~envLevels[1][3],
		\decTime,  ~envLevels[1][4],
		\relTime,  ~envLevels[1][5],
	]);
};

~playSynth[2] = {
	Synth(\quietsch, [
		\out, ~masterBus.index,
		\amp, ~trackVolume[2] * ~trackMutes[2],
		\atkLevel, ~envLevels[2][0],
		\decLevel, ~envLevels[2][1],
		\susLevel, ~envLevels[2][2],
		\atkTime,  ~envLevels[2][3],
		\decTime,  ~envLevels[2][4],
		\relTime,  ~envLevels[2][5],
	]);
};


~playSynth[3] = {
	Synth(\done, [
		\out, ~masterBus.index,
		\freq, 130,
		\amp, ~trackVolume[3] * ~trackMutes[3],
		\atkLevel, ~envLevels[3][0],
		\decLevel, ~envLevels[3][1],
		\susLevel, ~envLevels[3][2],
		\atkTime,  ~envLevels[3][3],
		\decTime,  ~envLevels[3][4],
		\relTime,  ~envLevels[3][5],
	]);
};

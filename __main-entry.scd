
// TANGIBLE SIGNALS //////////////////////////////

/*



To do:

- re-organise tdef

- GUI rework: names bigger, knobs bigger, steps smller, incl. red color over active steps
- add random KNOB
- random knob, activate by wheel button, assign variable randomness to steps

*/





(


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












// SYSTEM  START  ==============================
// Server.killAll;
s = Server.default;
s.waitForBoot({
	// Start screen
	// ==================================
	1.do({("").postln});
	("TANGIBLE SIGNALS").postln;
	("=================").postln;
	// 1.do({("").postln});

	// Serial Init
	// ==================================
	thisProcess.openUDPPort(12345); // attempt to open 57120
	thisProcess.openPorts; // list all open ports
	("> SuperCollider open UDP ports: " + thisProcess.openPorts).postln;
	~port = 12345; // 57120 is sclang default port
	~pythonFader = NetAddr.new("127.0.0.1", 1111);    // netAddr for fader python3 script
	~pythonPin = NetAddr.new("127.0.0.1", 2222);    // netAddr for fader python3 script
	~pythonWheel = NetAddr.new("127.0.0.1", 3333);    // netAddr for fader python3 script
	("> NetAddresses assigned to Faders + Pins + Wheel ").postln;

	// System vars init
	// ==================================
	i = ();
	TempoClock.default.tempo = (120/30);
	("> init System variables").postln;


	1.8.wait;
	// DO SYNTHS
	// ==================================
	// i.sampleDir = thisProcess.nowExecutingPath.dirname +/+ "AUDIO/";
	i.synths = thisProcess.nowExecutingPath.dirname +/+ "_synths.scd";
	i.synths.load;
	("> Synths loaded").postln;

	1.8.wait;
	// LOAD WINDOW
	// i.window = thisProcess.nowExecutingPath.dirname +/+ "_window.scd";
	// i.window.load;
	s.meter(2, 2);
	s.plotTree;
	// ("> Window loaded ").postln;

	1.8.wait;
	// INIT SYNTHS
	i.sound = thisProcess.nowExecutingPath.dirname +/+ "_sound.scd";
	i.sound.load;
	("> Sound loaded ").postln;

	1.8.wait;
	// INIT ENGINES OSC - SYSTEM - LOOP
	i.engine = thisProcess.nowExecutingPath.dirname +/+ "_engine.scd";
	i.engine.load;
	("> Engine loaded ").postln;

	1.8.wait;
	// LOAD OSC DEF
	i.osc = thisProcess.nowExecutingPath.dirname +/+ "_osc.scd";
	i.osc.load;
	("> OSC communication loaded ").postln;



	1.8.wait;
	// START
	// System loaded
	// ==================================
	1.do({(">").postln});
	(">>>>>>>> System started <<<<<<<<<").postln;
	1.do({(">").postln});
});
)



















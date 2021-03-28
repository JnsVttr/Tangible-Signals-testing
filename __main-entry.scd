
// TANGIBLE SIGNALS //////////////////////////////

/*



To do:

- re-organise tdef

- GUI rework: names bigger, knobs bigger, steps smller, incl. red color over active steps
- add random KNOB
- random knob, activate by wheel button, assign variable randomness to steps

*/





(



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
	// LOAD NO-WINDOW
	i.noWindow = thisProcess.nowExecutingPath.dirname +/+ "_no_window.scd";
	i.noWindow.load;
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



















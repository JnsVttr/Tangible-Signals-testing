
NetAddr.langPort;    // retrieve the current port SC is listening to
NetAddr.localAddr    // retrieve the current IP and port


thisProcess.openUDPPort(12345);
thisProcess.openPorts; // list all open ports
n = NetAddr("127.0.0.1", 12345); // 57120 is sclang default port


OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting off


// receiving from all addresses

// wheel
OSCdef(\wheel, {|msg, time, addr, recvPort| msg.postln}, '/wheel'); // def style
OSCdef(\button, {|msg, time, addr, recvPort| msg.postln}, '/button'); // def style
OSCdef(\touch, {|msg, time, addr, recvPort| msg.postln}, '/touch'); // def style
OSCdef(\push, {|msg, time, addr, recvPort| msg.postln}, '/push'); // def style
OSCdef(\done, {|msg, time, addr, recvPort| msg.postln}, '/done'); // def style
OSCdef(\wheel).clear;
OSCdef(\button).clear;
OSCdef(\touch).clear;
OSCdef(\push).clear;
OSCdef(\done).clear;

// faders
OSCdef(\faderInput, {|msg, time, addr, recvPort| msg.postln}, '/fader'); // def style
OSCdef(\faderInput).clear

// pins
OSCdef(\pinInput, {|msg, time, addr, recvPort| msg.postln}, '/pin'); // def style
OSCdef(\pinInput).clear


// sending to all addresses

// sending to wheel
~pythonWheel = NetAddr.new("127.0.0.1", 3333);    // netAddr for fader python3 script
~pythonWheel.sendMsg("/wheel/startPos", 123, 0, 300, 2000);  // /wheel/startPos, 300, 0, 400, 2000     // pos, rev, speed, acc
~pythonWheel.sendMsg("/wheel/startPos", 123, 3, 200, 2500);  // /wheel/startPos, 300, 0, 400, 2000     // pos, rev, speed, acc
~pythonWheel.sendMsg("/wheel/startPos", 123, 0, 340, 3000);  // /wheel/startPos, 300, 0, 400, 2000     // pos, rev, speed, acc
~pythonWheel.sendMsg("/wheel/startPos", 123, 3, 60, 2000);  // /wheel/startPos, 300, 0, 400, 2000     // pos, rev, speed, acc
~pythonWheel.sendMsg("/wheel/setRev", 1, 0,0,0);                       // revolution
~pythonWheel.sendMsg("/wheel/clearPush", 0,0,0,0);                      // clear push array
~pythonWheel.sendMsg("/wheel/setPush", 0,0, 1 ,0);                      // null, null, revAll (1=all) - set push point at current position,
~pythonWheel.sendMsg("/wheel/setRev", 0, 0,0,0); ~pythonWheel.sendMsg("/wheel/startPos", 123, 0, 550, 8200);
~pythonWheel.sendMsg("/wheel/setRev", 0, 0,0,0); ~pythonWheel.sendMsg("/wheel/startPos", 203, 1, 550, 8200);
~pythonWheel.sendMsg("/wheel/setRev", 0, 0,0,0); ~pythonWheel.sendMsg("/wheel/startPos", 123, 1, 750, 6000);
~pythonWheel.sendMsg("/wheel/setPush", 0,0, 1 ,0);                      // null, null, revAll  - set push point at current position,
~pythonWheel.sendMsg("/wheel/addPush", 120, 1, 0, 0);                   // pos, rev, all , revAll - add push point to array


// sending to fader
~fader = NetAddr.new("127.0.0.1", 1111);    // netAddr for fader python3 script
~fader.sendMsg("/position", 00, 11,22,33,44,55);
~fader.sendMsg("/position", 0,99,30,0,20,20);
~fader.sendMsg("/position", 0,99,0,0,55,99);
~fader.sendMsg("/position", 0,44,77,99,55,99);
~fader.sendMsg("/position", 33,99,82,15,40,60);
~fader.sendMsg("/position", 0,0,0,0,0,0);


// sending to pins
~pins = NetAddr.new("127.0.0.1", 2222);    // netAddr for fader python3 script
~pins.sendMsg("/pinPosition", 0,1,1,1,1,1,1,1);
~pins.sendMsg("/pinPosition", 1,0,0,0,0,0,0,0);
~pins.sendMsg("/pinPosition", 0,1,0,0,0,1,1,1);
~pins.sendMsg("/pinPosition", 1,1,0,0,1,0,0,1);









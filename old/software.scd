

(

// WINDOW
~w = 950;
~h = 550;
~window = Window.new("Tangible Signals", Rect(100, 700, ~w, ~h))
.front
.background_(Color.white);

r = StaticText.new(~window, Rect(0, 18, ~w, 70)).background_(Color.white).stringColor_(Color.black);
r.font = Font("Helvetica", 21);
r.align = \center;
r.string = "TANGIBLE SIGNALS";



// INTERACTION WINDOW
~space = 10;
~btnWindow= UserView.new(~window, Rect(~space, 120, ~w-(~space*2), 280))
.background_(Color.white);

~btnViews = Array.fill(5, nil); // array for btn lines
~checks = Array.fill(4, nil); // array for checkboxes
~mutes = Array.fill(4, nil); // array for checkboxes
~vol = Array.fill(4, nil); // array for checkboxes
~bars = Array.fill(8, nil); // array for light
~btns = Array2D.new(~btnViews.size, 8); // array for buttons
~envs = Array.fill(4, nil); // array for envelopes
~btnViewSpace = 0;


for (0, 4, {|i|
	~btnViewSpace = ~btnViewSpace + 5;
	~btnViews[i] = HLayoutView(~btnWindow,Rect(10,~btnViewSpace,910,60));
	~btnViewSpace = ~btnViewSpace + 60;

	// make space for status bars
	if (i<4, {
		~checks[i] = CheckBox.new(~btnViews[i], Rect(0,0,100,50), ("SEQ " + (i).asString));
		~vol[i] = Slider(~btnViews[i], Rect(0, 0, 20, 120)).action_({(~vol[i].value).postln}).background_(Color.new255(255, 241, 255));
		~mutes[i] = CheckBox.new(~btnViews[i], Rect(0,0,80,50), "M");


		for (0, 7, {|k|
			~btns[i, k] = Button(~btnViews[i],Rect(0,0,50,50)).states_([["", Color.grey, Color.white]]).action_({ ("action").postln; });
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



// CONTROL WINDOW

~controlWindow = UserView.new(~window, Rect(~space, 460, ~w-(~space*2), 80))
//.background_(Color.new255(216, 231, 255));
.background_(Color.white);

~ctrlBtn = Array.fill(3, nil);
~ctrlBtn[0] = Button(~controlWindow,Rect(700,0,50,50)).states_([["stop", Color.grey, Color.white]]).action_({ ("stop").postln; });
~ctrlBtn[1] = Button(~controlWindow,Rect(760,0,50,50)).states_([["play", Color.grey, Color.white]]).action_({ ("play").postln; });

~ctrlEqCheck = CheckBox.new(~controlWindow, Rect(180,0,120,20), "MASTER-EQ");
~ctrlEq = EnvelopeView(~controlWindow, Rect(300, 0, 310, 80))
		    .drawLines_(true)
		    .selectionColor_(Color.red)
		    .drawRects_(true)
		    .resize_(5)
		    .step_(0.05)
		    .action_({arg b; [b.index, b.value].postln})
		    .thumbSize_(5)
		    .value_([[0.0, 0.3, 0.6, 1.0],[0.5,0.5,0.5,0.5]]);

);





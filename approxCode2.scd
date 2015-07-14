/*
__   ____  ____  ____   __  _  _  __  _  _   __  ____  ____
/ _\ (  _ \(  _ \(  _ \ /  \( \/ )(  )( \/ ) / _\(_  _)(  __)
/    \ ) __/ ) __/ )   /(  O ))  (  )( / \/ \/    \ )(   ) _)
\_/\_/(__)  (__)  (__\_) \__/(_/\_)(__)\_)(_/\_/\_/(__) (____)
____  ____   __    ___  ____   __   _  _  _  _  __  __ _   ___
(  _ \(  _ \ /  \  / __)(  _ \ / _\ ( \/ )( \/ )(  )(  ( \ / __)
) __/ )   /(  O )( (_ \ )   //    \/ \/ \/ \/ \ )( /    /( (_ \
(__)  (__\_) \__/  \___/(__\_)\_/\_/\_)(_/\_)(_/(__)\_)__) \___/
https://github.com/chriskiefer/ApproximateProgramming_SC
Chris Kiefer, 2014-15
*/


(
~sliders = {
	//make a bank of sliders to control the gene
	~win = Window.new("multislider", Rect(0,0,600,400)).front;
	~mslid = MultiSliderView(~win,Rect(10,10,25*20+2,300));
	~mslid.elasticMode_(1);
	~mslid.thumbSize_(10);
	~mslid.drawLines_(true);
	~mslid.value=Array.fill(25, {|v| v*0.05}); // size is set automatically when you set the value
	~mslid.action = {|v|~data=v.value.linlin(0,1,-32767,32767);};
};

~approxAlgs = {
	//this code makes synths from genes
	s.options.memSize_(8192*16);

	~traverseTree = {|tre, id, func|
		if (id == tre.id, {
			tre = func.(tre);
		});
		if (tre.args == nil, {
		}, {
			tre.args.size().do({|i|
				tre.args[i] = ~traverseTree.(tre.args[i], id, func);
			});
		});
		tre
	};

	~nodeToCode = {
		|node, index =0, level=0|
		var code = "\n";
		level.do({code = code ++ "\t";});
		if(node.func != nil, {
			code = code ++ "~rz[" ++ index ++ "].nodes[\\" ++ node.func ++ "].(";
			node.args.do({
				|v|
				code = code ++ ~nodeToCode.(v, index, level+1);
				if (v != node.args.last, {
					code = code ++ ",";
				});
			});
			code = code ++ ")";
		}, {
			if(node.val != nil, {
				code = code ++ "~dc.(" ++ node.val + ")";
			});
		}
		);
		code;
	};

	~genUgen = {
		|gene, instance, firstNodeID = 0|
		var numArgs, finished, tree, el, genePos, level, constants, newConstants, targetNode, targetID, targetIdx;
		var newNode, newArgs;
		var code = "";
		var node = ~rz[instance].nodes.keys.choose;
		var nodeID = firstNodeID;
		var nodeIndexes;
		var nodeIdx;
		constants = List.new;
		tree = (\val:nil, \id:nodeID);
		constants.add(nodeID);
		nodeID = nodeID + 1;
		//	gene = {999.rand()}!10;
		genePos = 0;
		level=0;
		gene.postln;

		nodeIdx = gene[genePos] / 1000 * ~rz[instance].nodes.keys.size();
		node = ~rz[instance].nodes.keys.asArray[nodeIdx];
		numArgs = ~rz[instance].nodes[node].def.argNames.size();
		//enough space?

		while ({genePos + numArgs + 1 < gene.size()}, {
			("Gene " ++ ~data[genePos]).postln;
			node.postln;
			("Constants 1: " ++ constants).postln;
			"adding node".postln;
			("genePos, numArgs]: " ++ [genePos, numArgs]).postln;
			targetIdx = gene[genePos+1] /1000 * constants.size();
			("Target: " ++ targetIdx).postln;
			newArgs = gene[genePos+2..genePos+numArgs+1].collect({|x|
				var newThing;
				newThing = (\val:x/1000, \id:nodeID);
				constants.add(nodeID);
				nodeID = nodeID + 1;
				newThing
			});
			("Newargs: " ++newArgs).postln;
			newNode = (\func:node, \id:nodeID, \idist: nodeIdx % 1, \idxs:(genePos..genePos+numArgs+1), \args:newArgs );
			nodeID = nodeID + 1;
			tree = ~traverseTree.(tree, constants[targetIdx], {|x| newNode});
			("Removing const: " ++ targetIdx).postln;
			constants.removeAt(targetIdx);
			("Constants 2: " ++ constants).postln;
			//		gene.size().postln;
			genePos = genePos + numArgs + 1;
			//		genePos.postln;
			if (genePos < gene.size(), {
				nodeIdx = gene[genePos] / 1000 * ~rz[instance].nodes.keys.size();
				node = ~rz[instance].nodes.keys.asArray[nodeIdx];
				numArgs = ~rz[instance].nodes[node].def.argNames.size();
				//			numArgs.postln;
				("NI: " ++ nodeIdx).postln;
			});
		});
		//	Post << tree;
		//	code = ~nodeToCode.(tree, instance);
		////	Post << code << Char.nl;
		//	[code, tree]
		tree
	};
};
~setupServer = {
	s.waitForBoot({
		//this sets up the structures/functions for live coding the component functions
		~dc = {|x|DC.ar(x);};
		~to = {|x,l,h|x.linlin(-1,1,l,h)};
		~rz = List.new;
		~rz.size();
		~rz.add(a = ('nodes':(), 'synthLIFO':LinkedList.new));
		~nx = 0; ~ix=0;
		~rz[~nx].nodes = ();
		SynthDef(\lim, {
			var w = In.ar(0,2);
			w = Compander.ar(w,w, thresh: 0.8, slopeBelow:1,slopeAbove:0.5,clampTime: 0.01, relaxTime:0.01);
			w = Limiter.ar(w, 0.95, 0.1);
			ReplaceOut.ar(0, w);
		}).add;

	});
}
)

~sliders.();
~approxAlgs.();
~setupServer.();


//chose some component functions (or make more...)
~rz[~nx].nodes[\saw] = {|x,y| Saw.ar(x.linexp(-1,1,20,20000),y.linlin(-1,1,0.2,1))}
~rz[~nx].nodes[\pulse] = {|x,y,z| Pulse.ar(x.linexp(-1,1,20,20000),y, z.linlin(-1,1,0.2,1))}
~rz[~nx].nodes[\low] = {|a,b|Resonz.ar(a,~to.(b,20,100,0.5))};
~rz[~nx].nodes[\sin] = {|x,y| SinOsc.ar(x.linexp(-1,1,20,20000), y)}
~rz[~nx].nodes[\add] = {|a,b| (a+b).wrap(-1,1)}
~rz[~nx].nodes[\mul] = {|a,b| (a*b).wrap(-1,1)}
~rz[~nx].nodes[\subtract] = {|a,b| a-b}
~rz[~nx].nodes[\verb] = {|a,b,c,d| FreeVerb.ar(a, b+1/2,c+1/2,d+1/2)}
~rz[~nx].nodes[\imp] = {|a| Impulse.ar(a.linlin(-1,1,0.2,10))}
~rz[~nx].nodes[\imp2] = {|a| Impulse.ar(a.linlin(-1,1,3,50))}
~rz[~nx].nodes[\lfnoise] = {|x| LFDNoise3.ar(x.linexp(-1,1,0.01,2))}
~rz[~nx].nodes[\decimate] = {|a,b,c| Decimator.ar(a,b.linexp(100,4000), c.range(1,5))}
~rz[~nx].nodes[\slew] = {|a,b,c| Slew.ar(a, b.range(1,1000), c.range(1,1000))}

~rz[~nx].nodes[\lfsin] = {|x| SinOsc.ar(x.linexp(-1,1,0.01,2))}
~rz[~nx].nodes[\delay] = {|a,b,c| AllpassC.ar(a,0.4,b.linlin(-1,1,0,0.3, c))}
~rz[~nx].nodes[\res] = {|a,b,c| SinOsc.ar(a.exprange(20,2000)) * Decay2.ar(b,0.01,c.range(0.1,1))};
~rz[~nx].nodes[\knlk] = {|a| Klank.ar(`[[200,1000], nil, [1,1]],a)}
~rz[~nx].nodes[\knlk2] = {|a,b| Klank.ar(`[[200,1000], nil, [1,1]],Impulse.ar(b.linlin(-1,1,0.5,3)))}
~rz[~nx].nodes[\expand] = {|a,b| ({a}!(b*10)).sum }
// ~rz[~nx].nodes[\pwarp] = {|a| Warp1.ar(1,~buf2, Lag.ar(a,10), 1, 0.05, -1, 2, 0, 4)}
// ~rz[~nx].nodes[\pwarp2] = {|a,b| Warp1.ar(1,~buf2, Lag.ar(a,5), ~to.(b,0.1,1), 0.05, -1, 2, 0, 4)}
~rz[~nx].nodes[\nothing] = {|a| DC.ar(0)};
~rz[~nx].nodes[\nothing2] = {|a| DC.ar(0)};
~rz[~nx].nodes[\nothing3] = {|a| DC.ar(0)};
~rz[~nx].nodes.removeAt(\low)




(
//this process is unpredictable, so...

~codeDisplay = Document.new;

~data = {1.0.rand.linlin(0,1,-32767,32767)}!25;

)



~codeLoop.stop
(
//this loop generates new synths from the latest gene values
var gene;
var lastGene = 0!24;
var dist;
var tree1, treeInsert, treeFinal;
~editRegion = -1;

~regMaster = {
	~gMst = Group.after(1);
	NodeWatcher.register(~gMst, true);
};
if (~gMst == nil, {
	~regMaster.()
},{
	if (~gMst.isRunning == false, {
		~regMaster.()
	});
});
~regGens = {
	~gGens = Group.before(~gMst);
	NodeWatcher.register(~gGens, true);
};
if (~gGens == nil, {
	~regGens.()
},{
	if (~gGens.isRunning == false, {
		~regGens.()
	});
});
~lim.free;
~lim = Synth(\lim, [], ~gMst);


~codeLoop = {
	~geneStack = List.new;
	~geneTransform = {|x| (x / 32767 * 2 + 1 / 2 * 999).min(999).max(0);};
	inf.do({
		gene = ~geneTransform.(~data);
		dist = (gene - lastGene).squared.sum.sqrt;
		if (dist > 1, {
			if(~geneStack.size() > 0, {
				tree1 = ~genUgen.(~geneTransform.(~geneStack[0]), ~ix);
				tree1.postln;
				treeInsert = ~genUgen.(gene, ~ix, tree1.size());
				treeInsert.postln;
				~tree = tree1.deepCopy;
				~tree = ~traverseTree.(~tree, ~editRegion, {|x| treeInsert});
				"Done".postln;
			}, {
				~tree = ~genUgen.(gene, ~ix);
			});
			~code = ~nodeToCode.(~tree, ~ix);
			lastGene = gene.copy();
			~codeDisplay.string_(~code, -1, 9999999999);
			~drawTree.();
			try({
				var synthName = ("gen" ++ ~ix).asSymbol;
				var func = ~code.compile;
				if (func != nil, {
					SynthDef(synthName, {
						|active=1|
						var w = SynthDef.wrap(func);
						var e = EnvGen.kr(Env.asr(0.1,1,0.5), active, doneAction:2);
						w = w * e;
						Out.ar(0, w.dup);
					}).send(s, {
						var msg, newSynth;
						newSynth = Synth.basicNew(synthName);
						~rz[~ix].synthLIFO.add(newSynth);
						msg = newSynth.newMsg(~gGens);
						msg
					}.value);
				}, {
					"Code compile error".postln;
				}
				);
			});
			if (~rz[~ix].synthLIFO.size() > 1, {
				~rz[~ix].synthLIFO.popFirst.set(\active,0);
			});
		});
		0.05.wait;
	});
}.fork(AppClock);
)






~tree

~code

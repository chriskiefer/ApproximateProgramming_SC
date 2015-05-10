

(
~win = Window.new("multislider", Rect(0,0,600,400)).front;
~mslid = MultiSliderView(~win,Rect(10,10,25*20+2,300));
~mslid.elasticMode_(1);
~mslid.thumbSize_(10);
~mslid.drawLines_(true);
~mslid.value=Array.fill(25, {|v| v*0.05}); // size is set automatically when you set the value
~mslid.action = {|v|~data=v.value.linlin(0,1,-32767,32767);};


/*~data =[ 3149.0171779394, 5525.7766740322, 10586.169113398, 12178.565828323, -4364.5367227197, -863.37208867073, 2058.3199956417, 3230.5498459339, 1232.2241131067, 11999.184584022, -1846.0276463628, -366.12945127487, 14768.225077033, 3060.8558059931, -16845.007399857, -2418.2992439866, 9896.385477066, 13867.361945033, 6996.4466351271, 27228.915107846, -25152.133761555, 21713.899824142, 3266.6698373556, 2210.9247133732, 679.94799900055 ];

~data=[ 3149.0171779394, 5525.7766740322, 10586.169113398, 12178.565828323, -4364.5367227197, -863.37208867073, 2058.3199956417, 3230.5498459339, 1232.2241131067, 11999.184584022, -1846.0276463628, -366.12945127487, 5768.839568615, 3060.8558059931, -16845.007399857, -2418.2992439866, 9896.385477066, 13867.361945033, 6996.4466351271, 27228.915107846, -25152.133761555, 21713.899824142, 3266.6698373556, 2210.9247133732, 679.94799900055 ];*/



)
~dc = {|x|DC.ar(x);};
~to = {|x,l,h|x.linlin(-1,1,l,h)}
~rz = List.new
~rz.size()
~rz.add(a = ('nodes':(), 'synthLIFO':LinkedList.new))
~nx = 0;
Post << ~rz
~rz[~nx].nodes = ()
~rz[~nx].nodes
~rz[~nx].nodes.removeAt(\low)
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
~rz[~nx].nodes[\lfsin] = {|x| SinOsc.ar(x.linexp(-1,1,0.01,2))}
~rz[~nx].nodes[\delay] = {|a,b| DelayC.ar(a,0.4,b.linlin(-1,1,0,0.3, c))}
~rz[~nx].nodes[\knlk] = {|a| Klank.ar(`[[200,1000], nil, [1,1]],a)}
~rz[~nx].nodes[\knlk2] = {|a,b| Klank.ar(`[[200,1000], nil, [1,1]],Impulse.ar(b.linlin(-1,1,0.5,3)))}
~rz[~nx].nodes[\expand] = {|a,b| ({a}!(b*10)).sum }
~rz[~nx].nodes[\pwarp] = {|a| Warp1.ar(1,~buf2, Lag.ar(a,10), 1, 0.05, -1, 2, 0, 4)}
~rz[~nx].nodes[\pwarp2] = {|a,b| Warp1.ar(1,~buf2, Lag.ar(a,5), ~to.(b,0.1,1), 0.05, -1, 2, 0, 4)}
~rz[~nx].nodes[\nothing] = {|a| DC.ar(0)};
~rz[~nx].nodes[\nothing2] = {|a| DC.ar(0)};
~rz[~nx].nodes[\nothing3] = {|a| DC.ar(0)};

~ix = 0;

~rz

s
(
SynthDef(\lim, {
	var w = In.ar(0,2);
	w = Compander.ar(w,w, thresh: 0.8, slopeBelow:1,slopeAbove:0.5,clampTime: 0.01, relaxTime:0.01);
	w = Limiter.ar(w, 0.95, 0.1);
	ReplaceOut.ar(0, w);
}).add;
SynthDef(\MIR, {
	var mfFeat;
	var w = In.ar(0,2);
	var fft;
	fft = FFT(LocalBuf(512,1), w.sum);
	mfFeat = MFCC.kr(fft);
	SendReply.kr(Impulse.kr(25), 'mfcc', mfFeat, 7);
}).add;

~codeDisplay = Document.new;
~codeDisplay.mouseDownAction_({"m".postln;});
~synthLIFO = LinkedList.new;


~data = 1!24;


)



(



MIDIClient.init;
~sources = MIDIClient.sources;


~midiUids=();
~midiUids.saffire = ~sources.detect({|x|
	(
	(x.device.contains("UM-1") and: x.name.contains("UM-1"))
	)
});


MIDIIn.connect(0,~midiUids.saffire);
)
(
~controllerValues = 0!64;
~highResValues = 0.0 ! 32;
MIDIIn.control={
	|s,c,n,v|
	var msbi, lsbi;
	~controllerValues[n] = v;
	if (n < 32, {msbi=n;lsbi = n + 32;}, {msbi = n - 32; lsbi = n});
	~highResValues[msbi] = (~controllerValues[msbi] << 7) + ~controllerValues[lsbi] / 16384;
	~data = ~highResValues[..23].linlin(0,1,-32767,32767);
}
)



~data = {1.0.rand.linlin(0,1,-32767,32767)}!25;


~codeLoop.stop
(
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
	~mir.free;
	~mir = Synth(\MIR, [], ~gMst);


	~codeLoop = {
		~geneStack = List.new;
		~geneTransform = {|x| (x / 32767 * 2 + 1 / 2 * 999).min(999).max(0);};
		inf.do({


//			gene = ~data / 32767 * 2 + 1 / 2 * 999;
//			gene = gene.min(999).max(0);
			gene = ~geneTransform.(~data);



			dist = (gene - lastGene).squared.sum.sqrt;
			if (dist > 1, {



//				~genData = ~genUgen.(gene, ~ix);
//				~code = ~genData[0];
//				~tree = ~genData[1];
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
				//~codeDisplay.string_(~code);



				~drawTree.();



				try({
					var synthName = ("gen" ++ ~ix).asSymbol;
					SynthDef(synthName, {
						|active=1|
						var w = SynthDef.wrap(~code.compile);
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
				});
				if (~rz[~ix].synthLIFO.size() > 1, {
					~rz[~ix].synthLIFO.popFirst.set(\active,0);
				});
			});
			0.05.wait;


		});
	}.fork(AppClock);
)




(
s.options.memSize_(8192*16);
// ~buf1=Buffer.read(s,"/Users/ck84/Documents/docsRepos/sc/sounds/playground2.wav");
// ~buf2=Buffer.read(s,"/Users/ck84/Documents/docsRepos/sc/sounds/playground1.wav");




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

)

~tree

~code

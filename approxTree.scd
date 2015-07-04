/*
__   ____  ____  ____   __  _  _  __  _  _   __  ____  ____
/ _\ (  _ \(  _ \(  _ \ /  \( \/ )(  )( \/ ) / _\(_  _)(  __)
/    \ ) __/ ) __/ )   /(  O ))  (  )( / \/ \/    \ )(   ) _)
\_/\_/(__)  (__)  (__\_) \__/(_/\_)(__)\_)(_/\_/\_/(__) (____)
____  ____   __    ___  ____   __   _  _  _  _  __  __ _   ___
(  _ \(  _ \ /  \  / __)(  _ \ / _\ ( \/ )( \/ )(  )(  ( \ / __)
) __/ )   /(  O )( (_ \ )   //    \/ \/ \/ \/ \ )( /    /( (_ \
(__)  (__\_) \__/  \___/(__\_)\_/\_/\_)(_/\_)(_/(__)\_)__) \___/
Tree visualiser
https://github.com/chriskiefer/ApproximateProgramming_SC
Chris Kiefer, 2014-15
*/


(
//start off a code tree visualiser window
if (~treeWindow != nil, {~treeWindow.close});
~treeWindow = Window.new("tree")
	.acceptsMouseOver_(true).setInnerExtent(700,300)
	.alpha_(1.0)
	.front;
~treeWindow.view.background_(Color.white);

~links = List.new;
~treeWindow.drawHook = {
	Pen.strokeColor = Color.gray;
	~links.do({
		|v|
		Pen.moveTo(v[0]@v[1]);
		Pen.lineTo(v[2]@v[3]);
	});
	Pen.stroke;
};
~treeWindow.refresh();
~drawTree = {
	if (~labels == nil, {
		~labels = List.new;
	},{
		~labels.do({
			|v| v.remove;
		});
		~labels.clear();
	});
	~links.clear;
	~traverseAllTree = {|tre, parent, level, dict, func|
		#tre,dict = func.(tre, parent, level, dict);



		if (tre.args == nil, {
		}, {
			tre.args.size().do({|i|
				tre.args[i] = ~traverseAllTree.(tre.args[i], tre, level+1, dict, func);
			});
		});
		tre
	};
	~treeStats=();
	~traverseAllTree.(~tree, ~tree, 0, ~treeStats, {|x, parent, level, dict|
		var st;
		if(dict[level]==nil, {
			dict[level]=1;
		}, {
			dict[level] = dict[level]+1;
		});
		[x,dict]
	});

	~newTreeStats = ();
	~traverseAllTree.(~tree, nil,0, ~newTreeStats, {|x, parent, level, dict|
		var st, lx, ly;
		if(dict[level]==nil, {
			dict[level]=1;
		}, {
			dict[level] = dict[level]+1;
		});
		ly = 20 + (40 * level);
		if (parent != nil, {


			lx = parent[\label].bounds.left - 70 + (70 * (dict[level]-1));
			~links.add([parent[\label].bounds.left + (parent[\label].bounds.width / 2),
				parent[\label].bounds.top + parent[\label].bounds.height,
				lx + (parent[\label].bounds.width / 2), ly]);
		}, {
			lx = ~treeWindow.bounds.width/2;
		});



		st = StaticText(~treeWindow, Rect(lx, ly, 60, 20))


		.enabled_(true)
		.background_(Color.gray(0.9))
		.font_(Font("Courier",11))
		.mouseDownAction_({|v|~geneStack.add(~data); ~editRegion = x.id;})
		.mouseOverAction_({|v, x, y|})
		;
		~labels.add(st);
		x[\label] = st;



		if (x.func != nil, {
			st.string = x.func;
			st.align_(\centering);


			st.background_(Color.gray(0.9).blend(Color.red(0.9), abs(x.idist - 0.5)))



		}, {
			if (x.val != nil, {
				st.string = x.val;
				st.background_(Color.green(1.0 - (x.val * 0.5)));
			});
		});
		[x,dict]
	});
	~treeWindow.refresh();
};
~drawTree.();


)
~tree.args.size()


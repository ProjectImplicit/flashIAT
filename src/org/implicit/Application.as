/**
 * Copyright 2005 University of Virginia
 * Main class.  Loads/parses properties and XML.  Then builds visual assets and launches task.
 *
 */
import LuminicBox.Log.ConsolePublisher;
import LuminicBox.Log.TracePublisher;
import LuminicBox.Log.PostPublisher;
import LuminicBox.Log.Logger; 
import LuminicBox.Log.Console;
import org.implicit.bean.*;
import org.implicit.util.Proxy;
import org.implicit.util.XMLConstruct;
import org.implicit.Task;
class org.implicit.Application {
	var iat:IAT;
	var iatXML;
	var numLoaded=0;
	var numToLoad=0;
	var loading_mc;
	var font;
	var fontSize;
	var fontColor;	 
	var propLoader;
	var props;
	var imageURL;
	var connector;
	var task;
	// Entry Point
	static function main(){
		 _root.application = new Application(); 
	}
	 
	function Application(){
	
			_root.log = new LuminicBox.Log.Logger("iatLogger");
			//_root.log.addPublisher( new PostPublisher() );
			_root.log.addPublisher( new ConsolePublisher() );
			_root.err = function(a,m){_root.log.error(a,m);}; 
		if (_root.i == undefined)
			_root.i = "iat.xml";
		if (_root.p == undefined)
			_root.p = "default.xml";
		if (_root.r == undefined)
			_root.r = "";
		
		Stage.showMenu=false; // hide content menu
		// make loading label
		loading_mc = _root.createEmptyMovieClip("load"+_root.getNextDepth(),_root.getNextDepth());
		buildTextClip("", "", loading_mc);
		loading_mc._visible=true;
		// Load the properties
		propLoader = new XML();
		propLoader.ignoreWhite = true;
		propLoader.onLoad=Proxy.create(this,propIn);
		propLoader.load(_root.p+"?nocache="+getTimer());
}
		
	function init()
	{
		//Set the path for for the images 
		if (_root.r == undefined || _root.r == "")
			imageURL = props.IMAGE_URL;
		else
			imageURL = _root.r;
		
		_root.log.debug("imageURL="+imageURL+ " props.IMAGE_URL=" + props.IMAGE_URL + " _root.r=" + _root.r);

		setLoadingMessage(props.INITIAL_LOADING);
		iatXML=new XMLConstruct();
		iatXML.onLoad=Proxy.create(this,dataIn);
		iatXML.load(_root.i+"?nocache="+getTimer()); 
	}
		
	function dataIn(success){
		if (success){
				buildIAT();
		}
		else{
			_root.err("Could not load study file: "+_root.i);
			setLoadingMessage(props.FAILED_LOADING);
		}
	}
	
	function imageIn(mc,initOb){
		numLoaded++;
		if (numLoaded == numToLoad)
			loadingComplete();
		else
        	setLoadingMessage(props.IMAGE_LOADING + numLoaded + "-"+numToLoad);
		placeClip(mc,initOb);
	}	
	function audioIn(success){
		if(success){
		numLoaded++;
		if (numLoaded == numToLoad)
			loadingComplete();
		else
        	setLoadingMessage(props.IMAGE_LOADING + numLoaded + "-"+numToLoad);
		}
	}
	
	function loadingComplete(){
		if (iatValid()){
			setLoadingMessage(props.BEGIN_LABEL); 
			loading_mc.onPress = Proxy.create(this,beginTask);
		}
		else
		{
			_root.err({xml:iatXML,iat:iat},"IAT could not be parsed");
			setLoadingMessage(props.FAILED_LOADING);
		}
	}
	
	function beginTask(){
		loading_mc._visible=false;
		//Mouse.hide();
		loading_mc.onPress = undefined;
		task = new Task(iat,this);
		task.runBlock();
	}
	
 	function setLoadingMessage(mess){
		loading_mc.tf.htmlText = "<font face=\""+props.FONT+"\" size=\""+props.FONTSIZE+"\" color=\"#"+props.FONTCOLOR+"\">"+mess+"</font>";
		placeClip(loading_mc);
		loading_mc._y = (Stage.height*0.75)-(loading_mc._height/2); //YBYB: added that so the cursor will not mask the target stimuli, but it didn't work*/
		loading_mc._visible=true;
	}
	
	function placeClip(mc,initOb){	
		
		if (initOb.alpha != undefined)
			mc._alpha = parseInt(initOb.alpha);
		if (initOb.w != undefined)
			 mc._width = parseInt(initOb.w);
		if (initOb.h != undefined)
			mc._height = parseInt(initOb.h);
	
		if (initOb.x != undefined)
			mc._x = initOb.x;
		else
			mc._x = (Stage.width/2)-(mc._width/2);
		if (initOb.y != undefined)
			mc._y = initOb.y;
		else
			mc._y = (Stage.height/2)-(mc._height/2);		
			
	}
		
	
	function buildTextClip(content,style,mc,initOb){
		mc._visible=false;
		mc.createTextField("tf",1,0,0,initOb.w,initOb.h);
		if (initOb.w>0)
			mc.tf.wordWrap = true;
		initOb.w=undefined;
		mc.tf.autoSize = true;
		mc.tf.selectable = false;
		mc.tf.html = true;
		mc.tf.multiline = true;
		mc.tf.htmlText = style+content+"</font>";
		placeClip(mc,initOb);
	}
	
	function buildImageClip(file, mc,initOb) {
    	mc._visible = false; 
    	numToLoad++;
        setLoadingMessage(props.IMAGE_LOADING + numLoaded + "-"+numToLoad);
    	mc.loadjpg(imageURL+file);
		mc.onComplete=Proxy.create(this,imageIn,mc,initOb);
	} 

	function propIn(success){
		var n;
		var v;
		props = new Array();
		if (success){
			for (var i=0;i<propLoader.firstChild.childNodes.length;i++){
					n = propLoader.firstChild.childNodes[i].attributes.name;
					v = propLoader.firstChild.childNodes[i].firstChild.nodeValue;
					props[n] = v;
					}
			if (props.DEBUG == "1"){
				_root.log.addPublisher( new TracePublisher() );
				_root.log.addPublisher( new ConsolePublisher() );
				_root.log.info("Application Started"); 
				_root.l = function(a,m){_root.log.info(a,m);}; 
			}
			if (props["NEXT_URL"] == undefined)
				_root.err(propLoader,"Could not parse prop file");
			else
				props["NEXT_URL"] = props["NEXT_URL"] + ";jsessionid="+_root.JID;
			if (props["POST_URL"] == undefined)
				_root.err(propLoader,"Could not parse prop file");
			else
				props["POST_URL"] = props["POST_URL"] + ";jsessionid="+_root.JID;
				
			init();
		}
		else {
			_root.err("Could not load prop file:" + _root.p);
			setLoadingMessage("<font size=\"24\">!!!</font>");  // could not load props, so show error code
		}
	}

	function buildIAT(){
		var cat;
		var stim;
		var bl;
		var style; 
		var inst;
		var err;
		var sep;
		var mcInitOb;
		var catElement;
		var stimElement;
		setLoadingMessage(props.BUILD_LOADING);
		iat = new IAT;
		iat.categories = new Array();
		iat.blocks = new Array();
		iat.name = iatXML.IATName._value;
		iat.reportBlocks=iatXML.ReportBlocks._value;
		
		if (iatXML.attributes.results == "false")
		    	iat.reportResult = false;

		if (parseInt(iatXML.attributes.gamescore) > 0)
		    	iat.gameScore = parseInt(iatXML.attributes.gamescore);

		if (iatXML.attributes.hidegamescore == "true")
		    	iat.hideGameScore = true;

		if (parseInt(iatXML.attributes.fastResp) > 0)
		    	iat.fastResp = parseInt(iatXML.attributes.fastResp);

		if (parseInt(iatXML.attributes.fastRespScore) > 0)
		    	iat.fastRespScore = parseInt(iatXML.attributes.fastRespScore);

		if (parseInt(iatXML.attributes.slowResp) > 0)
		    	iat.slowResp = parseInt(iatXML.attributes.slowResp);

		if (parseInt(iatXML.attributes.slowRespScore) > 0)
		    	iat.slowRespScore = parseInt(iatXML.attributes.slowRespScore);
		
		if (parseInt(iatXML.attributes.fastResp) > 0)
		    	iat.fastResp = parseInt(iatXML.attributes.fastResp);

		if (parseInt(iatXML.attributes.scoreEquation) > 0)
		    	iat.equation = parseInt(iatXML.attributes.scoreEquation);

		if (parseInt(iatXML.attributes.errScore) > 0)
		    	iat.errScore = parseInt(iatXML.attributes.errScore);

		if (parseInt(iatXML.attributes.divideBy) > 0)
		    	iat.divideBy = parseInt(iatXML.attributes.divideBy);

		// loop through and build blocks
		for(var i=0;i<iatXML.Block.length;i++){
			bl = new Block();
			bl.stimuli = new Array();
			bl.trialCount = iatXML.Block[i].TrialCount._value;
			bl.pairingDef = iatXML.Block[i].BlockPairingDefinition._value.split( ',' ); 

			if (parseInt(iatXML.Block[i].attributes.nRepeat) > 0)
				bl.nRepeat = parseInt(iatXML.Block[i].attributes.nRepeat);
			if (iatXML.Block[i].attributes.limitSequence == "true")
				bl.limitSequence = true;
			//if (iatXML.Block[i].attributes.terminateIfRepeats == "true")
				//bl.terminateIfRepeats = true;
	
			// make repeat because of fast responses tag, if exists.
			//_root.log.debug("block-maxFast="+iatXML.Block[i].RepeatFast.attributes.maxFast);
			if (iatXML.Block[i].RepeatFast._value != undefined) 
			{
				//Read attributes.
				if (parseInt(iatXML.Block[i].RepeatFast.attributes.maxFast) != undefined)
						bl.maxFast = parseFloat(iatXML.Block[i].RepeatFast.attributes.maxFast);
				if (parseInt(iatXML.Block[i].RepeatFast.attributes.fastLat) != undefined)
						bl.fastLat = parseFloat(iatXML.Block[i].RepeatFast.attributes.fastLat);
				
				//_root.log.debug("bl.maxFast="+bl.maxFast);

				//Make message to user
				font=props.FONT;
				fontSize=props.FONTSIZE;
				fontColor=props.FONTCOLOR;
				var fastMsg;
				if (iatXML.Block[i].RepeatFast.attributes.type == "image") 
				{
					_root.l("build repeat fast image");
					bl.fastMsg_mc = buildStim(iatXML.Block[i].RepeatFast).mc;
					_root.l(bl.fastMsg_mc);
				}
				else
				{
					fastMsg = iatXML.Block[i].RepeatFast._value;
					bl.fastMsg_mc = _root.createEmptyMovieClip("fstMsg"+_root.getNextDepth(),_root.getNextDepth());
					style="<font face=\""+font+"\" size=\""+fontSize+"\" color=\"#"+fontColor+"\">";
					buildTextClip(fastMsg, style,bl.fastMsg_mc,{w:Stage.width-props.INST_MARGIN-props.INST_MARGIN});
				}
			}
			// make repeat because of error responses tag, if exists.
			//_root.log.debug("block-maxerr="+iatXML.Block[i].RepeatErr.attributes.maxErr);
			if (iatXML.Block[i].RepeatErr._value != undefined) 
			{
				//Read attributes.
				if (parseInt(iatXML.Block[i].RepeatErr.attributes.maxErr)  != undefined)
						bl.maxErr = parseFloat(iatXML.Block[i].RepeatErr.attributes.maxErr);
				
				//_root.log.debug("bl.maxErr="+bl.maxErr);
				//Make message to user
				font=props.FONT;
				fontSize=props.FONTSIZE;
				fontColor=props.FONTCOLOR;
				var errMsg;
				if (iatXML.Block[i].RepeatErr.attributes.type == "image") 
				{
					_root.l("build repeat fast image");
					bl.ErrMsg_mc = buildStim(iatXML.Block[i].RepeatErr).mc;
					_root.l(bl.errMsg_mc);
				}
				else
				{
					errMsg = iatXML.Block[i].RepeatErr._value;
					bl.errMsg_mc = _root.createEmptyMovieClip("errMsg"+_root.getNextDepth(),_root.getNextDepth());
					style="<font face=\""+font+"\" size=\""+fontSize+"\" color=\"#"+fontColor+"\">";
					buildTextClip(errMsg, style,bl.errMsg_mc,{w:Stage.width-props.INST_MARGIN-props.INST_MARGIN});
				}
			}
			/*if (iatXML.Block[i].TerminateMessage._value != undefined) 
			{
				bl.termMsg = iatXML.Block[i].TerminateMessage._value;
			}*/

			// make instructions
			font=props.FONT;
			fontSize=props.FONTSIZE;
			fontColor=props.FONTCOLOR;
			inst=props.INSTRUCTIONS;
			if (iatXML.Block[i].Instructions._value != undefined) {
				inst = iatXML.Block[i].Instructions._value;
			}
			if (iatXML.Block[i].Instructions.attributes.type == "image") {
				_root.l("build image");
				bl.instructions_mc = buildStim(iatXML.Block[i].Instructions).mc;
				_root.l(bl.instructions_mc);
			}
			else{
				bl.instructions_mc = _root.createEmptyMovieClip("inst"+_root.getNextDepth(),_root.getNextDepth());
				style="<font face=\""+font+"\" size=\""+fontSize+"\" color=\"#"+fontColor+"\">";
				buildTextClip(inst, style,bl.instructions_mc,{w:Stage.width-props.INST_MARGIN-props.INST_MARGIN});
			}
			// make category seperator
			font=props.FONT;
			fontSize=props.FONTSIZE;
			fontColor=props.FONTCOLOR;
			sep=props.SEP;
			bl.leftSeparator_mc = _root.createEmptyMovieClip("sep"+_root.getNextDepth(),_root.getNextDepth());
			bl.rightSeparator_mc = _root.createEmptyMovieClip("sep"+_root.getNextDepth(),_root.getNextDepth());
			if (iatXML.Block[i].CategorySeparator._value != undefined) {
				if (iatXML.Block[i].CategorySeparator.attributes.color != undefined)
					fontColor = iatXML.Block[i].CategorySeparator.attributes.color;
				if (iatXML.Block[i].CategorySeparator.attributes.fontSize != undefined)
					fontSize = iatXML.Block[i].CategorySeparator.attributes.fontSize;
				if (iatXML.Block[i].CategorySeparator.attributes.font != undefined)
					font = iatXML.Block[i].CategorySeparator.attributes.font;
				sep = iatXML.Block[i].CategorySeparator._value;
			}
			style="<font face=\""+font+"\" size=\""+fontSize+"\" color=\"#"+fontColor+"\">";
			buildTextClip(sep, style,bl.leftSeparator_mc);
			buildTextClip(sep, style,bl.rightSeparator_mc);

			//make background stim
			for (var j=0;j<iatXML.Block[i].Stimulus.length;j++){
				bl.stimuli.push(buildStim(iatXML.Block[i].Stimulus,style));
			}

			// make error label
			font=props.FONT;
			fontSize=props.FONTSIZE;
			fontColor=props.FONTCOLOR;	
			err=props.ERR;
			bl.error_mc = _root.createEmptyMovieClip("err"+_root.getNextDepth(),_root.getNextDepth());
			if (iatXML.Block[i].ErrorLabel._value != undefined){
				if (iatXML.Block[i].ErrorLabel.attributes.color != undefined)
					fontColor = iatXML.Block[i].ErrorLabel.attributes.color;
				if (iatXML.Block[i].ErrorLabel.attributes.fontSize != undefined)
					fontSize = iatXML.Block[i].ErrorLabel.attributes.fontSize;
				if (iatXML.Block[i].ErrorLabel.attributes.font != undefined)
					font = iatXML.Block[i].ErrorLabel.attributes.font;
				err = iatXML.Block[i].ErrorLabel._value;
			}
			style="<font face=\""+font+"\" size=\""+fontSize+"\" color=\"#"+fontColor+"\">";
			buildTextClip(err,style, bl.error_mc);
			bl.error_mc._y = Stage.height - bl.error_mc._height - props.ERROR_PADDING;
			
			// store Stim Delay
			bl.delay=props.STIM_DELAY;
			if (iatXML.Block[i].attributes.StimulusDelay != undefined){
				bl.delay=iatXML.Block[i].attributes.StimulusDelay;
			}
			
			// store error correction
			bl.errcor=props.ERR_CORR;
			if (iatXML.Block[i].attributes.ErrorCorrection != undefined){
				bl.errcor=iatXML.Block[i].attributes.ErrorCorrection;
			}
			
			// store error correction
			bl.errfeed=props.ERR_FEED;
			if (iatXML.Block[i].attributes.ErrorFeedback != undefined){
				bl.errfeed=iatXML.Block[i].attributes.ErrorFeedback;
			}
			
			iat.blocks.push(bl);
		}	

		// loop through and build categories
		for(var i=0;i<iatXML.Categories.Category.length;i++){
			catElement = iatXML.Categories.Category[i];
			cat = new Category;
			mcInitOb = new Object();
			cat.stimuli = new Array();
			font=props.FONT;
			fontSize=props.FONTSIZE;
			fontColor=props.FONTCOLOR;
			
			cat.name = catElement.Stimuli.CategoryName._value;
			cat.mc=_root.createEmptyMovieClip("cat"+_root.getNextDepth(),_root.getNextDepth());
				
			if (catElement.attributes.color != undefined)
				fontColor = catElement.attributes.color;
			if (catElement.attributes.fontSize != undefined)
				fontSize = catElement.attributes.fontSize;
			if (catElement.attributes.font != undefined)
				font = catElement.attributes.font;
			if (catElement.Stimuli.CategoryName.attributes.image != undefined){	
				buildImageClip(catElement.Stimuli.CategoryName.attributes.image,cat.mc, mcInitOb);
			}
			else{
				cat.style = "<font face=\""+font+"\" size=\""+fontSize+"\" color=\"#"+fontColor+"\">";	
				buildTextClip(cat.name,cat.style,cat.mc,mcInitOb);
			}
			// Build stimuli
			for (var j=0;j<catElement.Stimuli.Stimulus.length;j++){
								
			if (catElement.Stimuli.Stimulus[j].attributes.color != undefined){
				var s = "<font face=\""+font+"\" size=\""+fontSize+"\" color=\"#"+catElement.Stimuli.Stimulus[j].attributes.color+"\">";	
				cat.stimuli.push(buildStim(catElement.Stimuli.Stimulus[j],s));	
			} 
			else
				cat.stimuli.push(buildStim(catElement.Stimuli.Stimulus[j],cat.style));
			}
		iat.categories.push(cat);
		}
		

		
		// store reportblocks
		iat.reportBlocks = iatXML.ReportBlocks._value.split( ',' );
		
		// store results
		var cutoff;
		iat.results = new Array();
		for(var i=0;i<iatXML.Results.Result.length;i++){
			cutoff = parseFloat(iatXML.Results.Result[i].attributes.cutoff);
			if ((cutoff == undefined) || (cutoff == NaN))
				_root.err("The cutoff could not be parsed:"+iatXML.Results.Result[i].attributes.cutoff);
			iat.results.push({id:iatXML.Results.Result[i].attributes.id,cutoff:cutoff,text:iatXML.Results.Result[i]._value});
		}
		
		//  Loading is done if no images
		if (numLoaded == numToLoad){
					loadingComplete();
		}	
	}
	
	function buildStim(stimElement,style){
				var stim = new Stimulus();
				var mcInitOb = new Object();
				stim.content = stimElement._value;
				stim.mc=_root.createEmptyMovieClip("stim"+_root.getNextDepth(),_root.getNextDepth());
				
				// mc placement
				if (stimElement.attributes.x != undefined)
					mcInitOb.x = stimElement.attributes.x;					
				if (stimElement.attributes.y != undefined)
					mcInitOb.y = stimElement.attributes.y;
				if (stimElement.attributes.width != undefined)
					mcInitOb.w = stimElement.attributes.width;
				if (stimElement.attributes.height != undefined)
					mcInitOb.h = stimElement.attributes.height;
				if (stimElement.attributes.transparency != undefined)
					mcInitOb.alpha = stimElement.attributes.transparency;

				if (stimElement.attributes.type == "image"){	
					stim.type = 1;
					buildImageClip(stimElement._value,stim.mc,mcInitOb);
				}
				else{
					stim.type = 0;
					buildTextClip(stimElement._value, style, stim.mc,mcInitOb);
				}
			if (stimElement.attributes.audio != undefined) 
				loadAudio(stimElement.attributes.audio,stim)
				
				return(stim);
	
	}
	function loadAudio(file, stim){
		stim.audio = new Sound();
    	numToLoad++;
        setLoadingMessage(props.IMAGE_LOADING + numLoaded + "-"+numToLoad);

		stim.audio.onLoad=Proxy.create(this,audioIn);
		    	stim.audio.loadSound(imageURL+file);
	} 
		
	
	function iatValid(){
		if (iat.blocks.length <= 0)
			return false;
		if (iat.categories.length <= 0)
			return false;
		if (iat.name.length <= 0)
			return false;
		if (iat.reportResult){
			if (iat.results.length <= 0)
				return false;
			for (var i=0;i<iat.results.length-1;i++){
				if (!(iat.results[i].cutoff < iat.results[i+1].cutoff))
					return false;
			}
		}
		return true;
	}
}
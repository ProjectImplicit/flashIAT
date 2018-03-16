/**
 * Copyright 2005 University of Virginia
 * Task execution class.  
 *
 */
import org.implicit.TrialSet;
import org.implicit.util.Proxy;
import org.implicit.Selector6;
import org.implicit.Scorer;
import org.implicit.GameScorer;

class org.implicit.Task {
	var def;
	var tl=1;  // top left 
	var tr=0;  // top right
	var bl=3;  // bottom left
	var br=2;  // bottom right
	var ls_mc;
	var rs_mc;
	var ts;
	var app;
	var pad; 
	var ipad;
	var bnum=0;
	var nBReport=0; //YBYB: this just for DB report, because we had bugs when we repeated the same block
	var currTrial=0;
	var sel;
	var stimInterval;
	var completedTrials=0;
	var keys;
	var trial;
	var poster;
	var completed;
	var scoringData;
	var gameScore; //YBYB: add a game score to entertain the participants
	var gameScorer; //A class to update the game's score
	var gscr_mc; //YBYB: add a game score to entertain the participants
	var nErrs;
	var nFasts;
	var repeatErr = false;
	var repeatFast = false;
	var inBlock = false;
	var nRepeat; //how many times we repeated the same block
	
	function Task (def,app){
		this.app=app;
		this.def = def;
		ts = new TrialSet(Proxy.create(this,onResult),parseInt(app.props.SKIP));
		pad = parseInt(app.props.CAT_PADDING);
		ipad = parseInt(app.props.INST_PADDING);
		keys = [app.props.LEFT_KEY,app.props.RIGHT_KEY];
		poster = new LoadVars;
		scoringData = new Array();
		completed=false;
		gameScorer = new GameScorer(def);
		gameScore = 0;
		nRepeat = 0;
		//YBYB: make game-score label
		gscr_mc = _root.createEmptyMovieClip("load"+_root.getNextDepth(),_root.getNextDepth());
		buildTextClip("", "", gscr_mc);
		
	}
	
	function onResult(lat,err){
		var responseLabel;
		if (err==1)
		{
			nErrs++;
			if ((def.blocks[bnum].pairingDef[tl] == trial.cat) || (def.blocks[bnum].pairingDef[bl] == trial.cat) )
				responseLabel = def.blocks[bnum].leftLabels;
			else 
				responseLabel = def.blocks[bnum].rightLabels;
		}
		else
		{
			if ((def.blocks[bnum].pairingDef[tl] == trial.cat) || (def.blocks[bnum].pairingDef[bl] == trial.cat) )
				responseLabel = def.blocks[bnum].leftLabels;
			else 
				responseLabel = def.blocks[bnum].rightLabels;
		}
		if (lat < def.blocks[bnum].fastLat)
		{
			nFasts++;
		}
		showGameScore(lat, err);
		poster.addResultValue("trialNum", completedTrials);
		poster.addResultValue("trialName", def.categories[trial.cat].stimuli[trial.stim].content);
		poster.addResultValue("trialResp", responseLabel);
		poster.addResultValue("trialErr", err);
		poster.addResultValue("trialLatency", lat);
		scoringData.push({block:parseInt(bnum),err:err,lat:lat});
		
		completedTrials++;
		
		if  ((completedTrials >= def.blocks[bnum].trialCount) || (lat == -1)){ 
			hideCategoryLabels();
			hideBackgroundStimuli();
			poster.addResultValue("trialsSent", def.blocks[bnum].trialCount);
			//_root.log.debug(" go to end block");
			endBlock();
		}
		
		else{ // Select another trial
			stimInterval = setInterval(Proxy.create(this,selectTrial),def.blocks[bnum].delay);
		}
	}

	function endBlock()
	{
		//_root.log.debug(" def.blocks[" + bnum + "].nRepeat="+def.blocks[bnum].nRepeat + " nRepeat="+ nRepeat);
		//var bTerm = false;
		inBlock = false;
		if (def.blocks[bnum].nRepeat > nRepeat)
		{
			//_root.log.debug(" nErrs=" + nErrs + " trialCount="+def.blocks[bnum].trialCount + " maxErr="+ def.blocks[bnum].maxErr);
			if (nErrs > (def.blocks[bnum].trialCount * def.blocks[bnum].maxErr))
			{			
				nRepeat++;
				repeatErr = true;
				showRepeatErrMsg();
				listen();
			}

			//_root.log.debug(" nFasts=" + nFasts + " trialCount="+def.blocks[bnum].trialCount + " maxFast="+ def.blocks[bnum].maxFast);
			if (repeatErr == false && nFasts > (def.blocks[bnum].trialCount * def.blocks[bnum].maxFast))
			{
				nRepeat++;
				repeatFast = true;
				showRepeatFastMsg();
				listen();
			}
		}
		/*else if (def.blocks[bnum].nRepeat > 0 && def.blocks[bnum].terminateIfRepeats)
		{
			//_root.log.debug("EARLY TERMINATE");
			hideCategoryLabels();
			hideBackgroundStimuli();
			bTerm = true;
			app.setLoadingMessage(def.blocks[bnum].termMsg);
			poster.sendAndLoad(app.props.POST_URL, poster, "POST");
			stimInterval = setInterval(Proxy.create(this,nextTask),3000);
		}*/
		
		//if (!repeatErr && !repeatFast && !bTerm)
		if (!repeatErr && !repeatFast)
		{
			nRepeat = 0;
			bnum++;
			toNextBlock();
		}		
	}

	function toNextBlock()
	{
		nBReport++;
		if (bnum < def.blocks.length)
		{
			poster.sendAndLoad(app.props.POST_URL, poster, "POST");
			runBlock();
		}
		else
		{
			app.setLoadingMessage(app.props.END_WAIT); 
			poster.sendAndLoad(app.props.POST_URL, poster, "POST");
			stimInterval = setInterval(Proxy.create(this,nextTask),3000);
		}	
	}
	
	function runBlock(){
			var b,blockCats;
				
			completedTrials = 0;
			nErrs = 0;
			nFasts = 0;
			blockCats = new Array();  // block meta data needed to pick stimuli order
			for (var j=0;j<def.blocks[bnum].pairingDef.length;j++){
				blockCats[j] = {id: def.blocks[bnum].pairingDef[j],
								size: def.categories[def.blocks[bnum].pairingDef[j]].stimuli.length};
			}

			sel = new Selector6(def.blocks[bnum].trialCount,blockCats, def.blocks[bnum].limitSequence);
 			gscr_mc._visible=false;
			showCategoryLabels();
			showInstuctions();
			poster = new LoadVars();
			poster.rawData="";
			poster.addResultValue("mode","insAppletData");
			poster.addResultValue("taskName",def.name);
			poster.addResultValue("blockNum",nBReport);
			poster.addResultValue("blockName",("BLOCK"+nBReport));
			poster.addResultValue("blockTrialCnt", def.blocks[bnum].trialCount);	
			poster.addResultValue("blockPairingDef",def.blocks[bnum].leftLabels+","+def.blocks[bnum].rightLabels);
		
			//_root.log.debug("Task: bnum=" + bnum + " nBReport="+nBReport);
		
			listen();	
	}

	function selectTrial() {
		clearInterval(stimInterval);
		trial = sel.getNextStimuli();
		var trueKey = keys[def.categories[trial.cat].key];
		var falseKey = keys[def.categories[trial.cat].key == 0 ? 1 : 0];
		ts.run(def.categories[trial.cat].stimuli[trial.stim].mc,def.categories[trial.cat].stimuli[trial.stim].audio,def.blocks[bnum].error_mc,trueKey,falseKey,def.blocks[bnum].errcor,def.blocks[bnum].errfeed);
	}

	function showInstuctions() 
	{
		def.blocks[bnum].instructions_mc._y = Stage.height - def.blocks[bnum].instructions_mc._height - ipad;
		def.blocks[bnum].instructions_mc._visible = true;
	}
	
	function hideInstuctions() {
		def.blocks[bnum].instructions_mc._visible = false;
	}
	
	function showRepeatErrMsg() 
	{
		def.blocks[bnum].ErrMsg_mc._y = Stage.height - def.blocks[bnum].ErrMsg_mc._height - ipad;
		def.blocks[bnum].ErrMsg_mc._visible = true;
	}
	function hideRepeatErrMsg() {
		def.blocks[bnum].ErrMsg_mc._visible = false;
	}

	function showRepeatFastMsg() 
	{
		def.blocks[bnum].FastMsg_mc._y = Stage.height - def.blocks[bnum].FastMsg_mc._height - ipad;
		def.blocks[bnum].FastMsg_mc._visible = true;
	}
	function hideRepeatFastMsg() {
		def.blocks[bnum].FastMsg_mc._visible = false;
	}

	function onKeyDown()
	{
		if (Key.getCode() == Key.SPACE)
		{
			processInput();
		}
	}

	function onMouseDown()
	{
		//processInput();
	}
	
	function listen()
	{
		Key.addListener(this);
		//Mouse.addListener(this);//only for iatjw
	}
	
	function stopListen()
	{
		Key.removeListener(this);
		Mouse.removeListener(this);
	}
	
	function processInput()
	{
		stopListen();
		if (repeatErr)
		{
			repeatErr = false;
			hideRepeatErrMsg();
			toNextBlock();
		}
		else if (repeatFast)
		{
			repeatFast = false;
			hideRepeatFastMsg();
			toNextBlock();
		}
		if  (!completed)
		{
			if (!inBlock)
			{
				inBlock = true;
				hideInstuctions();
				showBackgroundStimuli();
				//selectTrial();//for iatjw:
				stimInterval = setInterval(Proxy.create(this,selectTrial),500);
			}
		}
		else 
		{
			completeTask();
		}		

	}
	
	function hideCategoryLabels(){
		var pairing = def.blocks[bnum].pairingDef;
		def.categories[pairing[tr]].mc._visible=false;
		def.categories[pairing[tl]].mc._visible=false;
		def.categories[pairing[br]].mc._visible=false;
		def.categories[pairing[bl]].mc._visible=false;
		def.blocks[bnum].leftSeparator_mc._visible=false;
		def.blocks[bnum].rightSeparator_mc._visible=false;
	}

	function showBackgroundStimuli(){
		for (var i=0;i<def.blocks[bnum].stimuli.length;i++){
			def.blocks[bnum].stimuli[i].mc._visible=true;
		}
	}

	function hideBackgroundStimuli(){
		for (var i=0;i<def.blocks[bnum].stimuli.length;i++){
			def.blocks[bnum].stimuli[i].mc._visible=false;
		}
	}

	//YBYB: show the game score, to entertain the participants
	function showGameScore(lat, err)
	{
		if ((def.gameScore > 0 || def.equation == 1) && !def.hideGameScore)
		{
			//_root.log.debug("Task: going to call gameScorer with gameScore=" + gameScore + " lat="+lat + " err=" + err);
			gameScore = gameScorer.updateScore(gameScore, lat, err);
			//_root.log.debug("Task: Use game score=" + gameScore);
			var gameScrMsg;
			gameScrMsg = "score: " + gameScore;
			gscr_mc.tf.htmlText = "<font face=\""+app.props.FONT+"\" size=\""+app.props.FONTSIZE+"\" color=\"#"+app.props.FONTCOLOR+"\">"+gameScrMsg+"</font>";
			gscr_mc._x = Stage.width / 2 - gscr_mc._width / 2;
			var pairing = def.blocks[bnum].pairingDef;
			gscr_mc._y = Stage.height - pad - gscr_mc._height;
			gscr_mc._visible=true;
		}
	}
	function showCategoryLabels(){
		var pairing = def.blocks[bnum].pairingDef;
		def.categories[pairing[tl]].key = 0;
		def.categories[pairing[tl]].mc._x = pad;
		def.categories[pairing[tl]].mc._y = pad;
		def.categories[pairing[tl]].mc._visible=true;
		def.blocks[bnum].leftLabels = def.categories[pairing[tl]].name;
		
		def.categories[pairing[tr]].key = 1;
		def.categories[pairing[tr]].mc._x = Stage.width - def.categories[pairing[tr]].mc._width - pad;
		def.categories[pairing[tr]].mc._y = pad;
		def.categories[pairing[tr]].mc._visible=true;
		def.blocks[bnum].rightLabels = def.categories[pairing[tr]].name; 
		
		if (pairing.length == 4){
			ls_mc = def.blocks[bnum].leftSeparator_mc;
			rs_mc = def.blocks[bnum].rightSeparator_mc;
			
			ls_mc._x = pad;
			ls_mc._y = pad + def.categories[pairing[tl]].mc._height + pad;
			ls_mc._visible=true;
			
			rs_mc._x = Stage.width - ls_mc._width - pad;
			rs_mc._y = pad + def.categories[pairing[tr]].mc._height + pad;
			rs_mc._visible=true;
			
			def.categories[pairing[bl]].key = 0;
			def.categories[pairing[bl]].mc._x = pad;
			def.categories[pairing[bl]].mc._y = ls_mc._y + ls_mc._height + pad;
			def.categories[pairing[bl]].mc._visible=true;
			def.blocks[bnum].leftLabels = def.categories[pairing[tl]].name + "/" + 
												def.categories[pairing[bl]].name;

			def.categories[pairing[br]].key = 1;
			def.categories[pairing[br]].mc._x = Stage.width - def.categories[pairing[br]].mc._width - pad;
			def.categories[pairing[br]].mc._y = rs_mc._y + rs_mc._height + pad;
			def.categories[pairing[br]].mc._visible=true;
			def.blocks[bnum].rightLabels = def.categories[pairing[tr]].name + "/" + 
												def.categories[pairing[br]].name;
												
		}	
	}
	
	function completeTask(){
		clearInterval(stimInterval);
		var scoreString;
		var score;
		var mess=app.props.SCORE_ERR;
		
		if (_root.tid == undefined){
			_root.err("No TID");
			return;
		}
		if (def.reportResult){
			var scorer = new Scorer;
			scoreString = scorer.scoreTask(scoringData, def.reportBlocks);
			
			if (scoreString=="FAST")
				mess = app.props.FAST_TXT;
			else if (scoreString=="ERROR")
				mess = app.props.ERR_TXT;
			else{
				score = parseFloat(scoreString);
				if ((score == undefined) || (score == NaN)){
				_root.err(def, "Undefined D-Score:"+scoreString);	
				}
				
				// score  greater than highest range
				if (score > def.results[def.results.length-1].cutoff)  
		        	mess=def.results[def.results.length-1].text;
		        else{
		        	for (var i=0; i<def.results.length; i++)   {
					
						// negative cutoff
						if  ((def.results[i].cutoff < 0) && (score <= def.results[i].cutoff))  {
		            		mess=def.results[i].text;
	    	   		 	   	break;
	       				}
	       				//zero cutoff
						if  ((def.results[i].cutoff == 0) && (score > def.results[i-1].cutoff) && (score <= def.results[i+1].cutoff)) {   
	            			mess=def.results[i].text;
	          			    break;
	    				}
	       				// non-negative cutoff
	       				if  ((def.results[i].cutoff >= 0) && (score <= def.results[i].cutoff))  {
		            		mess=def.results[i-1].text;
	    	    	   		break;
	       				} 
					}  // for  loop
		        }
			}
			if ((mess==app.props.SCORE_ERR) && (app.props.SKIP != 1)){  // The result was never set, but let it go if skip is on
				_root.err(def,"Could not map "+score+" to a result");
				return;
			}
		
			poster = new LoadVars;
			poster.rawData="";
			poster.addResultValue("dummy","dummy");
			poster.addResultValue("mode","iatSummary");
			poster.addResultValue("iatScore",score);
			poster.addResultValue("resultMessage",mess);
			poster.addResultValue("tid",_root.tid);
			poster.addResultValue("dummy","dummy");
			poster.send(app.props.NEXT_URL, "_self", "POST");
		}
		else if (def.gameScore > 0 || def.equation == 1)
		{
			poster = new LoadVars;
			poster.rawData="";
			poster.addResultValue("dummy","dummy");
			poster.addResultValue("mode","iatSummary");
			poster.addResultValue("iatScore",score);
			poster.addResultValue("resultMessage"," " + gameScore + " ");
			poster.addResultValue("tid",_root.tid);
			poster.addResultValue("dummy","dummy");
			poster.send(app.props.NEXT_URL, "_self", "POST");
		}
		else 
		{
			poster = new LoadVars;
			poster.addResultValue("dummy","dummy");
			poster.addResultValue("tid",_root.tid);
			poster.addResultValue("dummy","dummy")
			poster.send(app.props.NEXT_URL, "_self", "POST");
		}
			
			app.setLoadingMessage(app.props.END_WAIT);
		// time out error after 60 seconds
		stimInterval = setInterval(Proxy.create(this,completeTask),60000);
			
	}
	
	function nextTask(){
			completed = true;
			app.setLoadingMessage(app.props.END_CONT);
			listen();
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
	}
}
/**
 * Copyright 2005 University of Virginia
 * Picks a stimulus to display
 *
 */
import javax.naming.LimitExceededException;
import org.implicit.Sequencer;

class org.implicit.Selector6 {
	var cats;   // the categories 
	var limit;	// the number of stimuli to pick from each category
	var dim;	// the current dimension.  0 = top, 1= bottom
	var catSeq; // sequence of categories
	var stimSeq; // sequence of stimuli
	var limitReps; // for sequencer: chunks in which all cats must have equal number of stimuli
	var iTrial; //pointer to the current trial
	var ntrials;

	// trials is block trial count.
	// cats is an array of categories.  length is 2 or 4	
	public function Selector6(trials,cats,limitReps){
		this.cats=cats;
		this.limitReps = limitReps;
		this.ntrials=trials;

		if (limitReps)
		{
			initLimitReps();
		}
		else
		{
			initOldMethod();
		}

	}
	
	function initOldMethod()
	{
		for(var i=0;i<cats.length;i++){
			cats[i].s = new Array();  	// an array of stimulus ids
			cats[i].p = 0;				// a counter which tracks number of times this category had stim selcted
			initStack(cats[i]);			
		}
		 // The max number of stimuli that can be so that category selection is balanced
		 //  ie, if 40 trials and 4 categories, select 10 from each category, 
		limit = ntrials/cats.length; 
		dim = 0;  // select from top dimension first
	}
	// creates or refills stack of random stimIDs
	private function initStack(cat){
		for(var x=0;x<cat.size;x++){
			cat.s.push(x);  //  fill s with stimIDs ex. if cat contains 20 stim, s = [0,1,2..19]
		}
		cat.s.randomize();	//  shuffle orde of stimIDs in s
	}
	
	function initLimitReps()
	{
		//_root.log.debug("initLimitReps");
		var respmap = new Array();//allowable responses for each category. 1st=3rd, 2nd=4th
		var catslength = new Array(); //number of stimuli in each category
		var trls = new Array(); // eligible categories per trial
		var seqLimit = new Array(); //number of trials for each separate stimuli assignment
		seqLimit[0] = ntrials;


		//var iCat = Math.round(Math.random());  // select the first category randomly
		var iCat = 1;
		var cats1String;
		var cats2String;
		
		if (cats.length == 2) 
		{
			respmap = ['R','L'];
			cats1String = '01';
			cats2String = '01'
		}
		else //cats.length == 4
		{
			respmap = ['R','L','R','L']; //allowable responses for each category. The first and third are always the same
			cats1String = '01';
			cats2String = '23'
		}		

		// Fill number of stimuli in each category 
		for(var i=0;i<cats.length;i++)
		{
			catslength[i] = cats[i].size;
			//_root.log.debug("catslength["+i + "]="+catslength[i]);
		}

		/*var nseqTrials = 1;
		while (nseqTrials <= ntrials)
		{//Just continue until we have at least enough trials, if not more than that
			seqLimit.push(limitReps);
			nseqTrials += limitReps;
			//_root.log.debug("adding limitReps, nseqTrials="+nseqTrials + " limitReps="+limitReps);
		}*/

		// Fill the allowed categories in each trial. We might fill more than needed, but there's no harm in that 
		_root.log.debug("iCat="+iCat);
		for (var iTrial = 0; iTrial < ntrials; iTrial++)
		{
			trls[iTrial] = (iCat == 0 ? cats1String : cats2String);
			iCat = iCat == 0 ? 1 : 0;
			//_root.log.debug("trls["+iTrial + "]="+trls[iTrial]);
		}		

		//_root.log.debug("before new");
		var seq = new Sequencer(respmap, catslength, trls, seqLimit);
		//_root.log.debug("after new, before assignResponse");
		var myresponse = seq.assignResponse();
		//_root.log.debug("before assignCategory");
		catSeq = seq.assignCategory();
		//_root.log.debug("before assignStimulus");
		stimSeq = seq.assignStimulus();
		//_root.log.debug("after assignStimulus");
		
		//debug printing
		_root.log.debug("PRINT SOMETHING");
		for (var iDebug=0; iDebug < stimSeq.length; iDebug++)
		{
			_root.log.debug("$ catSeq[" + iDebug + "]=" + catSeq[iDebug] + ", stimSeq[" + iDebug + "]=" + stimSeq[iDebug]);
		}
		iTrial = 0;
	}

	
	//  selects a stimulus from a dimension (two categories)
	private function select(cats){
		var stimIndex;  		
		var i = Math.round(Math.random());  // select category in dim
		if (cats[i].p >=limit)
			i = i == 0 ? 1 : 0;			// switch category if selected 
		stimIndex = cats[i].s.pop();  	//  get the stimID
		cats[i].p++;  					// increment count for category
		if (cats[i].s.length == 0)		// if the array of random stimIDs is empty, refill
			initStack(cats[i]);
		return ( {cat: cats[i].id, stim: stimIndex} ); 
	}	
	
	//  method called from task to determine which stimuli to show
	public function getNextStimuli()
	{
		if (limitReps)
		{
			if (iTrial > catSeq.length || iTrial > stimSeq.length)
			{
				iTrial = 0;
			}
			iTrial++;
			return ( {cat: cats[catSeq[iTrial-1]].id, stim: stimSeq[iTrial-1]} ); 
		}
		else
		{
			if (cats.length == 2)
				return select([cats[0],cats[1]]);  // this is a two category block, so just pick from top dim
			else {
				//  This is four cat block.  Alternate from selecting top and bottom
				dim = dim == 0 ? 1 : 0;
				if (dim)
					return select([cats[0],cats[1]]);  // select from top dim
				else
					return select([cats[2],cats[3]]);  // select from bottom dim
			}
		}
	}
}
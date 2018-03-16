/**
 * Copyright 2005 University of Virginia
 * Picks a stimulus to display
 *
 */
class org.implicit.Selector {
	var cats;   // the categories 
	var limit;	// the number of stimuli to pick from each category
	var dim;	// the current dimension.  0 = top, 1= bottom
	// trials is block trial count.
	// cats is an array of categories.  length is 2 or 4	
	public function Selector(trials,cats){
		this.cats=cats;

		for(var i=0;i<cats.length;i++){
			cats[i].s = new Array();  	// an array of stimulus ids
			cats[i].p = 0;				// a counter which tracks number of times this category had stim selcted
			initStack(cats[i]);			
		}
		 // The max number of stimuli that can be so that category selection is balanced
		 //  ie, if 40 trials and 4 categories, select 10 from each category, 
		limit = trials/cats.length; 
		dim = 0;  // select from top dimension first
	}
	
	// creates or refills stack of random stimIDs
	private function initStack(cat){
		for(var x=0;x<cat.size;x++){
			cat.s.push(x);  //  fill s with stimIDs ex. if cat contains 20 stim, s = [0,1,2..19]
		}
		cat.s.randomize();	//  shuffle orde of stimIDs in s
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
	public function getNextStimuli(){
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
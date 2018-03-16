/**
 * Copyright 2005 University of Virginia
 * Trial execution class.  
 *
 */
 

class org.implicit.TrialSet {
	var t0;
	var stim_mc;
	var err_mc;
	var inTrial;
	var pressed;
	var trueKey;
	var falseKey;
	var trueKeyHeld;
	var falseKeyHeld; 
	var released;
	var callback;
	var err;
	var feedback;
	var corr;
	var skipEnabled;
	var audio;
	
	function TrialSet (callback,skipEnabled){
		this.callback = callback;
		this.skipEnabled = skipEnabled;
		trueKeyHeld = false;
		falseKeyHeld = false;
		Key.addListener(this);
	}
	
	function run(stim_mc,audio, err_mc, trueKey, falseKey, corr, feedback){
		this.stim_mc = stim_mc;
		this.err_mc = err_mc;
		this.trueKey=trueKey;
		this.falseKey=falseKey;
		this.feedback = feedback;
		this.corr = corr;
		this.audio=audio;
		if (audio != undefined)
			audio.start();
		inTrial = true; 
		err = 0;
		stim_mc._visible=true;
		err_mc._visible=false;
		trueKeyHeld = Key.isDown(trueKey);
		falseKeyHeld = Key.isDown(falseKey);
		t0 = getTimer();
	} 
	
	function onKeyDown(){
		pressed = Key.getCode();
		if ((pressed == trueKey) && !trueKeyHeld){
			trueKeyHeld=true;	
			if(inTrial){
				inTrial=false;
				stim_mc._visible=false;
				err_mc._visible=false;
				if (audio != undefined)
					audio.stop();
				callback((getTimer()-t0), err);
			}
		}	
		else if ((pressed == falseKey) && !falseKeyHeld) {
			falseKeyHeld=true;	
			if (inTrial){
				err = 1;
				if (feedback)
					err_mc._visible=true;
				if (!corr){
					inTrial=false;
					stim_mc._visible=false;
					err_mc._visible=false;
					if (audio != undefined)
						audio.stop();
					callback((getTimer()-t0), err);
					
					}
				}
			}
		else if (skipEnabled && (pressed == Key.ENTER)){
			if (inTrial){
				inTrial=false;
				stim_mc._visible=false;
				err_mc._visible=false;
				callback(-1);
			}
		}
	}
		
	function onKeyUp(){
		released = Key.getCode();
		if (released == trueKey){
			trueKeyHeld=false;
		}
		else if (released == falseKey){
			falseKeyHeld=false;
		}
	}			
}
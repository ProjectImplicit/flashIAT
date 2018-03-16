﻿﻿
/*
 
 This is how it can be used

var rm : Array = ['R','L','R','L'];
var sincat: Array = [4,4,4,4];
var trls: Array = ['1','1','1','1','01','23','01','23','01','23','01','23','01','23','01','23','01','23','01'];
var cinc : Array = [4,15];

var mysequencer = new Sequencer(rm,sincat,trls,cinc);
var myresponse = mysequencer.assignResponse();
var mycategory = mysequencer.assignCategory();
var mystimulus = mysequencer.assignStimulus();
*/

/**
 * Given an array of category IDs, their responses, and the stimuli within them
 * to return an array of stimuli
 * The shuffling mechanism constrains the response sequencing first and then selects items without replacement for each response
 *  email N. Sriram srinsriram@gmail.com regarding this algorithm
 **/
 
import javax.naming.LimitExceededException;

class org.implicit.Sequencer {
	
	//these minisequences will be sampled without replacement so that not more than six identical responses in a row  are possible..
	var respsequences; 
	var sequencecounter;
	
	//categories are indexed from 0 to k such that there are k+1 categories
	// stimuli within categories are also indexed from 0 upwards 
	 
	var responsemapping     // String as 1D array with the allowable responses for each category  example: ['R','L','R','L']
	var nstimincat          // 1D array with number of stimuli per category  example: [4,4,4,4]
	var trials;	            // 1D array with strings of eligible categories  example: ["012", "1", "12","123","01" ...] 
	var ncategories         // number of categories: example 4
	var ntrials;            // number of trials example: 20
	var ninchunks;          // do randomization and stimulus assignment separately for subsequences of ntrials example: [4, 16] 
	var chosenresponses;    // 1D array of right and left responses
    var chosenstimuli;      // 1D array of stimuli, one per trial
    var chosencategories;   // 1D array of selected categories
    var validinput;        // use this to check validity of parameters in sequence
    var sumofchunks;
	
	
	function eligible(a,b) {
 		var ok1=false, ok2=false;
        var resp1="";
        for (var i=0;i<trials[b].length;i++) resp1+=responsemapping[Number(trials[b].charAt(i))];
        if (resp1.indexOf(respsequences[a].charAt(0))>=0) ok1=true;
        var resp2="";
        if (b < ntrials-1)  for (var i=0;i<trials[b+1].length;i++) resp2+=responsemapping[Number(trials[b+1].charAt(i))];
        if ((b < ntrials-1) && (resp2.indexOf(respsequences[a].charAt(1))>=0)) ok2=true;
        if (b >= ntrials-1) ok2=true; // in this case the second response is irrelevant
		//_root.log.debug("ok1="+ok1 + " ok2="+ok2);
        if (ok1 && ok2) return true; else return false;  
      }  


	function Sequencer(responsemapping,nstimincat,trials,ninchunks) {
		this.responsemapping=responsemapping;
		this.nstimincat=nstimincat;
		this.trials=trials;
		this.ninchunks=ninchunks;
		this.ncategories=responsemapping.length;
		this.ntrials=trials.length;     
		this.validinput=true; this.sumofchunks=0;
		for (var i=0;i<ninchunks.length;i++) sumofchunks+=ninchunks[i];
		if (sumofchunks!=ntrials) validinput=false;   // we dont use this.. but this flags a problem in the input
		this.chosenresponses=new Array(ntrials); 
		this.chosenstimuli=new Array(ntrials);
		this.chosencategories=new Array(ntrials);
		this.respsequences = new Array("RR","RL","LR","LL");
	    this.sequencecounter =new Array(0,0,0,0);
	  }
	
	
	function assignResponse() {
		//fill up chosenresponses
		var n; var nsofar=0;
		for (var h=0;h<ninchunks.length;h++) {
			if (h==0) nsofar=0; else nsofar+=ninchunks[h-1];
			n=nsofar-2;  // resets n as it will be incremented by 2 once the inner loop is entered
			for (var t=0;t<4;t++) sequencecounter[t]=0;
			for (var i=0;i<ninchunks[h];i+=2) {
				n+=2;
				var min=1000;
				for (var j=0;j<4;j++) if (eligible(j,n) && sequencecounter[j]<min) min=sequencecounter[j];
				var k=0;
				do {k = Math.floor(4*Math.random()) ;} while (sequencecounter[k]>min || !eligible(k,n));  // potential for infinite loop if input is bad
				chosenresponses[n]=respsequences[k].charAt(0);
				if (i<(ninchunks[h]-1)) chosenresponses[n+1]=respsequences[k].charAt(1);
				sequencecounter[k]++; 
			}
		}
	
       return(chosenresponses);	   
	 }		
		
		
	function assignCategory() {
     for (var i=0;i<ntrials;i++) {
		var catlist="";
		for (var j=0;j<trials[i].length;j++) 
        if (chosenresponses[i]==responsemapping[trials[i].charAt(j)]) catlist+=trials[i].charAt(j);
        if (catlist!="") chosencategories[i]=Number(catlist.charAt(Math.floor(catlist.length*Math.random()))); else chosencategories[i] = -1;
       }
      return(chosencategories)
     }   

		
	function assignStimulus() {
        	//initialize stimuluscounter to zero
		var stimuluscounter = new Array(ncategories);
		var n=-1;
		for (var h=0;h<ninchunks.length;h++) {
			for (var i=0;i<ncategories;i++) {
				stimuluscounter[i]=new Array(nstimincat[i]);
				for(var j=0;j<nstimincat[i];j++) stimuluscounter[i][j]=0;
			}
			for (var i=0;i<ninchunks[h];i++) {
				n++;
				var j=chosencategories[n];
				var min=1000;
				for (var k=0;k<nstimincat[j];k++) if (stimuluscounter[j][k] < min) min=stimuluscounter[j][k];
				var k=0;
				do {k= Math.floor(nstimincat[j]*Math.random());} while (stimuluscounter[j][k]>min);
				stimuluscounter[j][k]++;
				chosenstimuli[n]=k;
				}
			}
 
        return(chosenstimuli);		
	}
	
}
	
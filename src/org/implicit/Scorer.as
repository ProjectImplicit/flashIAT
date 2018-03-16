/**
 * Copyright 2005 University of Virginia
 * Determines D score  
 *
 */
class org.implicit.Scorer {
	
	function scoreTask(results,rb) {
		var b = new Array();
		b[0] = new Array();
		b[1] = new Array();
		b[2] = new Array();
		b[3] = new Array();

		var pool36;
		var pool47;
		var ave3;
		var ave4;
		var ave6;
		var ave7;
		var diff36;
		var diff47;
		var score;
		var iat1;
		var iat2;
		
		var rberr = new Array();
		rberr[0] = 0;
		rberr[1] = 0;
		rberr[2] = 0;
		rberr[3] = 0;
		var trialsUnder = 0;
		var totalScoredTrials = 0;
		
		var errorString;
		var trial;
		
		// BNG Steps 1-5
		for(var i=0; i < results.length; i++){  //  Loop through all trials 
			trial = results[i];
			for (var j=0; j < rb.length; j++){  //  check if trial is in a report block and < 10000
		
				if ((trial.block == rb[j]) && (trial.lat < 10000)){ 
					b[j].push([trial.lat,trial.err]);    //  add to scoring array
					if (trial.lat < 300)
						trialsUnder++;
					if (trial.err)
						rberr[j]++;
					trace(j + ":" + trial.err+ ":"+rberr[j]);				
					totalScoredTrials++;
					break;
				}
			}	
		}

		for (var i = 0; i < b.length; i++){
			if ((rberr[i]/b[i].length) > .4)
				return("ERROR");
		}
		
		if ((trialsUnder/totalScoredTrials)>.1)
			return("FAST");		
			 
		if (rb.length == 2) {
			pool36 = poolSD(b[0],b[1]);
			ave3 = ave(b[0]);
			ave6 = ave(b[1]);
			diff36 =  ave3 - ave6;
			score = diff36/pool36;
			score = int((score)*1000)/1000; 
		}
		else if (rb.length == 4) {
			//  pool sd BNG Step 6
			pool36 = poolSD(b[0],b[2]);
			pool47 = poolSD(b[1],b[3]);
			//Logger.ms("Pool SDS:"+pool36+","+pool47);
			
			// average	BNG 9
			ave3 = ave(b[0]);
			ave4 = ave(b[1]);
			ave6 = ave(b[2]);
			ave7 = ave(b[3]); 
			//Logger.ms("ave3:"+ave3+",ave4:"+ave4+",ave6:"+ave6+",ave7:"+ave7);
			
			// difference  BNG 10
			diff36 = ave3 - ave6;
			diff47 = ave4 - ave7;
			//Logger.ms("Diffs "+diff36+","+diff47);
			
			//  Divide  BNG11
			iat1 = (diff36/pool36);
			iat2 = (diff47/pool47);
			//Logger.ms("IATs:"+iat1+","+iat2);
			
			// Average quotients BNG 12
			score = ((iat1+iat2)/2);
			
			// Round to thousandths
			// score = int((score)*1000)/1000;
		}
		return score; 
	}

   	//  IAT Math Functions
    function poolSD (arr1,arr2){
		var temp = new Array();
		for(var i=0;i<arr1.length;i++){
			temp.push(arr1[i][0]);
		}
		for(var i=0;i<arr2.length;i++){
		  	temp.push(arr2[i][0]);
		}	
	  return(sd(temp));
	}
	

	function ave (a){
 		var result=0,i=0,num=0;
 			while(i<a.length){
  				result+=a[i][0];
				num++;
				i++;
		 }
		return(result/num);                                                                                                                                                                                                                                                                    
 	}
 	
	
		//  Standard Math Functions		
    function meanf (arr) {
        var l = arr.length, s=0;
        while (l--) s += arr[l];
     	   return s/arr.length;
    }
	
	function variance (arr) {
        var l = arr.length, x2=0,d=0, m = meanf(arr);
        while (l--) {
			d = arr[l]-m;
			x2 += d*d;
		}
        return (x2/(arr.length-1));
    }
  
	function sd (arr){
        return Math.sqrt(variance(arr));
    }

}
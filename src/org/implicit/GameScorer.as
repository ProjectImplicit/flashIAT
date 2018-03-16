/**
 * Copyright 2005 University of Virginia
 * Determines D score  
 *
 */
class org.implicit.GameScorer 
{
	
	var useGameScore;
	var isEq1 = false;
	var addScore;
	var delScore;
	var errScore;
	var slowRespScore;
	var fastRespScore;
	var slowResp;
	var fastResp;
	var divider;
	
	function GameScorer (def)
	{
		//_root.log.debug("new game Scorer def.gameScore="+def.gameScore + " def.equation=" +def.equation + " def.hideGameScore=" + def.hideGameScore);
		if ( (def.gameScore > 0 || def.equation == 1) && !def.hideGameScore)
		{
			this.useGameScore = true;
			this.slowResp = def.slowResp;
			this.fastResp = def.fastResp;
			if (def.equation == 1)
			{
				this.isEq1 = true;
				this.divider = def.divideBy;
				this.errScore = def.errScore;
			}
			else
			{
				slowRespScore = def.slowRespScore;
				fastRespScore = def.fastRespScore;
				this.addScore = def.gameScore;
				this.delScore = def.gameScore;
			}
		}
		else
		{
			this.useGameScore = false;
		}
		//_root.log.debug("new game Scorer, useGameScore="+useGameScore);
	}

	function updateScore(gameScore, lat, err)
	{
		//_root.log.debug("gs, before, gameScore=" + gameScore + " lat=" + lat + " err=" + err);
		if (useGameScore)
		{
			if (isEq1)
			{
				return updateScoreEq1(gameScore, lat, err);
			}
			else
			{
				return updateScoreSimple(gameScore, lat, err);
			}
		}
		return 0;
    }
    
    function updateScoreEq1(gameScore, lat, err)
    {
		var retScore;
		if (err == 1)
		{
			retScore = gameScore - errScore;
		}
		else
		{
			if (lat >= slowResp)
			{//0 points
				retScore = gameScore;
			}
			else
			{//equation1 means = (1000-lat/10), when 1000 is fastResp & 10 the divider. [So if you're 1000 fast, you get 1000-100 = 900. If you 2000, you get 1000 2000/10 = 800. If you 500, you get 1000-50 = 950.]
				retScore = gameScore + (fastResp - (lat/divider));
			}
		}
		retScore = Math.round(retScore);
		//_root.log.debug("gs eq1, now gameScore=" + retScore);
		return retScore;
    }

    function updateScoreSimple(gameScore, lat, err)
    {
		var retScore;
		if (err == 1)
		{
			retScore = gameScore - delScore;
		}
		else
		{
			retScore = gameScore + addScore;
			if (slowResp > 0 && lat > slowResp) 
			{
				retScore = gameScore - slowRespScore;
			}
			else if (fastResp > 0 && lat < fastResp) 
			{
				retScore = gameScore + fastRespScore;
			}
		}
		return retScore;
    }

}
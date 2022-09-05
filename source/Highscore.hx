package;

import flixel.FlxG;

using StringTools;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map();
	public static var songRating:Map<String, Float> = new Map();
	public static var maniaSongScores:Map<String, Float> = new Map();
	public static var maniaWeekScores:Map<String, Float> = new Map();
	public static var maniaSongRating:Map<String, Float> = new Map();
	public static var weekPerformance:Map<String, Float> = new Map();
	public static var songPerformance:Map<String, Float> = new Map();
	#else
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songRating:Map<String, Float> = new Map<String, Float>();
	public static var maniaSongScores:Map<String, Float> = new Map<String, Float>();
	public static var maniaWeekScores:Map<String, Float> = new Map<String, Float>();
	public static var maniaSongRating:Map<String, Float> = new Map<String, Float>();
	public static var weekPerformance:Map<String, Float> = new Map<String, Float>();
	public static var songPerformance:Map<String, Float> = new Map<String, Float>();
	#end


	public static function resetSong(song:String, diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		setScore(daSong, 0);
		setRating(daSong, 0);
	}

	public static function resetWeek(week:String, diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);
		setWeekScore(daWeek, 0);
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
		{
			return Math.floor(value);
		}

		var tempMult:Float = 1;
		for (i in 0...decimals)
		{
			tempMult *= 10;
		}
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1, ?maniaScore:Float = 0, ?maniaRating:Float = 0, ?perfPoints:Float = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong)) {
			if (songScores.get(daSong) < score || maniaSongScores.get(daSong) < maniaScore) {
				setScore(daSong, score, maniaScore, perfPoints);
				if(rating >= 0) setRating(daSong, rating, maniaRating);
			}
		}
		else {
			setScore(daSong, score, maniaScore, perfPoints);
			if(rating >= 0) setRating(daSong, rating, maniaRating);
		}
	}

	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0, ?maniaScore:Float = 0, ?perfPoints:Float = 0):Void
	{
		var daWeek:String = formatSong(week, diff);

		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score || maniaWeekScores.get(daWeek) < maniaScore)
				setWeekScore(daWeek, score, maniaScore, perfPoints);
		}
		else
			setWeekScore(daWeek, score, maniaScore, perfPoints);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int, ?maniaScore:Float = 0, ?perfPoints:Float = 0):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		maniaSongScores.set(song, maniaScore);
		songPerformance.set(song, perfPoints);
		FlxG.save.data.maniaSongScores = maniaSongScores;
		FlxG.save.data.songPerformance = songPerformance;
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}
	static function setWeekScore(week:String, score:Int, ?maniaScore:Float = 0, ?perfPoints:Float = 0):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(week, score);
		maniaWeekScores.set(week, maniaScore);
		weekPerformance.set(week, perfPoints);
		FlxG.save.data.maniaWeekScores = maniaWeekScores;
		FlxG.save.data.weekPerformance = weekPerformance;
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}

	static function setRating(song:String, rating:Float, ?maniaRating:Float = 0):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRating.set(song, rating);
		maniaSongRating.set(song, maniaRating);
		FlxG.save.data.maniaSongRating = maniaSongRating;
		FlxG.save.data.songRating = songRating;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		return Paths.formatToSongPath(song) + CoolUtil.getDifficultyFilePath(diff);
	}

	public static function getScore(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}

	public static function getRating(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!songRating.exists(daSong))
			setRating(daSong, 0);

		return songRating.get(daSong);
	}

	public static function getWeekScore(week:String, diff:Int):Int
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek))
			setWeekScore(daWeek, 0);

		return weekScores.get(daWeek);
	}

	public static function getManiaScore(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!maniaSongScores.exists(daSong))
			setScore(daSong, 0);

		return maniaSongScores.get(daSong);
	}

	public static function getManiaRating(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!maniaSongRating.exists(daSong))
			setRating(daSong, 0);

		return maniaSongRating.get(daSong);
	}

	public static function getManiaWeekScore(week:String, diff:Int):Float
	{
		var daWeek:String = formatSong(week, diff);
		if (!maniaWeekScores.exists(daWeek))
			setWeekScore(daWeek, 0);

		return maniaWeekScores.get(daWeek);
	}

	public static function getPerformancePoints(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!songPerformance.exists(daSong))
			setScore(daSong, 0);

		return songPerformance.get(daSong);
	}

	public static function getWeekPerformancePoints(week:String, diff:Int):Float
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekPerformance.exists(daWeek))
			setWeekScore(daWeek, 0);

		return weekPerformance.get(daWeek);
	}

	public static function load():Void
	{
		if (FlxG.save.data.weekScores != null)
		{
			weekScores = FlxG.save.data.weekScores;
		}
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
		if (FlxG.save.data.songRating != null)
		{
			songRating = FlxG.save.data.songRating;
		}
		if (FlxG.save.data.maniaWeekScores != null)
		{
			maniaWeekScores = FlxG.save.data.maniaWeekScores;
		}
		if (FlxG.save.data.maniaSongScores != null)
		{
			maniaSongScores = FlxG.save.data.maniaSongScores;
		}
		if (FlxG.save.data.maniaSongRating != null)
		{
			maniaSongRating = FlxG.save.data.maniaSongRating;
		}
		if (FlxG.save.data.weekPerformance != null)
		{
			weekPerformance = FlxG.save.data.weekPerformance;
		}
		if (FlxG.save.data.songPerformance != null)
		{
			songPerformance = FlxG.save.data.songPerformance;
		}
	}
}
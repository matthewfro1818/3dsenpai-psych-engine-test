package backend;

class Wife3 {
	static final erfs:Array<Float> = [0.254829592, -0.284496736, 1.421413741, 1.453152027, 1.061405429];
	static final p:Float = 0.3275911;

	static function erf(x:Float):Float {
		var theSignLol:Int = (x < 0 ? -1 : 1);
		x = Math.abs(x);

		var t:Float = 1 / (1 + p * x);
		var y:Float = 1 - (((((erfs[4] * t + erfs[3]) * t) + erfs[2]) * t + erfs[1]) * t + erfs[0]) * t * Math.exp(-x * x);
		return theSignLol * y;
	}

	public static var max_points = 1.0;
	public static var miss_weight = -5.5;
	public static var ts_pow = .75;
	public static var shit_weight:Float = 200;

	public static function getAcc(noteDiff:Float):Float {
		var ts:Float = PlayState.instance.playbackRate;

		var ridic:Float = 5 * ts;
		var zeroBucks:Float = 65 * Math.pow(ts, ts_pow);
		var dev:Float = 22.7 * Math.pow(ts, ts_pow);
		if(noteDiff <= ridic) return max_points;
		else if(noteDiff <= zeroBucks) return max_points * erf((zeroBucks - noteDiff) / dev);
		else if(noteDiff <= shit_weight) return (noteDiff - zeroBucks) * miss_weight / (shit_weight - zeroBucks);
		
		return miss_weight;
	}
}`
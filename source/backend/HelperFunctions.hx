package backend;

import flixel.math.FlxMath;

class HelperFunctions
{
    public static function truncateFloat(number:Float, ?precision:Int = 3):Float {
        var num:Float = number;
        num *= Math.pow(10, precision);
        num = Math.round(num) / Math.pow(10, precision);
        return num;
    }

	public static function GCD(a, b) return b == 0 ? FlxMath.absInt(a) : GCD(b, a % b);
}
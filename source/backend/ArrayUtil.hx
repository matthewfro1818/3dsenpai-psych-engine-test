package backend;

using StringTools;

class ArrayUtil {
	/**
        Checks a provided value to see if it is in the provided blacklist

        @param value The value you would like to be checked
        @param blacklist The provided blacklist you would like to use to check
    **/
    public static function checkBlacklist(value:String, blacklist:Array<String>):Bool {
        for (phrase in blacklist) {
            if (value == phrase) {trace(phrase + ' is in the blacklist'); return true; break;} 
        }
        trace(value + ' is not in blacklist');
        return false;
    }
    /**
        Essentially takes a double array and only returns the first parts of it.

        Ex. [['A', "b"], ['c', "d"]] will only return as ['A', 'c']
    
        @param bigArray Just an Array with more arrays in it.
        @return An array that only has the first value of array within an array.
    **/
    public static function grabFirstVal(bigArray:Array<Array<Dynamic>>):Array<Dynamic> {
        var tempArray:Array<Dynamic> = [];
        for (item in bigArray) {
            if (Std.isOfType(item, Array)) {
                tempArray.push(item[0]);
            }
        }
        return tempArray;
    }
	
	/**
	 * Gets the index of a possible new element of an Array of T using an efficient algorithm.
	 * @param array Array of T to check in
	 * @param getVal Function that returns the position value of T
	 * @return Index
	 */
	public static inline function binarySearch<T>(array:Array<T>, val:Float, getVal:T -> Float):Int {
		if (array.length <= 0) return 0; // if the array is empty, it should be equal to zero (the beginning)
		if (getVal(array[0]) > val) return 0; // in case its the minimum
		if (getVal(array[array.length - 1]) < val) return array.length; // in case its the maximum

		// binary search
		var iMin:Int = 0;
		var iMax:Int = array.length - 1;

		var i:Int = 0;
		var mid:Float;
		while(iMin <= iMax) {
			i = Math.floor((iMin + iMax) / 2);
			mid = getVal(array[i]);
			if (mid < val) iMin = i + 1
			else if (mid > val) iMax = i - 1;
			else {
				iMin = i;
				break;
			}
		}
		return iMin;
	}

	/**
	 * Adds to a sorted array, using binary search.
	 * @param array Array to add to
	 * @param val Value to add
	 * @param getVal Function that returns the value that needs to be sorted
	 */
	public static inline function addSorted<T>(array:Array<T>, val:T, getVal:T->Float) {
		if (val != null) array.insert(binarySearch(array, getVal(val), getVal), val);
	}

	inline public static function dynamicArray<T>(v:T, len:Int):Array<T> return [for (_ in 0...len) v];

	public static function sortByAlphabet(arr:Array<String>):Array<String> {
		arr.sort((a:String, b:String) -> {
			a = a.toUpperCase();
			b = b.toUpperCase();
	
			if (a < b) return -1;
			else if (a > b) return 1;
			else return 0;
		});
		return arr;
	}
}
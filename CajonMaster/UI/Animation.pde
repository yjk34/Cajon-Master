static int curSpeedIdx = 0;
static int curPatternIdx = 0;

void doSpeedAnim(boolean isIncrease) {
	if (isIncrease) {
		curSpeedIdx = (curSpeedIdx + 1) % speedList.length;
	}
	else {
		curSpeedIdx = (curSpeedIdx + speedList.length - 1) % speedList.length;
	}
	println("Speed: " + speedList[curSpeedIdx]);
}

void doPatternAnim(boolean isIncrease) {
	if (isIncrease) {
		curPatternIdx = (curPatternIdx + 1) % patternList.length;	
	}
	else {
		curPatternIdx = (curPatternIdx + patternList.length - 1) % patternList.length;		
	}
	println("Pattern: " + patternList[curPatternIdx]);
}
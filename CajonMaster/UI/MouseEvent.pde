final static int movementTresh = 10;

static Coord mouseTraceBegin;
static Coord mouseTraceEnd;

static boolean isMousePressed = false;

void mousePressed() {
	mouseTraceBegin.x = mouseX;
	mouseTraceBegin.y = mouseY;
	isMousePressed = true;
}

void mouseReleased() {
	mouseTraceEnd.x = mouseX;
	mouseTraceEnd.y = mouseY;

	checkTriggerEvent();
	doGestureRecognizeAndClearList();
	isMousePressed = false;
}

void mouseMoved() {
	// TODO: Solution B might use this
}

void checkTriggerEvent() {
	// Check if the begining is inside the speed rect
	if (mouseTraceBegin.x >= speedRectParams[0] && mouseTraceBegin.x < speedRectParams[0] + speedRectParams[2]
	&& mouseTraceBegin.y >= speedRectParams[1] && mouseTraceBegin.y < speedRectParams[1] + speedRectParams[3]) {
		// If the movement is obvious enough
		if (abs(mouseTraceBegin.y - mouseTraceEnd.y) > movementTresh) {
			if (mouseTraceEnd.y > mouseTraceBegin.y)
				doSpeedAnim(false);
			else
				doSpeedAnim(true);
		}
	}

	// Check if the begining is inside the pattern rect
	else if (mouseTraceBegin.x >= patternRectParams[0] && mouseTraceBegin.x < patternRectParams[0] + patternRectParams[2]
	&& mouseTraceBegin.y >= patternRectParams[1] && mouseTraceBegin.y < patternRectParams[1] + patternRectParams[3]) {
		if (abs(mouseTraceBegin.y - mouseTraceEnd.y) > movementTresh) {
			if (mouseTraceEnd.y > mouseTraceBegin.y)
				doPatternAnim(false);
			else
				doPatternAnim(true);
		}
	}
}

class Coord {
	public int x;
	public int y;

	public Coord(int x, int y) {
		this.x = x;
		this.y = y;
	}
};
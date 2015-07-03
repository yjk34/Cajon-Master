final static int SAD_GUY_PATTERN_IDX = 4;
final static int SAD_GUY_SPEED = 140;
final static int STOP_PATTERN_IDX = 5;
final static int STOP_SPEED = 145;

void checkClientMsg() {
	Client thisClient = myServer.available();
	if (thisClient != null) {
		String whatClientSaid = thisClient.readString();
		parseAndUpdateInfo(whatClientSaid);
	}
}

void parseAndUpdateInfo(String msg) {
	msg = msg.replace("\n", "");
	String[] infoArr = split(msg, ':');
	for (int i=0; i<infoArr.length; i += 2) {
		if (i+1 >= infoArr.length) break;
		String keyInfo = infoArr[i];
		String valueInfo = infoArr[i+1];
		println("key: " + keyInfo + ", value: " + valueInfo);
		if (keyInfo.equals("songName")) 
			doChangeSong(valueInfo);
		else if (keyInfo.equals("cmd")) 
			doCmd(valueInfo);
		else if (keyInfo.equals("gesture"))
			doGesture(valueInfo);
	}
	println(msg);
	// TODO: Parse what client said
}

void doChangeSong(String valueInfo) {
	boolean isSongInList = true;
	isPause = true;
	
	if (valueInfo.equals("sad")) {
		curPatternIdx = SAD_GUY_PATTERN_IDX;
		//curSpeedIdx = findNearestSpeedIdx(SAD_GUY_SPEED);
		curSpeed = SAD_GUY_SPEED;
	} else if (valueInfo.equals("stop")) {
		curPatternIdx = STOP_PATTERN_IDX;
		//curSpeedIdx = findNearestSpeedIdx(STOP_SPEED);
		curSpeed = STOP_SPEED;
	} else {
		isSongInList = false;
	}

	if (isSongInList)
		getNewRhythm();
	isPause = false;
}

void doCmd(String valueInfo) {
	if (valueInfo.equals("pause"))
		isPause = true;
	else if (valueInfo.equals("continue"))
		isPause = false;
}

void doGesture(String valueInfo) {
	if (valueInfo.equals("start")) {
		isGestureListen = true;
	} else if (valueInfo.equals("end")) {
		isGestureListen = false;
		doGestureRecognizeAndClearList();
	}

}

int findNearestSpeedIdx(int targetSpeed) {
	int rtnIdx = -1;
	int minSpeedDist = 300;
	for (int i=0; i<speedList.length; i++) {
		if (rtnIdx < 0 || abs(speedList[i] - targetSpeed) <= minSpeedDist)  {
			rtnIdx = i;
			minSpeedDist = abs(speedList[i] - targetSpeed);
		}
	}
	return rtnIdx;
}
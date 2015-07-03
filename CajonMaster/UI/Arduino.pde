final static int msperMin = 60000;
final static int beatsperBar = 4;
final static int strike_delay = 25;
final static int[][] drumRelayPin = {{6, 7}, {9, 10}, {12, 13}};
final static int[] prevDrumTime = {0, 0, 0};
final static boolean[] isDrumBack = {false, false, false};

final static int millisLimit = 3000; // So the lowest BPM is support for 20 ( 60 * 1000 / 3000 = 20)

static boolean isPause = true;
static boolean isReadyForRhythm = true;
static int prevActionTime = 0;

static int curBeatNum = 4;
static String curScore = "1000";
static int curScoreIdx = 0;
static int curSpeed = 80;

void arduinoSetup() {
  for(int i=0; i<drumRelayPin.length; i++) {
    arduino.pinMode(drumRelayPin[i][0], Arduino.OUTPUT);
    arduino.pinMode(drumRelayPin[i][1], Arduino.OUTPUT);
    initDrumRelay(i);
  }
    
}

void arduinoLoop() {
  if (isReadyForRhythm) {
    getNewRhythm();
    isReadyForRhythm = false;
    prevActionTime = millis() % millisLimit;
  }

  playByScore();
}

void getNewRhythm() {
  curBeatNum = (int) pow(2, (int)(rhythmList[curPatternIdx].charAt(0) - '0'));
  curScore = rhythmList[curPatternIdx].substring(1);
  curScoreIdx = 0;

  println("curBeatNum = " + curBeatNum);
  println("curScore = " + curScore);
  }

void playByScore() {
  if (isPause) return;

  int millisThresh = 60 * 1000 / (curSpeed *  curBeatNum / 4); // N BPM = every 60000 / N millis seconds for 1 hit
  
  for (int i=0; i<drumRelayPin.length; i++) {
    if (prevDrumTime[i] >= 0) {
      int curPastDrumPeriod = (millis() % millisLimit) - prevDrumTime[i];
      curPastDrumPeriod = curPastDrumPeriod >= 0 ?curPastDrumPeriod : curPastDrumPeriod + millisLimit;
      if (curPastDrumPeriod >= strike_delay) {
        isDrumBack[i] = false;
        initDrumRelay(i);
        prevDrumTime[i] = -1;
      }
    }
  }

  int curPastTime = (millis() % millisLimit) - prevActionTime;
  curPastTime = curPastTime >= 0 ? curPastTime : curPastTime + millisLimit;
  if (curPastTime >= millisThresh) {
    //println("I use " + curPastTime + " to Hit when I need " + millisThresh + " ms.");
    if ( (getTone(curScoreIdx) & 2) != 0 )
      drumHitMotion(1);
    else if ( (getTone(curScoreIdx) & 1) != 0 )
      drumHitMotion(0);
    else if ( (getTone(curScoreIdx) & 4) != 0 ) 
      drumHitMotion(2);
    curScoreIdx++;

    // Check if it reach the end of the rhythm...
    if (curScoreIdx == curScore.length()) {
      curScoreIdx = 0;
      isReadyForRhythm = true;
    } else {
      prevActionTime = millis() % millisLimit;
    }
  }
}

int getTone(int idx) {
  return (int) (curScore.charAt(idx) - '0');
}

void drumHitMotion(int idx) {
  switch(idx) {
    case 0:
      //println("BassDrum");
      break;
    case 1:
      //println("SideDrum");
      break;
    case 2:
      //println("HihatDrum");
      break;
  }
  prevDrumTime[idx] = millis() % millisLimit;
  doDrumStrike(idx);
}

void doDrumStrike(int idx) {
  setRelayLow(drumRelayPin[idx][1]);
  setRelayHigh(drumRelayPin[idx][0]);
}

void doDrumBack(int idx) {
  setRelayLow(drumRelayPin[idx][0]);
  setRelayHigh(drumRelayPin[idx][1]);
}

void initDrumRelay(int idx) {
  setRelayLow(drumRelayPin[idx][0]);
  setRelayLow(drumRelayPin[idx][1]);
}

void setRelayHigh(int relayPin) {
  if (arduino != null)
    arduino.digitalWrite(relayPin, Arduino.HIGH);
}

void setRelayLow(int relayPin) {
  if (arduino != null)
    arduino.digitalWrite(relayPin, Arduino.LOW);
}

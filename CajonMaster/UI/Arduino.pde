final static int msperMin = 60000;
final static int beatsperBar = 4;
final static int strike_delay = 50;
final static int back_delay = 30;
final static int switch_delay = 30;
final static int bass_drum_relay_1 = 10;
final static int bass_drum_relay_2 = 11;
final static int side_drum_relay_1 = 12;
final static int side_drum_relay_2 = 13;

final static int millisLimit = 3000; // So the lowest BPM is support for 20 ( 60 * 1000 / 3000 = 20)

static boolean isReadyForRhythm = true;
static int prevActionTime = 0;

static int curBeatNum = 4;
static String curScore = "1000";
static int curScoreIdx = 0;

void arduinoSetup() {
  arduino.pinMode(bass_drum_relay_1, Arduino.OUTPUT);
  arduino.pinMode(bass_drum_relay_2, Arduino.OUTPUT);
  arduino.pinMode(side_drum_relay_1, Arduino.OUTPUT);
  arduino.pinMode(side_drum_relay_2, Arduino.OUTPUT);
  initBassDrumRelay();
  initSideDrumRelay();
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
  int millisThresh = 60 * 1000 / speedList[curSpeedIdx]; // N BPM = every 60000 / N millis seconds for 1 hit
  int curPastTime = (millis() % millisLimit) - prevActionTime;
  curPastTime = curPastTime >= 0 ? curPastTime : curPastTime + millisLimit;

  if (curPastTime >= millisThresh) {
    if ( (getTone(curScoreIdx) & 1) != 0 )
      bassDrumHitMotion();
    else if ( (getTone(curScoreIdx) & 2) != 0 )
      sideDrumHitMotion();
    else if ( (getTone(curScoreIdx) & 4) != 0 ) {
      // TODO: It should be hihat, not empty
      
    }

    curScoreIdx++;
    if (curScoreIdx == curBeatNum) {
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

void sideDrumHitMotion() {
  println("sideDrumHitMotion()");
  sideDrumStrike();
  delay(strike_delay);
  initSideDrumRelay();
  delay(switch_delay);
  sideDrumBack();
  delay(back_delay);
  initSideDrumRelay();
  delay(switch_delay);
}

void sideDrumStrike() {
  setRelayHigh(side_drum_relay_1);
}

void sideDrumBack() {
  setRelayHigh(side_drum_relay_2);
}

void bassDrumHitMotion() {
  println("bassDrumHitMotion()");
  bassDrumStrike();
  delay(strike_delay);
  initBassDrumRelay();
  delay(switch_delay);
  bassDrumBack();
  delay(back_delay);
  initBassDrumRelay();
  delay(switch_delay);
}

void bassDrumStrike() {
  setRelayHigh(bass_drum_relay_1);
}

void bassDrumBack() {
  setRelayHigh(bass_drum_relay_2);
}

void initSideDrumRelay() {
  setRelayLow(side_drum_relay_1);
  setRelayLow(side_drum_relay_2);
}

void initBassDrumRelay() {
  setRelayLow(bass_drum_relay_1);
  setRelayLow(bass_drum_relay_2);
}

void setRelayHigh(int relayPin) {
  if (arduino != null)
    arduino.digitalWrite(relayPin, Arduino.HIGH);
}

void setRelayLow(int relayPin) {
  if (arduino != null)
    arduino.digitalWrite(relayPin, Arduino.LOW);
}

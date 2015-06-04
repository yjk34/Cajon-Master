final static int msperMin = 60000;
final static int beatsperBar = 4;
final static int strike_delay = 50;
final static int back_delay = 30;
final static int switch_delay = 60;
final static int bass_drum_relay_1 = 10;
final static int bass_drum_relay_2 = 11;
final static int side_drum_relay_1 = 12;
final static int side_drum_relay_2 = 13;

void arduinoSetup() {
  arduino.pinMode(bass_drum_relay_1, Arduino.OUTPUT);
  arduino.pinMode(bass_drum_relay_2, Arduino.OUTPUT);
  arduino.pinMode(side_drum_relay_1, Arduino.OUTPUT);
  arduino.pinMode(side_drum_relay_2, Arduino.OUTPUT);
  initBassDrumRelay();
  initSideDrumRelay();
}

void arduinoLoop() {
  playByScore("10110111", 120, 8);
  delay(5000);
}

void playByScore(String score, int bpm, int tempo) {
  int period = (msperMin / bpm) * beatsperBar / tempo;
  int i;
  for (i=0 ; i<score.length() ; i++) {
    switch (score.charAt(i)) {
      case '0': // rest
        delay(period);
        break;
      case '1': // hit side drum
        sideDrumHitMotion();
        delay(period - strike_delay - back_delay - switch_delay - switch_delay);
        break;
      case '2': // hit bass drum
        bassDrumHitMotion();
        delay(period - strike_delay - back_delay - switch_delay - switch_delay);
        break;
    }
  }
}

void sideDrumHitMotion() {
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
  arduino.digitalWrite(relayPin, Arduino.HIGH);
}

void setRelayLow(int relayPin) {
  arduino.digitalWrite(relayPin, Arduino.LOW);
}

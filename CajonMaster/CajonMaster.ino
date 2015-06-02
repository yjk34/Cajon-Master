const int msperMin = 60000;
const int beatsperBar = 4;
const int strike_delay = 50;
const int back_delay = 30;
const int switch_delay = 60;
const int bass_drum_relay_1 = 10;
const int bass_drum_relay_2 = 11;
const int side_drum_relay_1 = 12;
const int side_drum_relay_2 = 13;
char serial_input_buf[50];
int index = 0;
int bpm;
void setup() {
  pinMode(bass_drum_relay_1, OUTPUT);
  pinMode(bass_drum_relay_2, OUTPUT);
  pinMode(side_drum_relay_1, OUTPUT);
  pinMode(side_drum_relay_2, OUTPUT);
  Serial.begin(9600);
  initBassDrumRelay();
  initSideDrumRelay();
}

void loop() {
  //play("100100101001001010010010", 120, 8);
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
  digitalWrite(relayPin, HIGH);
}

void setRelayLow(int relayPin) {
  digitalWrite(relayPin, LOW);
}

const int strike_delay = 50;
const int back_delay = 30;
const int switch_delay = 60;
const int relay_1 = 12;
const int relay_2 = 13;
char serial_input_buf[50];
int index = 0;
int bpm;
void setup() {
  pinMode(relay_1, OUTPUT);
  pinMode(relay_2, OUTPUT);
  Serial.begin(9600);
  initRelay();
}

void loop() {
  //play("100100101001001010010010", 120, 8);
  playByScore("10110111", 120, 8);
  delay(5000);
}

void playByScore(String score, int bpm, int tempo) {
  int period = (60000 / bpm) * 4 / tempo;
  int i;
  for (i=0 ; i<score.length() ; i++) {
    switch (score.charAt(i)) {
      case '0': // rest
        delay(period);
        break;
      case '1': // hit
        hitMotion();
        delay(period - strike_delay - back_delay - switch_delay - switch_delay);
        break;
    }
  }
}

void hitMotion() {
  strike();
  delay(strike_delay);
  initRelay();
  delay(switch_delay);
  back();
  delay(back_delay);
  initRelay();
  delay(switch_delay);
}

void strike() {
  setRelayHigh(relay_1);
}

void back() {
  setRelayHigh(relay_2);
}

void initRelay() {
  digitalWrite(relay_1, LOW);
  digitalWrite(relay_2, LOW);
}

void setRelayHigh(int relayPin) {
  digitalWrite(relayPin, HIGH);
}

void setRelayLow(int relayPin) {
  digitalWrite(relayPin, LOW);
}

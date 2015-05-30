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
  relay_init();
  bpm = 70;
  print_bpm();
}

void loop() {
  //play("100100101001001010010010", 120, 8);
  play("10110111", 120, 8);
  delay(5000);
}

void play(String score, int bpm, int tempo) {
  int period = (60000 / bpm) * 4 / tempo;
  int i;
  for (i=0 ; i<score.length() ; i++) {
    switch (score.charAt(i)) {
      case '0': // rest
        delay(period);
        break;
      case '1': // hit
        hit();
        delay(period - strike_delay - back_delay - switch_delay - switch_delay);
        break;
    }
  }
}

void hit() {
  strike();
  delay(strike_delay);
  relay_init();
  delay(switch_delay);
  back();
  delay(back_delay);
  relay_init();
  delay(switch_delay);
}

void strike() {
  relay_1_high();
}

void back() {
  relay_2_high();
}

void relay_init() {
  digitalWrite(relay_1, LOW);
  digitalWrite(relay_2, LOW);
}

void relay_1_high() {
  digitalWrite(relay_1, HIGH);
}

void relay_1_low() {
  digitalWrite(relay_1, LOW);
}

void relay_2_high() {
  digitalWrite(relay_2, HIGH);
}

void relay_2_low() {
  digitalWrite(relay_2, LOW);
}

void print_bpm() {
  Serial.write("Current BPM : ");
  Serial.print(bpm);
  Serial.write('\n');
}
  

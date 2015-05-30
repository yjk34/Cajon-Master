const int t_gap = 100;
const int relay_1 = 12;
const int relay_2 = 13;
char serial_input_buf[50];
int index = 0;
int bpm;
void setup() {
  pinMode(relay_1, OUTPUT);
  pinMode(relay_2, OUTPUT);
  Serial.begin(9600);
  bpm = 70;
  print_bpm();
}

void loop() {
  /*if (Serial.available() > 0) {
    char inChar = Serial.read();
    serial_input_buf[index] = inChar;
    index++;
    if (inChar == '\n') {
      serial_input_buf[index] = '\0';
      index = 0;
      bpm = atoi(serial_input_buf);
      print_bpm();
    }
  }
  hit();
  int period = 60000 / bpm;
  delay(period);  */

  play("10010010", 120, 8);
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
        delay(period-t_gap);
        break;
    }
  }
}

void hit() {
  digitalWrite(relay_1, HIGH);
  digitalWrite(relay_2, LOW);
  delay(t_gap);
  digitalWrite(relay_2, HIGH);
  digitalWrite(relay_1, LOW);
}

void print_bpm() {
  Serial.write("Current BPM : ");
  Serial.print(bpm);
  Serial.write('\n');
}
  

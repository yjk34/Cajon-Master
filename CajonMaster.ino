const int t_gap = 150;
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
  if (Serial.available() > 0) {
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
  delay(period);  
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
  
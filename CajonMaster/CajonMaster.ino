const int msperMin = 60000;
const int beatsperBar = 4;
const int strike_delay = 30;
const int back_delay = 70;
const int bass_drum_relay_1 = 6;
const int bass_drum_relay_2 = 7;
const int hi_hat_relay_1 = 9;
const int hi_hat_relay_2 = 10;
const int side_drum_relay_1 = 12;
const int side_drum_relay_2 = 13;

void setup() {
  pinMode(bass_drum_relay_1, OUTPUT);
  pinMode(bass_drum_relay_2, OUTPUT);
  pinMode(side_drum_relay_1, OUTPUT);
  pinMode(side_drum_relay_2, OUTPUT);
  pinMode(hi_hat_relay_1, OUTPUT);
  pinMode(hi_hat_relay_2, OUTPUT);
  Serial.begin(9600); 
  initBassDrumRelay();
  initSideDrumRelay();
  initHiHatRelay();
}
void loop() {
   //playByScore("102010201020102010201020102010201020102010201020102010201020102010201020102010201020102010201020102010201020102010201020102010201020102010201020102010201020102010201020102010201020102010201020", 150, 8);
  //playByScore("1010101010101010101010101010101010101010101010101010101010101010", 180, 8);
  //playByScore("1020102010201020102010201020102010201020102010201020", 180, 8);
  //playByScore("102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040102040", 180, 8);
  
  playByScore("40004000400040005040605050406050505060524050602250406050504060505050606042502222504060505040605050506052405060225040605050406050505060604250202050005000500050005040104010401040104010401040104010401040104010401040104012403240504010401040104010401040104010401040104010401040100000000010221050401040104010401040104010401040104010401040104010401040104032405040104010401040104010401240104010401040104010405022400022222240504030401040304010403040124030401040304010403040104030401240302250403040104030401040304012403040104030401040304010601242501060605040304010403040104030401240304050403040104030401040304250303030504030401040304010403040124030405040304010403040106032405030302250401040104010401040104010401040504010401040302250403040104030405022300010001000", 135, 16);
  delay(3000);
}

void playByScore(String score, int bpm, int tempo) {
  //int period = (msperMin / bpm) * beatsperBar / tempo;
  int period = (60000 / bpm) * 4 / tempo;
  int i;
  for (i=0 ; i<score.length() ; i++) {
    
    //analogVal += (10 * flag);
    /*if (analogVal == 1) {
      analogVal = 255;
      //flag *= -1;
    } else if(analogVal == 255 ) {
      analogVal = 1;
      //flag *= -1;
    }*/
      
    switch (score.charAt(i)) {
      case '0': // rest
        delay(period);
        break;
      case '1': // hit bass drum
        bassDrumHitMotion();
        //delay(period - strike_delay - back_delay);
        delay(period - strike_delay);
        break;
      case '2': // hit side drum
        sideDrumHitMotion();
        //delay(period - strike_delay - back_delay);
        delay(period - strike_delay);
        break;
      case '3': // hit side drum
        sideDrumHitMotion();
        //delay(period - strike_delay - back_delay);
        delay(period - strike_delay);
        break;
      case '4': // hit hi-hat
        hiHatHitMotion();
        //delay(period - strike_delay - back_delay);
        delay(period - strike_delay);
        break;
      case '5': // hit bass drum
        bassDrumHitMotion();
        //delay(period - strike_delay - back_delay);
        delay(period - strike_delay);
        break;
      case '6': // hit side drum
        sideDrumHitMotion();
        //delay(period - strike_delay - back_delay);
        delay(period - strike_delay);
        break;
        
    }
  }
}

void sideDrumHitMotion() {
  sideDrumStrike();
  delay(strike_delay);
  initSideDrumRelay();
  //delay(switch_delay);
  //sideDrumBack();
  //delay(back_delay);
  //initSideDrumRelay();
  //delay(switch_delay);
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
  //bassDrumBack();
  //delay(back_delay);
  //initBassDrumRelay();
  //delay(switch_delay);
}

void bassDrumStrike() {
  setRelayHigh(bass_drum_relay_1);
}

void bassDrumBack() {
  setRelayHigh(bass_drum_relay_2);
}

void hiHatHitMotion() {
  hiHatStrike();
  delay(strike_delay);
  initHiHatRelay();
  //delay(switch_delay);
  //hiHatBack();
  //delay(back_delay);
  //initHiHatRelay();
  //delay(switch_delay);
}

void hiHatStrike() {
  setRelayHigh(hi_hat_relay_1);
}

void hiHatBack() {
  setRelayHigh(hi_hat_relay_2);
}

void initSideDrumRelay() {
  setRelayLow(side_drum_relay_1);
  setRelayLow(side_drum_relay_2);
}

void initBassDrumRelay() {
  setRelayLow(bass_drum_relay_1);
  setRelayLow(bass_drum_relay_2);
}

void initHiHatRelay() {
  setRelayLow(hi_hat_relay_1);
  setRelayLow(hi_hat_relay_2);
}

void setRelayHigh(int relayPin) {
  digitalWrite(relayPin, HIGH);
}

void setRelayLow(int relayPin) {
  digitalWrite(relayPin, LOW);
}

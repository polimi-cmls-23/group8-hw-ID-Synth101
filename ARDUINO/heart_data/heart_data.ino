#include "pitches.h" //file where are contained the information to play the notes
int noteDuration = 50;
int pinToGround = 6;
bool notePlayed = false;
int period = 0;
int periods[10];
int periodsCount = 0;
int currentBPM = 33; //33 is a code that are used when arduino data are not correct or still not available
int melody[] = {NOTE_C3, NOTE_D3, NOTE_E4, NOTE_D3};
int noteDurations[] = {8,8,8,8};
int lastVals[25];//array that contains the present and the 29 previous samples

void setup() {
  pinMode(pinToGround, OUTPUT);//initialization of the pin that is used as GND
  Serial.begin(9600);//Serial initialization
  for (int thisNote = 0; thisNote < 4; thisNote++){ //this iteration is useful to play the starting notes
    int noteDur = 1000/noteDurations[thisNote];
    tone(8, melody[thisNote], noteDur);
    int pauseBetweenNotes = noteDuration * 1.30;
    delay(pauseBetweenNotes);
    noTone(8);
  }
}

void loop() {
  int val = analogRead(A2);//reading from the heart rate sensor pin
  if (val < 999 && val > 550){
    Serial.print(String(val) + String(currentBPM) + "E"); //building of the serial message sent to processing
  }
  else {
    Serial.print("NVVE");//the Not Valid Values is used to say to processing that the current value picked up from the sensor is not in a correct range.
  }

  if (isPeak(lastVals[0], val) && !notePlayed && val>780){
    periods[periodsCount] = period;//array that contains the last periods (time distance from each peak)
    periodsCount++;
    if(periodsCount == 9){
      noTone(8);
      int BPM = computeBPM(periods);//function that computes the BPM
      if(BPM > 40 && BPM < 150){
        currentBPM = BPM;
      }
      else{
        currentBPM = 33;
      }
      periodsCount = 0;
    }
    period = 0;
    tone(8,NOTE_C7, noteDuration);//generation of the note played in presence of a peak
    delay(12);//delay applied to the loop function
    //noTone(8);
    notePlayed = true;
  }
  else{
    if (endPeak(lastVals[0], val) && val< 760){
      notePlayed = false;
      }
    period = period + 12;
    delay(12);
  }
  for (int i = 0; i<24; i++){
    lastVals[i] = lastVals[i+1];
  }
  lastVals[24] = val;
}

int computeBPM(int arr[]){
  int sum = 0;
  int BPMS = 0;
  for (int i = 0; i<10; i++){
    BPMS = BPMS + (60000/arr[i]);
  }
  return(BPMS/10);
}

bool isPeak (int last, int current){//function that detects a peak
  int difference = current - last;
  bool isPeak = false;
  if (difference >= 80){
    isPeak = true;
  }
  return isPeak;
}

bool endPeak(int last, int current){//function that detects the end of a peak
  int difference = last - current;
  bool endPeak = false;
  if (difference >= 80){
    endPeak = true;
  }
  return endPeak;
}

#include "pitches.h"
int noteDuration = 50;
int pinToGround = 6;
bool notePlayed = false;
int period = 0;
int periods[10];
int periodsCount = 0;
int currentBPM = 33;
int melody[] = {NOTE_C3, NOTE_D3, NOTE_E4, NOTE_D3};
int noteDurations[] = {8,8,8,8};

void setup() {
  pinMode(pinToGround, OUTPUT);
  Serial.begin(9600);
  for (int thisNote = 0; thisNote < 4; thisNote++){
    int noteDur = 1000/noteDurations[thisNote];
    tone(8, melody[thisNote], noteDur);
    int pauseBetweenNotes = noteDuration * 1.30;
    delay(pauseBetweenNotes);
    noTone(8);
  }
}

void loop() {
  int val = analogRead(A2);
  //Serial.print(val);
  if (val < 999 && val > 550){
    Serial.print(String(val) + String(currentBPM) + "E");
  }
  else {
    Serial.print("NVVE");
  }
  if (val > 780 && !notePlayed){
    periods[periodsCount] = period;
    periodsCount++;
    if(periodsCount == 10){
      int BPM = computeBPM(periods);
      if(BPM > 60 && BPM < 130){
        currentBPM = BPM;
      }
      else{
        currentBPM = 33;
      }
      periodsCount = 0;
    }
    period = 0;
    tone(8,NOTE_C7, noteDuration);
    delay(50);
    noTone(8);
    notePlayed = true;
  }
  else{
    if (val < 780){
      notePlayed = false;
      }
    period = period + 50;
    delay(50);
  }
}

int computeBPM(int arr[]){
  int sum = 0;
  int BPMS = 0;
  for (int i = 0; i<10; i++){
    BPMS = BPMS + (60000/arr[i]);
  }
  return(BPMS/10);
}
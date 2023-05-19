import oscP5.*;
import netP5.*;
//import processing.serial.*;
OscP5 oscP5;
NetAddress sender;
NetAddress receiver;

import controlP5.*;
ControlP5 cp5;

//Arduino e mouse controller
int [] xvals;
int[] yvals;
int[] ardvalsStream;
String bpm="80";
String currentBPM = "80";
//Serial myPort;  
char val;

int rectX;
int rectY;
int rectWidth;
int rectHeight;





//opther global variables
int mode=1;

PFont myFont;
int offsetx=110;
int offsety=52;

int knobValue = 100;
int knobRadius;


float yToSend;
float xToSend;
//String xParamToRecieve;
//String yParamToRecieve;
//String bpmParamToRecieve;
float xParamToRecieve;
float yParamToRecieve;
float bpmParamToRecieve;


//COLORS:
color Color1= #8ED0FD;
color Color1Secondary=#6391B0;
color Color1Tertiary=#CFECFF;

color Color2= #7EFCF4;
color Color2Secondary=#55ABA5;
color Color2Tertiary=#C4FFFB;

color Color3= #ADFFB6;
color Color3Secondary=#67A36B;
color Color3Tertiary=#D9FCDC;

color Color4= #7EE6AD;
color Color4Secondary=#5BA67D;
color Color4Tertiary=#C7F2DA;

color currentColor= Color1; //#FAFAFA;
color secondaryColor= Color1Secondary;
color tertiaryColor= Color1Tertiary;


Knob knobSongSelection;
Knob knobReverb;
Knob knobMaster;

PShape heartSVG;



void setup() {
  fullScreen();
  noStroke();
  rectMode(CORNER);
  frameRate(240);
  
  mode=1;
  rectX= width/3 + 50;
  rectY= 4*height/9;
  rectWidth = width/3;
  rectHeight = height/9;
  
 //MouseController
  xvals = new int[rectWidth];
  yvals = new int[rectWidth];
  for(int i=0;i<rectWidth;i++){yvals[i]=height;};
  
  ardvalsStream = new int[rectWidth];
  for(int i=0;i<rectWidth;i++){ardvalsStream[i]=550;};
  
  //Initializing arduino Serial
  //String portName = Serial.list()[0];
  //myPort = new Serial(this, portName, 9600);

  //KNOBS STUFF:
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  
  knobRadius =height/15;
  
  
  
  knobSongSelection = cp5.addKnob("Song Selection")
               .setRange(int(0),int(10))
               .setValue(int(0))
               .setPosition(width/2 - knobRadius/2 - width/10, height - (height/6 + 50))
               .setRadius(knobRadius)
               .setNumberOfTickMarks(10)
               .setTickMarkLength(3)
               .snapToTickMarks(true)
               .setColorForeground(currentColor)
               .setColorBackground(secondaryColor)            //(0, 160, 100))
               .setColorActive(tertiaryColor)
               .setViewStyle(Knob.ELLIPSE)
               .setLabelVisible(false);
               
               
  knobReverb = cp5.addKnob("Reverb")
               .setRange(0,99)
               .setValue(50)
               .setPosition(width/2 - knobRadius/2, height - (height/6 + 50))
               .setRadius(knobRadius)
               .setColorForeground(currentColor)
               .setColorBackground(secondaryColor)            //(0, 160, 100))
               .setColorActive(tertiaryColor)
               .setViewStyle(Knob.ARC)
               .setLabelVisible(false);

  
  knobMaster = cp5.addKnob("Master")
               .setRange(0,99)
               .setValue(50)
               .setPosition(width/2 - knobRadius/2 + width/10, height - (height/6 + 50))
               .setRadius(knobRadius)
               //.setNumberOfTickMarks(10)
               //.setTickMarkLength(3)
               //.snapToTickMarks(true)
               .setColorForeground(currentColor)
               .setColorBackground(secondaryColor)            //(0, 160, 100))
               .setColorActive(tertiaryColor)
               .setViewStyle(Knob.ARC)
               .setLabelVisible(false);
               
  
  
  //FONT STUFF:
    myFont = createFont("Rockwell Nova Light", 50);
    textFont(myFont);
    textAlign(CENTER, CENTER);
    
    
    oscP5 = new OscP5(this,12000);
    sender = new NetAddress("127.0.0.1",57120);
    
    //uploading SVG
    heartSVG = loadShape("heart.svg");
    
  
}

void draw() {
  
  //GEOMETRIC SHAPES:
  
  fill(Color1); //1-top left
  rect(0,0,width/2,height/2);
  
  fill(Color2); //2-top right
  rect(width/2,0,width/2,height/2);

  fill(Color3); //3-bottom left
  rect(0,height/2,width/2,height/2); 
  
  fill(Color4);  //4-bottom right
  rect(width/2,height/2,width/2,height/2);
  
  fill(currentColor);  //ellipse
  ellipse(width/2, height/2, width, height);
  
  
  textAlign(CENTER, CENTER);
  //EXIT BUTTON:
                                     //RectClose button
  if (overRectClose(width-21,0,21,21)) fill(#FF0000); //red
  else fill(#7EFCF4); //2-top right background
  rect(width-21,0,21,21);//000000;
  


  //TEXT:
  
  fill(#FFFFFF);
  textSize(50); //4 modes
  text("mode 1", offsetx, offsety-5);
  text("mode 2", width-offsetx, offsety-5);
  text("mode 3", offsetx, height-offsety);
  text("mode 4", width-offsetx, height-offsety);
  
   
  
  if(overRectClose(width-21,0,21,21)) fill (#FFFFFF); //X of the RectClose button
  else fill (#000000);
  textSize(30);
  text("×", width-10, 5); 
  fill (#000000);
  
  yToSend= mouseY / (float)height;
  xToSend= mouseX / (float)width;

  
  plotLiveInfo(mode);
  
  if (mode == 1){
    textSize(50);
    textAlign(CENTER);
    text("BAND-PASS FILTER", width/2-300, 50, 600, 80);
    textSize(30);
  }
   if (mode == 2){
    textSize(50);
    textAlign(CENTER);
    text("RANDOM NOTES", width/2-300, 50, 600, 80);
    textSize(30);
  }
   if (mode == 3){
    textSize(50);
    textAlign(CENTER);
    text("SONG ACCELERATOR", width/2-300, 50, 600, 80);
    textSize(30);
  }
   if (mode == 4){
    textSize(50);
    textAlign(CENTER);
    text("ARPEGGIATOR", width/2-300, 50, 600, 80);
    textSize(30);
  }
  
  //text("Hey you! move your cursor!", width/2, height/2);
  
  //KNOBS
  knobSongSelection.setColorForeground(color(currentColor)).setColorBackground(color(secondaryColor)).setColorActive(tertiaryColor);
  knobReverb.setColorForeground(color(currentColor)).setColorBackground(color(secondaryColor)).setColorActive(tertiaryColor);
  knobMaster.setColorForeground(color(currentColor)).setColorBackground(color(secondaryColor)).setColorActive(tertiaryColor);
  cp5.draw();
  text("Reverb", width/2-17, height - 80 , 110, 50);
  text("Master", width/2-17 + width/10, height - 80, 100, 50);
  text("Song", width/2+17 - knobRadius/2 - width/10, height - 80, 100, 50);
  text(str(int(knobSongSelection.getValue())),width/2 - width/10 + 8, height - (height/6 + 50) + 45, 60, 60);
  text(str(int(knobReverb.getValue())), width/2 + 8, height - (height/6 + 50) + 45, 60, 50);
  text(str(int(knobMaster.getValue())), width/2 + width/10 + 8, height - (height/6 + 50) + 45, 60, 60);
  //ARROWS:
  /*strokeWeight(2);
  stroke(secondaryColor);
  drawArrow(width/3,height/2,width/3,0);
  drawArrow(width/2,height/3.5,height-2*height/3.5,90);
  noStroke();*/
  
  //MOUSE GRAPHS
  
 for (int i = 1; i < rectWidth; i++) {
    xvals[i-1] = xvals[i];
    yvals[i-1] = yvals[i];
    ardvalsStream [i-1] = ardvalsStream [i];
  }
  // Add the new values to the end of the array
  xvals[rectWidth-1] = mouseX;
  yvals[rectWidth-1] = mouseY;
  
  
  /*if (myPort.available()>0){
    String val = myPort.readStringUntil('E');
    val = val.substring(0, val.length()-1);
    if(val.equals("NVV")){
      println("Current values are not valid");
      ardvalsStream[rectWidth-1]=ardvalsStream[rectWidth-2]; 
    }
    else{
      String currentValue = val.substring(0,3);
      ardvalsStream[rectWidth-1]=Integer.parseInt(currentValue);
      bpm = val.substring(3, val.length()); 
      println("Current value = " + currentValue);
      if(bpm.equals("33")){
        println("BPM = Waiting for valid data");
        bpm = currentBPM;
      }
      else{
        println("bpm = " + bpm);
        if(!bpm.equals(currentBPM)){
         currentBPM = bpm;
        }
      }
    }
  }*/

  fill(currentColor);
  
  rectMode(CENTER);
  rect(width/2, height/2, width/3, height/9+1);
  rectMode(CORNER);
  
  //sending OSC messages to supercollider
  OscMessage MessageToSend = new OscMessage("/pos");
  MessageToSend.add(mode);
  
  MessageToSend.add(mouseX / (float)width);
  MessageToSend.add(mouseY / (float)height);
  MessageToSend.add(bpm);
  
  MessageToSend.add(int (knobSongSelection.getValue()));
  MessageToSend.add(knobReverb.getValue()/200);
  MessageToSend.add(knobMaster.getValue()/200);
  
  oscP5.send(MessageToSend, sender);
  MessageToSend.print();
  
  strokeWeight(3);  
  for (int i = 0; i < rectWidth; i++) {

    // Draw the x-values
    stroke(secondaryColor);
    point(i+rectX, -5+rectY-map(xvals[i], 0,  width, 0, rectHeight));

    // Draw the y-values
    stroke(secondaryColor);
    point(i+rectX, rectY+map(yvals[i], 0, height, 0, 1+height/9));
    
    // Draw the heartbeat graph
    stroke(secondaryColor);
    point(i+rectX, +5+rectY+rectHeight+map(ardvalsStream[i], 550, 1050, rectHeight, 0));
  }
  
  fill(secondaryColor);
  textSize(20);
  textAlign(LEFT, BOTTOM);
  text("X", rectX-50, 5+rectY);
  text("Y", rectX-50, 10+rectY+rectHeight);
  heartSVG.disableStyle();
  stroke(secondaryColor);
  
  text(currentBPM, rectX-67, rectY+rectHeight+57, 80, 80);
  shape(heartSVG, rectX-95, rectY+rectHeight+85, 80, 80);
  
  textAlign(LEFT, BOTTOM);
  delay(50);
noStroke();
}


void oscEvent(OscMessage MessageToReceive) {
/* get and print the address pattern and the typetag of the received OscMessage */
println("### received an osc message with addrpattern "+MessageToReceive.addrPattern()+" and typetag "+MessageToReceive.typetag());

xParamToRecieve=MessageToReceive.get(0).floatValue();
yParamToRecieve=MessageToReceive.get(1).floatValue();
bpmParamToRecieve=MessageToReceive.get(2).floatValue();
//println("xParamToRecieve="+xParamToRecieve);
}


void plotLiveInfo(int mode){
  
  String yToDisplay;
  float pan=((xToSend-0.5)/0.5);
  String xToDisplay = nf(pan,1, 7);
  textAlign(LEFT, CENTER);
  int xMirror=0;
  int yMirror=0;

  if(mode==1){
    xMirror=0;
    yMirror=0;
  }
  
  //textAlign(CENTER, CENTER);
  //text("BPM-Current heart BPM:" +  bpm, rectX+rectWidth/2, rectY+5*rectHeight/2); //first mode initialization


  else if(mode==2){xMirror=1;yMirror=0;textAlign(RIGHT, CENTER);}
  else if(mode==3){xMirror=0;yMirror=1;}
  else if(mode==4){xMirror=1;yMirror=1;textAlign(RIGHT, CENTER);}
  float ySpacingOffset=0.3*height/6;
  float xTextFrequency=width/100+xMirror*(width-2*width/100);
  float yTextFrequency=height/6+yMirror*(height-2*height/6-ySpacingOffset*2);
  float xTextPan=width/100+xMirror*(width-2*width/100);
  float yTextPan=yTextFrequency+ySpacingOffset;
  float xTextBpm=width/100+xMirror*(width-2*width/100);
  float yTextBpm=yTextPan+ySpacingOffset;
 
 
 
  if(mode==1){ //first mode values
    yToDisplay=""+(1.5-(1.3*yToSend));
    text("X-Pan value:" + xParamToRecieve, xTextFrequency, yTextFrequency);
    text("Y-RQ factor:" + yParamToRecieve, xTextPan, yTextPan);
    text("BPM-Central frequency:" +  bpmParamToRecieve + " Hz", xTextBpm, yTextBpm);
  }
  else if(mode==2){ //second mode values
    text("X-Pan value:" + xParamToRecieve, xTextFrequency, yTextFrequency); 
    text("Y-midi Range value:±" + yParamToRecieve + " notes", xTextPan, yTextPan); 
    text("BPM-Central frequency:" + bpmParamToRecieve + " Hz", xTextBpm, yTextBpm); 
  }
  else if(mode==3){ //third mode values
    yToDisplay=""+2*yToSend;
    text("X-Pan value:" + xParamToRecieve, xTextFrequency, yTextFrequency); 
    text("Y-Speed of the song: x" + yParamToRecieve, xTextPan, yTextPan); 
    text("BPM-Current Delay:" + bpmParamToRecieve + " s", xTextBpm, yTextBpm); 
  }
  else if(mode==4){ //fourth mode values
     yToDisplay=""+(127-floor(yToSend*117));
    text("X-Pan value:" + xParamToRecieve, xTextFrequency, yTextFrequency); 
    text("Y-Freq of tonic note:" + yParamToRecieve + " Hz", xTextPan, yTextPan);
    text("BPM-Arpeggio duration:" + bpmParamToRecieve + " s", xTextBpm, yTextBpm);
  }
  textAlign(CENTER, CENTER);  
  }













void mousePressed() {
    //if (overEllipse()) exit();
    
    if (overRect1()&&!overEllipse()) {mode=1;currentColor=Color1; secondaryColor=Color1Secondary; tertiaryColor=Color1Tertiary;};
    if (overRect2()&&!overEllipse()&&!overRectClose(width-21,0,21,21)) {mode=2;currentColor=Color2; secondaryColor=Color2Secondary;  tertiaryColor=Color2Tertiary;};
    if (overRect3()&&!overEllipse()) {mode=3;currentColor=Color3; secondaryColor=Color3Secondary; tertiaryColor=Color3Tertiary;};
    if (overRect4()&&!overEllipse()) {mode=4;currentColor=Color4; secondaryColor=Color4Secondary; tertiaryColor=Color4Tertiary;};
}

void mouseClicked(){
  if (overRectClose(width-21,0,21,21)) exit();
}

void drawArrow(float x, float y, float len, float angle){
  pushMatrix();
  translate(x, y);
  rotate(radians(angle));
  line(0,0,len, 0);
  line(len, 0, len - 8, -8);
  line(len, 0, len - 8, 8);
  popMatrix();
}







boolean overRect1(){  
  
  if (mouseX < width/2 && mouseY < height/2) {
    return true;
  } else {
    return false;
  }
}

boolean overRect2(){  
  
  if (mouseX > width/2 && mouseY < height/2) {
    return true;
  } else {
    return false;
  }
}

boolean overRect3(){  

  if (mouseX < width/2 && mouseY > height/2) {
    return true;
  } else {
    return false;
  }
}

boolean overRect4(){  
  
  if (mouseX > width/2 && mouseY > height/2) {
    return true;
  } else {
    return false;
  }
}

boolean overRectClose(int x, int y, int width, int height)  {
  
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

boolean overEllipse() {
  
  float disX = width/2 - mouseX;
  float disY = height/2 - mouseY;
  
  if ((sq(disX) / sq(width/2) + sq(disY) / sq(height/2)) < 1 ) {
    return true;
  } else {
    return false;
  }
}

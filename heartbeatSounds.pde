/////////////////////////////////////////////////////////////////////VARIABLES
import oscP5.*;
import netP5.*;
import controlP5.*;
import processing.serial.*;

OscP5 oscP5;
ControlP5 cp5;
NetAddress sender;
NetAddress receiver;

//Arduino e mouse controller
int [] xvals;
int [] yvals;
int [] ardvalsStream;
String bpm="80";
String currentBPM = "80";
int currentSong=0;

//Arduino-Processing serial communication
Serial myPort;  
char val;

//this controls the dimension of the plots
int rectX;
int rectY;
int rectWidth;
int rectHeight;


//current mode controller
int mode=1;


//to print various text
int offsetx=110;
int offsety=52;
PFont myFont;

//plot parameters
String xParamToPlot;
String yParamToPlot;
String bpmParamToPlot;
float xParamToReceive;
float yParamToReceive;
float bpmParamToReceive;


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

//ControlP5 objects and SVG
Knob knobRoom;
Knob knobWave;
Knob knobDryWet;
Knob knobMaster;
int knobRadius;
DropdownList d1;

PShape heartSVG;

int num = 20;
int mx[] = new int[num];
int my[] = new int[num];
int currentXPad;
int currentYPad;

int leftKnobNumber;


/////////////////////////////////////////////////////////////////////MAIN SECTION OF THE CODE
void setup() {
  fullScreen();
  frameRate(240);
  noStroke();
  rectMode(CORNER);
  frameRate(240);
  
  mode=1;
  rectX= width/3-width/6;
  rectY= 20+4*height/9;
  rectWidth = width/3;
  rectHeight = height/9;
  
 //PAD:
  currentXPad=(width/2+int(1.3*width/8)+(3*rectHeight+10)/2);
  currentYPad=(-5+rectY-rectHeight+(3*rectHeight+10)/2);
  
 //MouseController
  xvals = new int[rectWidth];
  yvals = new int[rectWidth];
  for(int i=0;i<rectWidth;i++){xvals[i]=currentXPad;};
  for(int i=0;i<rectWidth;i++){yvals[i]=currentYPad;};
  
  ardvalsStream = new int[rectWidth];
  for(int i=0;i<rectWidth;i++){ardvalsStream[i]=550;};
  
  //Initializing arduino Serial

  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);

  //KNOBS STUFF:
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  
  knobRadius =height/15;
  
  
  
  knobRoom = cp5.addKnob("Room")
               .setRange(0,100)
               .setValue(50.1)
               .setPosition(width/2 - knobRadius - width/10, height - (height/6 + 50))
               .setRadius(knobRadius)
               .setColorForeground(currentColor)
               .setColorBackground(secondaryColor)            //(0, 160, 100))
               .setColorActive(tertiaryColor)
               .setViewStyle(Knob.ARC)
               .setLabelVisible(false);
               
  knobWave = cp5.addKnob("Synth")
               .setRange(1,4)
               .setValue(1)
               .setPosition(width/2 - knobRadius - width/10, height - (height/6 + 50))
               .setRadius(knobRadius)
               .setColorForeground(currentColor)
               .setColorBackground(secondaryColor)            //(0, 160, 100))
               .setColorActive(tertiaryColor)
               .setNumberOfTickMarks(3)
               //.setTickMarkLength(3)
               .snapToTickMarks(true)
               .setViewStyle(Knob.ARC)
               .setLabelVisible(false);
               
               
  knobDryWet = cp5.addKnob("Reverb")
               .setRange(0,100)
               .setValue(50.1)
               .setPosition(width/2-knobRadius, height - (height/6 + 50))
               .setRadius(knobRadius)
               .setColorForeground(currentColor)
               .setColorBackground(secondaryColor)            //(0, 160, 100))
               .setColorActive(tertiaryColor)
               .setViewStyle(Knob.ARC)
               .setLabelVisible(false);

  
  knobMaster = cp5.addKnob("Master")
               .setRange(0,100)
               .setValue(50.1)
               .setPosition(width/2 - knobRadius + width/10, height - (height/6 + 50))
               .setRadius(knobRadius)
               //.setNumberOfTickMarks(10)
               //.setTickMarkLength(3)
               //.snapToTickMarks(true)
               .setColorForeground(currentColor)
               .setColorBackground(secondaryColor)            //(0, 160, 100))
               .setColorActive(tertiaryColor)
               .setViewStyle(Knob.ARC)
               .setLabelVisible(false);
               
  // DROPDOWNLIST
  d1 = cp5.addDropdownList("myList-d1")
          .setPosition(width/2-200, 1.5*height/10)
          .setSize(400,200)
          .setColorForeground(color(90))
          .setColorActive(0)
          .setColorBackground(color(60));
  customize(d1); // customize the second list
  
  
  //FONT STUFF:
  myFont = createFont("Rockwell Nova Light", 50);
  textFont(myFont);
  textAlign(CENTER, CENTER);
    
    
  oscP5 = new OscP5(this,12000);
  sender = new NetAddress("127.0.0.1",57120);
  
  //uploading SVG
  heartSVG = loadShape("heart.svg");



  //point on mousepad
  ellipse(currentXPad, currentYPad, num, num);
}


void draw() {
  //pointer
  
  
  
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
    
  fill(color(60)); //mousePad black borders
  rect(width/2+int(1.3*width/8)-1,-6+rectY-rectHeight,3*rectHeight+12,3*rectHeight+12);
  
  fill(secondaryColor); //mousePad
  rect(width/2+int(1.3*width/8),-5+rectY-rectHeight,3*rectHeight+10,3*rectHeight+10);
  
  
  

  
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
  
  
  
  
  //KNOBS
  knobRoom.setColorForeground(color(currentColor)).setColorBackground(color(secondaryColor)).setColorActive(tertiaryColor);
  knobWave.setColorForeground(color(currentColor)).setColorBackground(color(secondaryColor)).setColorActive(tertiaryColor);
  knobDryWet.setColorForeground(color(currentColor)).setColorBackground(color(secondaryColor)).setColorActive(tertiaryColor);
  knobMaster.setColorForeground(color(currentColor)).setColorBackground(color(secondaryColor)).setColorActive(tertiaryColor);
  cp5.draw();
  textAlign(CENTER,CENTER);
  if(mode%2==1){
    text("Room", width/2 - knobRadius - width/10, height - 80, knobRadius*2, 50);
    text("Dry/Wet", width/2 - knobRadius, height - 80 , knobRadius*2, 50);
    leftKnobNumber=int(knobRoom.getValue());
    d1.show();}
  else{
    text("Wave", width/2 - knobRadius - width/10, height - 80, knobRadius*2, 50);
    leftKnobNumber=int(knobWave.getValue());
    d1.hide();}
  text("Master", width/2 - knobRadius + width/10, height - 80, knobRadius*2, 50);
  
  

  
  
  text(str(leftKnobNumber), width/2 - knobRadius - width/10, height - (height/6 + 50) + 40, knobRadius*2, 50);
  if(mode%2==1)text(str(int(knobDryWet.getValue())), width/2 - knobRadius, height - (height/6 + 50) + 40, knobRadius*2, 50);
  text(str(int(knobMaster.getValue())), width/2 - knobRadius + width/10, height - (height/6 + 50) + 40, knobRadius*2, 50);
  
  //ARROWS:
  strokeWeight(2);
  stroke(secondaryColor); // (width/2+width/8,-5+rectY-rectHeight,3*rectHeight+10,3*rectHeight+10)
  drawArrow(width/2+int(1.3*width/8)-30,5+rectY-rectHeight+3*rectHeight+20,3*rectHeight+60,0);
  drawArrow(width/2+int(1.3*width/8)-20,5+rectY-rectHeight+3*rectHeight+30,3*rectHeight+60,270);
  noStroke();
  
  
  //MOUSE GRAPHS
  
 for (int i = 1; i < rectWidth; i++) {
    xvals[i-1] = xvals[i];
    yvals[i-1] = yvals[i];
    ardvalsStream [i-1] = ardvalsStream [i];
  }
  // Add the new values to the end of the array
  xvals[rectWidth-1] = currentXPad;
  yvals[rectWidth-1] = currentYPad;
  
 
  if (myPort.available()>0){
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
  }

  fill(currentColor);
  
  //rectMode(CENTER);
  // rect(width/2, height/2, width/3, height/9+1);
  rectMode(CORNER);
  
  //sending OSC messages to supercollider
  OscMessage MessageToSend = new OscMessage("/pos");
  MessageToSend.add(mode);
  
  MessageToSend.add(map(currentXPad, width/2+int(1.3*width/8)+10,  width/2+int(1.3*width/8)+3*rectHeight, 0,1)); //width/2+width/8,-5+rectY-rectHeight,3*rectHeight+10,3*rectHeight+10)
  MessageToSend.add(map(currentYPad, rectY-rectHeight+5,  rectY-rectHeight+3*rectHeight-5, 0,1));
  MessageToSend.add(bpm);//ho sostituito bpm!
  
  MessageToSend.add(currentSong);

  MessageToSend.add(knobRoom.getValue()/100);
  MessageToSend.add(knobDryWet.getValue()/100);
  MessageToSend.add(knobMaster.getValue()/150);
  MessageToSend.add(knobWave.getValue());
  
  oscP5.send(MessageToSend, sender);
  
  strokeWeight(3);  
  for (int i = 0; i < rectWidth; i++) {

    // Draw the x-values
    stroke(secondaryColor);
    point(i+rectX, -5+rectY-map(xvals[i], width/2+int(1.3*width/8)+10,  width/2+int(1.3*width/8)+3*rectHeight, 0, rectHeight));

    // Draw the y-values
    point(i+rectX, rectY+map(yvals[i], rectY-rectHeight+5, rectY-rectHeight+3*rectHeight-5, 0, 1+height/9));
    
    // Draw the heartbeat graph
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
  
  textAlign(CENTER, CENTER);
noStroke();

  fill(#000000);
  textSize(30);
  text("Mouse pad",  width/2+int(1.3*width/8)+(3*rectHeight)/2, num/2-5+rectY-rectHeight-40);
  fill(tertiaryColor);
  int which = frameCount % num;

  mx [which]= constrain(mouseX, num/2+width/2+int(1.3*width/8),(width/2+int(1.3*width/8)+3*rectHeight+10)-num/2);
  my [which] = constrain(mouseY, num/2-5+rectY-rectHeight,(-5+rectY-rectHeight+3*rectHeight+10)-num/2);
  
if(mousePressed && overRectClose(width/2+int(1.3*width/8),-5+rectY-rectHeight,3*rectHeight+10,3*rectHeight+10)){
    for (int i = 0; i < num; i++) {
      // which+1 is the smallest (the oldest in the array)
      int index = (which+1 + i) % num;
      ellipse(mx[index], my[index], i, i);
    }
  currentXPad = mx [num-1];
  currentYPad = my [num-1];
  }
else{
  ellipse(currentXPad, currentYPad, num, num);
}
delay(5);
textAlign(LEFT, BOTTOM);
}












/////////////////////////////////////////////////////////////////////SECONDARY SECTION OF THE CODE

void oscEvent(OscMessage MessageToReceive) {
/* get and print the address pattern and the typetag of the received OscMessage */
//println("### received an osc message with addrpattern "+MessageToReceive.addrPattern()+" and typetag "+MessageToReceive.typetag());

xParamToReceive=MessageToReceive.get(0).floatValue();
xParamToPlot=nf(xParamToReceive,1,2);
yParamToReceive=MessageToReceive.get(1).floatValue();
bpmParamToReceive=MessageToReceive.get(2).floatValue();
//println("xParamToReceive="+xParamToReceive);
}


void plotLiveInfo(int mode){
  
  
  textAlign(LEFT, CENTER);
  int xMirror=0;
  int yMirror=0;

  if(mode==1){
    xMirror=0;
    yMirror=0;
  }
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
    text("X-Pan value:" + xParamToPlot, xTextFrequency, yTextFrequency);
    yParamToPlot=nf(yParamToReceive,1,2);
    text("Y-RQ factor:" + yParamToPlot, xTextPan, yTextPan);
    text("BPM-Central frequency:" +  int(bpmParamToReceive) + " Hz", xTextBpm, yTextBpm);
    knobWave.hide();
    knobRoom.show();
    knobDryWet.show();
  }
  else if(mode==2){ //second mode values
    text("X-Pan value:" + xParamToPlot, xTextFrequency, yTextFrequency);
    text("Y-midi Range value:±" + int(yParamToReceive) + " notes", xTextPan, yTextPan);
    text("BPM-Central frequency:" + int(bpmParamToReceive) + " Hz", xTextBpm, yTextBpm); 
    knobRoom.hide();
    knobDryWet.hide();
    knobWave.show();
  }
  else if(mode==3){ //third mode values
    text("X-Pan value:" + xParamToPlot, xTextFrequency, yTextFrequency); 
    yParamToPlot=nf(yParamToReceive,1,2);
    text("Y-Speed of the song: x" + yParamToPlot, xTextPan, yTextPan);
    bpmParamToPlot=nf(bpmParamToReceive,1,2);
    text("BPM-Current Delay:" + bpmParamToPlot + " s", xTextBpm, yTextBpm); 
    knobRoom.show();
    knobDryWet.show();
    knobWave.hide();
}
  else if(mode==4){ //fourth mode values
    text("X-Pan value:" + xParamToPlot, xTextFrequency, yTextFrequency); 
    text("Y-Freq of tonic note:" + int(yParamToReceive) + " Hz", xTextPan, yTextPan);
    bpmParamToPlot=nf(bpmParamToReceive,1,2);
    text("BPM-Arpeggio duration:" + bpmParamToPlot + " s", xTextBpm, yTextBpm);
    knobRoom.hide();
    knobDryWet.hide();
    knobWave.show();
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




//Customization of dropdown menu
void customize(DropdownList ddl) {
  ddl.setItemHeight(40);
  ddl.setBarHeight(40);
  ddl.setCaptionLabel("Choose the song:");  
    ddl.addItem("0 - Applause demo ", 0);
    ddl.addItem("1 - Billie Jean ", 1);
    ddl.addItem("2 - Black hole sun ", 2);
    ddl.addItem("3 - Grounds for divorce ", 3);
    ddl.addItem("4 - My very good friend the milkman ", 4);
    ddl.addItem("5 - Never gonna give you up ", 5);
    ddl.addItem("6 - No man no cry ", 6);
    ddl.addItem("7 - Smokestack lightnin' ", 7);
    ddl.addItem("8 - Staying alive ", 8);
    ddl.addItem("9 - Take five ", 9);
    ddl.addItem("10 - Take on me ", 10);
  //ddl.scroll(0);

}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } 
  else if (theEvent.isFrom(d1)) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
    currentSong=int(theEvent.getController().getValue());
  }
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

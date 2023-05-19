# group8-hw-ID-Synth101
Group 08 repository for the ID homework of CMLS 2023.

<h1>Heart controlled sound generator and filter Synth 101</h1>

  <p>Implementation of computer music system using Arduino (with board MKR 1010), Processing and SuperCollider, with the goal of experimenting sound variation driven by a heart rate. An additional feature is the possibility to change the sound using your mouse.
  You can visualize the interactions, represented as a graph, in the gui.
  The code could be executed by plugging the Arduino board to an USB port, after that you must execute the supercollider "HeartbeatSoundGenerator.scd" by running the code contained in the parentesis at line 1, 5 and 19.
  and at last runnnig the processing "HeartbeatSoundGenerator.pde" file.
  You could now see a full screen GUI identical to the one displayed in the image below, at the bottom of there are three main knob: one to choose the song you want to play, one to set the overall reverb(still to implement) and one to control the overall volume.
  You can choose the mode that you prefer by clicking on the corresponding text.
  In the following lines we are going to breafly explain the features of each mode.
</p>
 
 ![GUI](https://github.com/polimi-cmls-23/group8-hw-ID-Synth101/assets/127778048/793a913f-2cf8-4e67-9622-3f198b272533)

    
<div>
  <h2>Mode 1: band-pass filter</h2>
  <div>Mouse x: controls the pan </div>
  <div>Mouse y: controls the amplitude of the band pass filter</div>
  <div>Heart rate: controls the central frequency of the band pass filter</div>

  <h2>Mode 2: random notes</h2>
  <div>Mouse x: controls the pan </div>
  <div>Mouse y: controls the note range</div>
  <div>Heart rate: controls the central frequency of note creation</div>
  
  <h2>Mode 3: song accelerator</h2>
  <div>Mouse x: controls the pan </div>
  <div>Mouse y: speed of the song</div>
  <div>Heart rate: delay</div>
  
  <h2>Mode 4: arpeggiator</h2>
  <div>Mouse x: controls the pan </div>
  <div>Mouse y: controls the frequency of the tonic</div>
  <div>Heart rate: controls the rate of the notes</div>
</div>

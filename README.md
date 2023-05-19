# group8-hw-ID-Synth101
Group 08 repository for the ID homework of CMLS 2023.

<h1>Heart controlled sound generator and filter Synth 101</h1>

  <p>Implementation of a computer music system using Arduino (board MKR 1010), Processing and SuperCollider with the goal of experimenting with sounds modulated by one's heartbeat rate. An additional level of modulation is given by the current mouse position in the processing interface.
  Current mouse position and heart pressure levels are represented in a graph in the middle of the GUI.
  The code can be executed by plugging the Arduino board to a computer's USB port, after doing so it is necessary to open the supercollider "HeartbeatSoundGenerator.scd" and to run the code contained in the parentesis at line 1, 5 and 19. Lastly, in order for everyhthing to work, you'll need to run the processing "HeartbeatSoundGenerator.pde" file.
  Once this is done you should be able to see a fullscreen GUI identical to the one displayed in the image below, at the bottom of there are three knobs: one lets you choose the song to play, another determines the overall reverb intensity (still to be implemented) and the last one to control the overall master volume.
  It is possible to choose between four different modes by clicking on the corresponding text.
  In the following lines we are going to briefly discuss the features of each mode.
</p>
 
 ![GUI](https://github.com/polimi-cmls-23/group8-hw-ID-Synth101/assets/127778048/793a913f-2cf8-4e67-9622-3f198b272533)

    
<div>
  <h2>Mode 1: band-pass filter</h2>
  <div>Mouse x: controls the pan </div>
  <div>Mouse y: controls the rq factor of the band-pass filter</div>
  <div>Heart rate: controls the central frequency of the band-pass filter</div>

  <h2>Mode 2: random notes</h2>
  <div>Mouse x: controls the pan </div>
  <div>Mouse y: controls the note range</div>
  <div>Heart rate: controls the central frequency of note generation</div>
  
  <h2>Mode 3: song accelerator</h2>
  <div>Mouse x: controls the pan </div>
  <div>Mouse y: controls the speed of the song</div>
  <div>Heart rate: controls the delay time</div>
  
  <h2>Mode 4: arpeggiator</h2>
  <div>Mouse x: controls the pan </div>
  <div>Mouse y: controls the frequency of the tonic</div>
  <div>Heart rate: controls duration of the arpeggio</div>
</div>

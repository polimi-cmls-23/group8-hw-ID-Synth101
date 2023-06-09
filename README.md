<h1>Heartbeat Sound - Synth 101</h1>

  <p>Implementation of a computer music system using Arduino (with board MKR 1010), Processing and SuperCollider, with the goal of experimenting sound variation driven by someone's heart rate. An additional feature is the possibility of applying several effects with your mouse by clicking and dragging it around the dedicated pad.
  You can visualize the interactions in the GUI thanks to the presence of three real time graphs.
  The code could be executed by plugging the Arduino board to an USB port, then loading the supercollider "heartbeatSounds.scd" by running the code contained in the brackets at lines 1, 5 and 17, and finally executing the processing "heartbeatSounds.pde" file.
  You should see a full screen GUI identical to the one displayed in the image below, at the bottom of which there are different control knobs that can be used to change some overall properties of the sound in the specific mode.
  In particular "room" and "dry/wet" are two parameters related to an additonal reverb present in mode 1 and mode 3. In mode 2 and mode 4 instead there's the knob "wave" that controls the type of waweshape. For every mode there is also the "master" knob that adjusts the general volume.  
  You can choose the mode that you prefer by clicking on the corresponding text.
  When the mode implies the selection of a song, a specific drop-down menu is shown in the top part of the screen.
  In order for the code to work, you must download also the "song" folder and set its path in the third line of the supercollider code.
  In the following lines we are going to briefly explain the characteristics of each mode.
</p>
 
 ![GUI](https://github.com/polimi-cmls-23/group8-hw-ID-Synth101/assets/127778048/62fad9c9-29c3-4d80-a0d0-8fa0c48f2421)

    
<ul>
  <h2>Mode 1: band-pass filter</h2>
  <li>Mouse x: controls the pan </li>
  <li>Mouse y: controls the amplitude of the band pass filter</li>
  <li>Heart rate: controls the central frequency of the band pass filter</li>

  <h2>Mode 2: random notes</h2>
  <li>Mouse x: controls the pan </li>
  <li>Mouse y: controls the distance between the highest and the lowest generated note</li>
  <li>Heart rate: controls the frequency of the central note</li>
  
  <h2>Mode 3: song accelerator</h2>
  <li>Mouse x: controls the pan </li>
  <li>Mouse y: controls the speed of the song</li>
  <li>Heart rate: controls the delay applied to the song</li>
  
  <h2>Mode 4: arpeggiator</h2>
  <li>Mouse x: controls the pan </li>
  <li>Mouse y: controls the frequency of the tonic note</li>
  <li>Heart rate: controls the time rate of the notes</li>
</ul>


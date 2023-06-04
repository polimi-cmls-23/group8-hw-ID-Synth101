(
~songs=Array.new;
~folder=PathName.new(thisProcess.nowExecutingPath.dirname+/+"songs")
)
(
~folder.entries.do({
	arg path;
	~songs=~songs.add(Buffer.read(s,path.fullPath));
});
)





//OSC MESSAGES
(
var recAddr=NetAddr("127.0.0.1",57120);
var sendAddr=NetAddr("127.0.0.1",12000);
var bpm=80,currentMode, currentSong, songNumber, songSelection=1,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10, currentWave;

OSCdef('OSCreceiver',

	{
		arg msg;//addr= recAddr;
		~mode= msg[1];

		x = msg[2];
		y = msg[3];
		bpm = (msg[4]).asInteger;

		songSelection =msg[5];

		~room=msg[6];
		~reverb =msg[7];
		~master =msg[8];
		~wave = (msg[9]).asInteger;
		postln(bpm);
		x = (x-0.5)/0.5;   // x corresponds to panning, so it has to be between -1 and 1 (now it is between 0 and 1)
	},
	"/pos");


currentMode= -1;
currentSong= -1;
currentWave= 1 ;


Routine({
	0.2.wait;
	loop({
		0.1.wait;
		if((currentMode!=~mode).or(currentSong!=songSelection).or(currentWave!=~wave),{

			~synthCurrentMode.free;
			~routine01.stop;
			~routine02_1.stop;
			~routine02_2.stop;
			~routine03.stop;
			~routine04_1.stop;
			~routine04_2.stop;
			v.free;
			a.free;
			b.free;



			currentWave=~wave;
			//DEF PRIMO EFFETTO
			SynthDef(\effect1,
				{
					arg out=0, freq = 250, rq = 0.5, master=0.5, pan=0, mix, room, damp=0.5;
					var sig,sigOut;
					sig = PlayBuf.ar(2, ~songs[songSelection].bufnum, 1, doneAction:0);

					sigOut = {BPF.ar(sig,freq,rq)};
					Out.ar(out, FreeVerb.ar([master*sigOut*1.2*((1-pan)/2)], mix, room, damp));
					Out.ar(out+1, FreeVerb.ar([master*sigOut*1.2*((1+pan)/2)], mix, room, damp));
			}).add;
			//DEF SECONDO EFFETTO
			SynthDef(\effect2,
				{ arg out=0, freq=440, sustain=0.05, pan=0, master=0.5, wave=1;
					var env, sig;
					env = EnvGen.kr(Env.perc(0.01, sustain, 0.2), doneAction: Done.freeSelf);
					//postln(~wave);
					//wave = ~wave;

					postln("wave inside osc="+wave.source );

					sig = switch (~wave,
								//postln("wave="+~wave);
								1,{SinOsc.ar(freq, 0, env)},
								2,{LFSaw.ar(freq, 0, env)},
								3,{Pulse.ar(freq, 0.5, env)},
								4,{LFTri.ar(freq, 0, env)};);

					Out.ar(out,LinPan2.ar(sig*master, pan));

					//Out.ar(out,master*Pan2.ar(sig,Line.kr(-1, 1, freqLFO)));


			}).add;
			//DEF TERZO EFFETTO
			SynthDef(\effect3,
				{
					arg out=0, pan= -1, rate=1, master=0.5, mix, room, damp=0.5;
					var sigOut,sigOutDelayed;

					sigOut=PlayBuf.ar(2, ~songs[songSelection].bufnum, rate, loop:0);
					Out.ar(out, FreeVerb.ar([master*sigOut*0.7*((1-pan)/2)], mix, room, damp));
					Out.ar(out+1, FreeVerb.ar([master*sigOut*0.7*((1+pan)/2)], mix, room, damp));
			}).add;
			//DEF QUARTO EFFETTO
			SynthDef(\effect4,
				{
					arg out=0, freq=440, sustain=0.05, pan=0, master=0.5, wave=1;
					var env, sig;

					env = EnvGen.kr(Env.perc(0.01, sustain, 0.2), doneAction: Done.freeSelf);

					wave = ~wave;
					sig = switch (~wave,

						1,{SinOsc.ar(freq, 0, env)},
						2,{LFSaw.ar(freq, 0, env)},
						3,{Pulse.ar(freq, 0.5, env)},
						4,{LFTri.ar(freq, 0, env)};
					);


					Out.ar(out,Pan2.ar(master*sig*1.2,pan));
			}).add;
			//DEF DELAY
			SynthDef(\myDelay,
				{
					arg delaytime=0.3;
					var input, effect;

					input=In.ar(0,2); //get two channels of input starting on bus 0
					effect= DelayN.ar(input, 2,delaytime); //max delay of two second
					Out.ar(0,0.5*effect); //output
			}).add;




			1.wait;

			switch (~mode,

				1,{
					//riproduzione primo effetto
					~synthCurrentMode = Synth(\effect1,[\freq, 250, \rq, 0.5,\master,~master]);

					~routine01=Routine({
						loop({
							var freq, rq;
							postln(bpm.isMemberOf(Integer));
							postln("bpm="+bpm);
							freq=bpm.linexp(61,129,100,5000);
							postln("mapped freq="+freq+"x="+x);
							rq = 1.5-(y*1.3);
							~synthCurrentMode.set(\freq, freq, \rq, rq,\master, ~master, \pan, x, \mix, ~reverb, \room, ~room);
							sendAddr.sendMsg("/DataForProcessing", x, rq, freq.asFloat);
							0.05.wait;
						})
					}).play;

				},
				2, {
					//riproduzione secondo effetto
					~routine02_1=Routine({
						loop({
							var rand;

							~variation = (y*20).trunc.asInteger;
							//f=0+(y*118).trunc.asInteger;
							f=(bpm*(108/149)).trunc.asInteger;
							rand = rrand(f-~variation, f+~variation);
							p = rand.midicps;
							0.1.wait;
						})
					}).play;
					~routine02_2=Routine({

						loop({
							arg env,freq;
							// postln(napoli);
							~synthCurrentMode =Synth(\effect2, [\freq, p,\pan,x,\master, ~master]);
							// ~synthCurrentMode.set(\variabiletemporanea,4);
							sendAddr.sendMsg("/DataForProcessing", x, ~variation.asFloat, f.midicps.asFloat);
							0.1.wait;
						})
					}).play;

				},
				3, {//riproduzione terzo effetto.
					a = Group.new;
					b=Group.after(a);

					~synthCurrentMode = Synth(\effect3, [\buffer, b, \rate, 1.5, \pan, x,\master,~master],target:a);
					v= Synth(\myDelay,[\delaytime,0],target:b);


					//modulazione Effetto 3
					~routine03=Routine({
						loop({
							var delay=(bpm-41)/(108);
							~synthCurrentMode.set(\rate, y*2, \pan, x,\master,~master, \mix, ~reverb, \room, ~room);
							v.set(\delaytime, delay);
							0.1.wait;
							sendAddr.sendMsg("/DataForProcessing", x, y*2, delay.asFloat);
							postln(delay.asFloat);
						})
					}).play;
				},
				4, {
					//riproduzione quarto effetto.
					~routine04_1=Routine({
						loop({
							f=127-(y*117).trunc.asInteger;
							l=[f, f+3, f+7, f+12];
							a = Pseq(l, inf).asStream;
							postln(bpm);
							(60/bpm).wait;
						})
					}).play;
					~routine04_2=Routine({
						var freq;
						(60/(bpm*4)).wait;
						loop({
							freq=a.next.midicps;
							//napoli=~wave;
							~synthCurrentMode=Synth(\effect4, [\freq, freq, \pan, x, \master, ~master]);
							//~synthCurrentMode.set(\wave,napoli);
							(60/(bpm*4)).wait;
							sendAddr.sendMsg("/DataForProcessing", x, f.midicps, 60/(bpm));
						})
					}).play;
				};
			);
			currentMode=~mode;
			currentSong= songSelection;

		},{});
		0.1.wait;
	})
}).play;


/*
Routine({
	loop({
		0.1.wait;
		sendAddr.sendMsg("/heartBeat", 1);
	});
}).play;
*/
)

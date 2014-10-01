// to play with Arduino
s.boot;
(
~es = Buffer.alloc(s, s.sampleRate * 5, 1);
~qi = Buffer.alloc(s, s.sampleRate * 5, 1);
);
//AUDIO & SynthDefs <--         
(
(// mic limpio asignado a t, BUS 9 (R)
SynthDef(\entrada, {|tdelay=0, decay=5, mix=0, level=0, gate=1|
        var sen, env, del;
        sen=In.ar(9);
        sen=AllpassN.ar(sen,0.1, tdelay, decay);
        del=FreeVerb.ar(sen,mix,0.5,0.5,1);
        sen=Pan2.ar(del, 0, level);
        env=EnvGen.kr(Env.asr(0,1,0),gate,doneAction:2);
        Out.ar(0,sen*env)
        }).send(s)
        );       
(// filtro1 asignado a g, BUS 8 (L) trunc con filtro
SynthDef(\filtro1, {|trunc=1, freq=500, level=0, gate=1, action=0|
        var sen, env;
        sen=In.ar(8).trunc(trunc);
        sen=Resonz.ar(sen,freq, 0.5, level);
        sen=Pan2.ar(sen, 0, level);
        env=EnvGen.ar(Env.asr(0.1,1,0.1), gate, doneAction:action);
        Out.ar(0,sen*env)
        }).send(s)
        ); 
(// filtro2 asignado a x, BUS 8 (L) trunc 
SynthDef(\filtro2,{|trunc=1, level=0, gate=1, action=0|
         var in, sen, env;
         in=In.ar(8).trunc(trunc);
         sen=Pan2.ar(in,0,level);
         env=EnvGen.ar(Env.asr(0.1,05,0.01),gate,doneAction:action);
         Out.ar(0,sen * env) * 0.4
         }).send(s)
         );
(// rec del BUS 8 asignado a q, graba al buffer a
SynthDef(\rec8,{
		RecordBuf.ar(In.ar(8), ~es.bufnum, loop:0, doneAction:2);
		}).send(s)
		);
(// rec del BUS 9 asignado a e, graba al buffer b
SynthDef(\rec9,{
        RecordBuf.ar(In.ar(9), ~qi.bufnum, loop:0, doneAction:2);
        }).send(s)
        );
(// play del buffer a asignado a k, reproduce el audio del buffer a(es)
SynthDef(\play8,{|gate=1, level=1, action=0|
		var sen, env;
		sen=PlayBuf.ar(1, ~es.bufnum, loop:1);
		sen=Pan2.ar(sen, 0, level);
		env=EnvGen.kr(Env.asr(0,1,0), gate, doneAction:action);
		Out.ar(0,sen*env)
		}).send(s)
		);
(// play del buffer b asignado a f, reproduce el audio del buffer b(qi)
SynthDef(\play9,{|freqS=50, rate=1, level=1, gate=1, action=0|
        var sen, env;
        sen=PlayBuf.ar(1, ~qi.bufnum, rate, loop:1);
        sen=FreqShift.ar(sen,freqS,0,[1,1]);
        sen=Pan2.ar(sen, 0, level);
        env=EnvGen.kr(Env.asr(0,1,0.1), gate, doneAction:action);
        Out.ar(0,sen*env)
        }).send(s)
        );
);       
// Prender <------------------
(
t = Synth(\entrada);	// bus 9 mic limpio (mic grande)
g = Synth(\filtro1);	// bus 8 filtro 1      
x = Synth(\filtro2);	// audio out filtro 2
~mic1 = Synth(\play8);	// audio play del buffer a (es)      
f = Synth(\play9);	// audio play del buffer b (qi)
);       

//Rutina de control <--------------------------
(
j = Routine{ 
	var digitalAnt1, cambio1=0; 
	var digitalAnt2, cambio2=0; 
	var digitalAnt3, cambio3=0; 
	var digitalAnt4, cambio4=0;
	var digitalAnt5, cambio5=0;
		
	loop{
           // analog1 asignado a freq del filtro 1
           g.set(\freq, ~analog1 + 100);
           
           // analog2 asignado a mix del mic limpio/rev
           t.set(\tdelay, ~analog2 / 255);
           
           // analog3 asignado al pitch rate del buffer b
           f.set(\rate, (~analog3 / 1024) + 0.01);
           
           // analog4 lrd asignado al pitch del buffer b
           f.set(\freqS, ~analog4 * 2);
                      
           // digital1, asignado a on/off filtro1
           if(~digital1 != digitalAnt1,
           {
           if (~digital1 == 0, {cambio1 = cambio1 +1});
           g.set(\gate, (cambio1 %2).postln);
           }
           );
           
           // digital2, asignado a on/off filtro2
           if(~digital2 != digitalAnt2,
           {
           if (~digital2 == 0, {cambio2 = cambio2 +1});
           x.set(\gate, (cambio2 %2).postln);
           }
           );
           
           // digital3, asignado a on/off mic sin plastico
           if(~digital3 != digitalAnt3,
           {
           if (~digital3 == 0, {cambio3 = cambio3 +1});
           t.set(\level, (cambio3 %2).postln);
           }
           );
           
           // digital4, asignado a on/off play buffer 9 b(~qi)
           if(~digital4 != digitalAnt4,
           {
           if (~digital4 == 0, {cambio4 = cambio4 + 1});
           f.set(\gate, (cambio4 %2).postln);
           }
           );
           
           // digital5, asignado a on/off play buffer 8 a(~es)
           if(~digital5 != digitalAnt5,
           {
           if (~digital5 == 0, {cambio5 = cambio5 + 1});
           ~mic1.set(\gate, (cambio5 %2).postln);
           }
           );
           
           digitalAnt1 = ~digital1;
           digitalAnt2 = ~digital2;
           digitalAnt3 = ~digital3;
           digitalAnt4 = ~digital4;
           digitalAnt5 = ~digital5;
           
           0.01.yield;}}.play;
);
 
// SCWindow <--
(
var ventanaEsq;
var boton1, boton2, boton3, boton4;
var slider1, slider2, sliderf, slider3, slider4;

ventanaEsq= Window("controles", Rect (750, 25, 270, 165)).front;

slider1= Slider(ventanaEsq, Rect(25, 25, 20, 120));
slider2= Slider(ventanaEsq, Rect(50, 25, 20, 120));
sliderf= Slider(ventanaEsq, Rect(100, 25, 20, 120));
slider3= Slider(ventanaEsq, Rect(125, 25, 20, 120));
slider4= Slider(ventanaEsq, Rect(160, 25, 20, 120));

boton1= Button(ventanaEsq, Rect(210, 25, 30, 20));
boton2= Button(ventanaEsq, Rect(210, 55, 30, 20));


StaticText(ventanaEsq, Rect(25, 3, 50, 30)).string_("in");
StaticText(ventanaEsq, Rect(25, 140, 50, 30)).string_("vol");
StaticText(ventanaEsq, Rect(50, 3, 50, 30)).string_("in");
StaticText(ventanaEsq, Rect(50, 140, 50, 30)).string_("rev");
StaticText(ventanaEsq, Rect(100, 3, 50, 30)).string_("d1");
StaticText(ventanaEsq, Rect(100, 140, 50, 30)).string_("vol");
StaticText(ventanaEsq, Rect(125, 3, 50, 30)).string_("d2");
StaticText(ventanaEsq, Rect(125, 140, 50, 30)).string_("vol");
StaticText(ventanaEsq, Rect(160, 3, 50, 30)).string_("sample");
StaticText(ventanaEsq, Rect(160, 140, 50, 30)).string_("vol");

slider1.action= {t.set(\level, slider1.value)};
slider2.action= {t.set(\mix, slider2.value)};
sliderf.action= {g.set(\level, sliderf.value)};
slider3.action= {x.set(\level, (slider3.value / 10))};
slider4.action= {f.set(\level, slider4.value)};

boton1.states=[["ooo", Color.black, Color(1,1,0)]];
boton2.states=[["xxx", Color.black, Color(0,1,0)]];

boton1.action={ |val| if(val.value == 0, {Synth(\rec9)})};
boton2.action={ |val| if(val.value == 0, {Synth(\rec8)})};
);

// Final <--
(// apaga Routine y Synths
j.stop; 

q.set(\gate, 0); // audio off
t.set(\gate, 0); // entrada limpia off
g.set(\action, 2); // filtro off 
x.set(\action, 2); // filtro2 off
f.set(\action,2);
~mic1.set(\action, 2); // buffer a play off

f.set(\level,0,\gate,1); // prueba de apagar el synth despues de \action
~mic1.set(\level,0,\gate,1);
g.set(\level,0,\gate,1);
x.set(\level,0,\gate,1);
);

(// apaga synths f,k,g,x <--
f.set(\gate, 0);
~mic1.set(\gate, 0);
g.set(\gate, 0);
x.set(\gate, 0);        
~es.free;
~qi.free;
)
currentEnvironment.clear;

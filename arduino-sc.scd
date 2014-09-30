//============================================
// Arduino SMS connection to SuperCollider
// 5 buttons, 3 knobs, 1 lrd
// scketch arduino --> Esquirla 4
// serial port --> /dev/ttyUSB0
// requires Arduino SMS quark
// Code by hv
//============================================
(
var ventana, boton, boton2;

ventana = Window("Arduino", Rect(298, 23, 106, 80)).front;
boton=Button(ventana, Rect(8, 6, 84, 24));
boton2=Button(ventana, Rect(8,36,84,24));

boton.states=[["SMSapagado", Color.black, Color.gray], ["SMSprendido", Color.black, Color.green]];
boton2.states=[["no action", Color.black, Color.gray],["action",Color.black, Color.green]];

boton.action={|val| if(val.value == 1, {p = ArduinoSMS("/dev/ttyUSB0", 115200)},{p.close})};

boton2.action={|val| if(val.value == 1, {p.action = {|... msg|
	
	~analog1=msg[0];
	~analog2=msg[1];
	~analog3=msg[2];
	~analog4=msg[3];
	~digital1=msg[4];
	~digital2=msg[5];
	~digital3=msg[6];
	~digital4=msg[7];
	~digital5=msg[8];
	
	}},{"ciao".postln})};
	
ventana.onClose={p.close}
);

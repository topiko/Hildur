// BEARING:
BEARINGD = 11;
BEARINGT = 4;
BEARINGAXLED= 5;

// BOLTS:
BOLT3TIGHT=2.9;
BOLT3LOOSE=3.05;
BOLT25TIGHT = 2.40;
BOLT25LOOSE = 2.60;

// GEARS:
GEART = 6;
GEARMODUL = 1;
HELIXANGLE=45;

SERVOGEARNTOOTH = 15;
SERVOHORNT = 7;
SERVOHORNBEARINGT = 4;
AXLEHORNDIN = 6;

// Bore, Diam, Thickness
SERVOBEARINGDIMS = [5, 11, 4];
AXLEBEARINGDIMS = [10, 15, 4];
WHEELBEARINGDIMS = [20, 27, 4];

SERVOHORNSP = .96;
TIGHTSP = .05;

GEARCOLOR="Ivory"; //WhiteSmoke"; //SlateGray";
BEARINGCOLOR="Gray";
$fn = 0; //50000;
acc = "print"; //"show"; // "print";

$fa = acc=="print" ? 1 : 5; //1;
$fs = acc=="print" ? .2 : 1; //.2; //.02



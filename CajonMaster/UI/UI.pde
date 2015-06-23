import processing.serial.*;
import processing.net.*;
import cc.arduino.*;

// Options 
final static boolean SERVER_SERVICE_OPEN = true;
final static int SERVER_PORT = 9527;

final static int WINDOW_WIDTH = 600;
final static int WINDOW_HEIGHT = 400;

Arduino arduino;
Server myServer;
PImage logo;
PFont titleFont;
PFont type1HeaderFont;

final static int[] speedRectParams = {50, 200, 220, 140, 10, 10, 10, 10};
final static int[] patternRectParams = {320, 200, 220, 140, 10, 10, 10, 10};
final static int[] speedRectColor = {250, 166, 0};
final static int[] patternRectColor = {9, 255, 132};
final static int[] speedList = {80, 100, 120, 140, 150, 160, 180, 260};

/* 
	Format: 
		1 digit - [Beats Num] (2 for 4 beats, 3 for 8 beats, 4 for 16 beats...)
		3 digit - [Speed]	  (ex. 120, 180...)
		N digit - [tone]	  (0 for nothing, 1 for bass drum, 2 for snare, 4 for hihat)
*/
final static String[] patternList = {"4 Beats - Typical", "8 Beats - Folk Rock", "8 Beats - Typical", "16 beats - Typical", "Sad Guy", "Stop"};
final static String[] rhythmList = {"21212", "314214121", "314241124", "41444244414142444", 
									"440004000400040005040605050406050505060524050602250406050504060505050606042502222504060505040605050506052405060225040605050406050505060604250202050005000500050005040104010401040104010401040104010401040104010401040104012403240504010401040104010401040104010401040104010401040100000000010221050401040104010401040104010401040104010401040104010401040104032405040104010401040104010401240104010401040104010405022400022222240504030401040304010403040124030401040304010403040104030401240302250403040104030401040304012403040104030401040304010601242501060605040304010403040104030401240304050403040104030401040304250303030504030401040304010403040124030405040304010403040106032405030302250401040104010401040104010401040504010401040302250403040104030405022300030223022504030401040304010403040124030441040304010403040104030401240304250403040104030401040304012403040104030401040304010223020124030225240704012403040124030401240302252403040104030401060124200303030500070001040304010601242503030305000500050005000104030425030303050007000104030401040304012403040104030401040304010601240302220107000700070007000700070007000700070007000700070007000700070007020700070007000700070007000700070007000000000000000504060505040605050506052405060225040605050406050505060604250222250406050504060505050605240506022504060505040605010201120201140600000000000005000",
									"4400040004000400010002020401020101000202040102010100020101000201010200020001020001000202040102010100020204010201010002010100020101020002000102010504060504050604050406050405060405040605040506040504060504050604050406050405060405040605040506040504060504050604050406050502222225040605040506040504060504050604050406050405060405040605040506040504060504050604050406050405060405040605040506040504060505022222250406050405060405040605040506040504060504050604050406050405060405040605040506040504060505050605060106010601060106010601060000040100020204010201010002020401020101000201010002010102000200010200010002020401020101000202040102010100020101000201010200020001020105040704050407040504070405040704050407040504070404000400040004000504060504050604050406050405060405040605040506040504060504050604050406050405060405040605040506040504060504050604050406050502222225040605040506040504060504050604050406050405060405040605040506040504060504050604050406050405060402010201020102010200040004000400010002000001020001000200000102000100020100010201010200020001020005040704050407040504070405040704050407040504070405020002000102000100020204010201010002020401020101000201010002010102000200010200010002020401020101000202040102010100020101000201010200020001020101000201010002010102000200010201010002010100020101020002000000000"};

// [R, G, B, Alpha, Size]
final static int[] tyep1HeaderParams = {255, 255, 255, 150, 16};
final static int[] tyep2HeaderParams = {255, 255, 255, 255, 26};
final static float type1FineTuneRatio = 0.5;
final static float type2FineTuneRatio = 0.5;

// Logo: [x, y, w, h]
final static int[] logoParams = {380, 15, 120, 160, 255, 255, 255};
// Title: [R, G, B, Size, x, y]
final static int[] titleParams = {189, 142, 24, 58, 270, 150};

void setup() {
	initScene();
	initGlobalVariables();

	try {
		println("There are " + Arduino.list().length + " arduino.");
		for (int i=0; i<Arduino.list().length; i++)
			println(Arduino.list()[i].toString());
		arduino = new Arduino(this, Arduino.list()[0], 57600);
		arduinoSetup();
	} catch (Exception ex) {
		if (arduino == null)
			println("Arduino is not ready... Turn out all arduino functions.");
	}
}

void initScene() {
	size(WINDOW_WIDTH, WINDOW_HEIGHT);

	logo = loadImage("Res/Logo.png");
	logo.resize(logoParams[2], logoParams[3]);

	titleFont = loadFont("Res/VladimirScript-48.vlw");
	type1HeaderFont = loadFont("Res/type1Header.vlw");
}

void initGlobalVariables() {
	mouseTraceBegin = new Coord();
	mouseTraceEnd = new Coord();

	if (SERVER_SERVICE_OPEN) {
		myServer = new Server(this, SERVER_PORT); 
		if (myServer != null)
			println("Server is listening");
	}
}

void draw() {
	drawBackground();
	drawCurrentOptions();

	if (SERVER_SERVICE_OPEN)
		checkClientMsg();

  	if (arduino != null)
		arduinoLoop();
}

void drawBackground() {
	background(255);
	noStroke();

	// Draw Logo
	image(logo, logoParams[0], logoParams[1]);
	textAlign(CENTER);
	textFont(titleFont, titleParams[3]);
    fill(titleParams[0], titleParams[1], titleParams[2]);
    text("Cajon Master", titleParams[4], titleParams[5]);

	// Draw speed rectangle
	fill(speedRectColor[0], speedRectColor[1], speedRectColor[2]);
	rect(speedRectParams[0], speedRectParams[1], speedRectParams[2], speedRectParams[3], speedRectParams[4], speedRectParams[5], speedRectParams[6], speedRectParams[7]);

	// Draw pattern rectangle
	fill(patternRectColor[0], patternRectColor[1], patternRectColor[2]);
	rect(patternRectParams[0], patternRectParams[1], patternRectParams[2], patternRectParams[3], patternRectParams[4], patternRectParams[5], patternRectParams[6], patternRectParams[7]);
}

void drawCurrentOptions() {
	textFont(type1HeaderFont, tyep1HeaderParams[4]);
	textAlign(CENTER);
    fill(tyep1HeaderParams[0], tyep1HeaderParams[1], tyep1HeaderParams[2], tyep1HeaderParams[3]);

    // Show upper and lower speed options
    text(speedList[ (curSpeedIdx + speedList.length - 1) % speedList.length ], speedRectParams[0] + speedRectParams[2] * type1FineTuneRatio, speedRectParams[1] + tyep1HeaderParams[4]);
    text(speedList[ (curSpeedIdx + 1) % speedList.length ], speedRectParams[0] + speedRectParams[2] * type1FineTuneRatio, speedRectParams[1] + speedRectParams[3] - tyep1HeaderParams[4]);

    // Show upper and lower pattern options
    text(patternList[ (curPatternIdx + patternList.length - 1) % patternList.length ], patternRectParams[0] + patternRectParams[2] * type1FineTuneRatio, patternRectParams[1] + tyep1HeaderParams[4]);
    text(patternList[ (curPatternIdx + 1) % patternList.length ], patternRectParams[0] + patternRectParams[2] * type1FineTuneRatio, patternRectParams[1] + patternRectParams[3] - tyep1HeaderParams[4]);

    // Show current speed
    textFont(type1HeaderFont, tyep2HeaderParams[4]);
    textAlign(CENTER);
    fill(tyep2HeaderParams[0], tyep2HeaderParams[1], tyep2HeaderParams[2], tyep2HeaderParams[3]);

    text(speedList[curSpeedIdx], speedRectParams[0] + speedRectParams[2] * type2FineTuneRatio, speedRectParams[1] + speedRectParams[3] * type2FineTuneRatio);
    text(patternList[curPatternIdx], patternRectParams[0] + patternRectParams[2] * type2FineTuneRatio, patternRectParams[1] + patternRectParams[3] * type2FineTuneRatio);
}


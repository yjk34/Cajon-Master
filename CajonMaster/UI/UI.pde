import processing.serial.*;
import cc.arduino.*;

Arduino arduino;
PImage logo;
PFont titleFont;

final static int windowW = 600;
final static int windowH = 400;

final static int[] speedRectParams = {50, 200, 220, 140, 10, 10, 10, 10};
final static int[] patternRectParams = {320, 200, 220, 140, 10, 10, 10, 10};
final static int[] speedRectColor = {250, 166, 0};
final static int[] patternRectColor = {9, 255, 132};
final static int[] speedList = {80, 100, 120, 140, 160, 180};
final static String[] patternList = {"4 Beats - Typical", "8 Beats - Folk Rock", "8 Beats - Typical", "16 beats - Typical"};

// [R, G, B, Alpha, Size]
final static int[] tyep1HeaderParams = {255, 255, 255, 150, 20};
final static int[] tyep2HeaderParams = {255, 255, 255, 255, 30};
final static float type1FineTuneRatio = 0.5;
final static float type2FineTuneRatio = 0.5;

// Logo: [x, y, w, h]
final static int[] logoParams = {380, 15, 120, 160, 255, 255, 255};
// Title: [R, G, B, Size, x, y]
final static int[] titleParams = {189, 142, 24, 58, 270, 150};

void setup() {
	initScene();
	initGlobalVariables();

	arduino = new Arduino(this, Arduino.list()[0], 57600);
	arduinoSetup();
}

void initScene() {
	size(windowW, windowH);

	logo = loadImage("Res/Logo.png");
	logo.resize(logoParams[2], logoParams[3]);

	titleFont = loadFont("Res/VladimirScript-48.vlw");
}

void initGlobalVariables() {
	mouseTraceBegin = new Coord();
	mouseTraceEnd = new Coord();
}

void draw() {
	drawBackground();
	drawCurrentOptions();

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
	textSize(tyep1HeaderParams[4]);
	textAlign(CENTER);
    fill(tyep1HeaderParams[0], tyep1HeaderParams[1], tyep1HeaderParams[2], tyep1HeaderParams[3]);

    // Show upper and lower speed options
    text(speedList[ (curSpeedIdx + speedList.length - 1) % speedList.length ], speedRectParams[0] + speedRectParams[2] * type1FineTuneRatio, speedRectParams[1] + tyep1HeaderParams[4]);
    text(speedList[ (curSpeedIdx + 1) % speedList.length ], speedRectParams[0] + speedRectParams[2] * type1FineTuneRatio, speedRectParams[1] + speedRectParams[3] - tyep1HeaderParams[4]);

    // Show upper and lower pattern options
    text(patternList[ (curPatternIdx + patternList.length - 1) % patternList.length ], patternRectParams[0] + patternRectParams[2] * type1FineTuneRatio, patternRectParams[1] + tyep1HeaderParams[4]);
    text(patternList[ (curPatternIdx + 1) % patternList.length ], patternRectParams[0] + patternRectParams[2] * type1FineTuneRatio, patternRectParams[1] + patternRectParams[3] - tyep1HeaderParams[4]);

    // Show current speed
    textSize(tyep2HeaderParams[4]);
    textAlign(CENTER);
    fill(tyep2HeaderParams[0], tyep2HeaderParams[1], tyep2HeaderParams[2], tyep2HeaderParams[3]);

    text(speedList[curSpeedIdx], speedRectParams[0] + speedRectParams[2] * type2FineTuneRatio, speedRectParams[1] + speedRectParams[3] * type2FineTuneRatio);
    text(patternList[curPatternIdx], patternRectParams[0] + patternRectParams[2] * type2FineTuneRatio, patternRectParams[1] + patternRectParams[3] * type2FineTuneRatio);
}


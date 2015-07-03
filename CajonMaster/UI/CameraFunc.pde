import java.awt.image.BufferedImage;
import processing.video.*;
import jp.nyatla.nyar4psg.*;

static MultiMarker nya;
static Capture cam;
static boolean isCameraOK = false;
static Vector<CCPoint> pntsList;

final static double TEMPLTATE_SCORE_THRESH = 0.1;

void initCamera() {
  String[] cameras = Capture.list();
  pntsList = new Vector<CCPoint>();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) 
      println(cameras[i]);
    
    cam = new Capture(this, WINDOW_WIDTH, WINDOW_HEIGHT);

    nya = new MultiMarker(this, WINDOW_WIDTH, WINDOW_HEIGHT , "camera_para.dat", NyAR4PsgConfig.CONFIG_PSG);
    nya.addARMarker("patt.hiro", 80);

    cam.start();     
    isCameraOK = true;
  }
}

void updateCam() {
  if (isCameraOK) {
    if (cam.available() == true) {
      cam.read();
      nya.detect(cam);

      nya.drawBackground(cam);
      if((!nya.isExistMarker(0))){
        return;
      }
      PVector[] markers = nya.getMarkerVertex2D(0);

      if (isGestureListen) {
        float tx = 0;
        float ty = 0;
        for (int i=0; i<markers.length; i++) {
          tx += markers[i].x / markers.length;
          ty += markers[i].y / markers.length;
        }
        pntsList.add(new CCPoint(tx, ty));
      }
    }
  }
}
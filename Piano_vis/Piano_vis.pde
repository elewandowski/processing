import oscP5.*;
import netP5.*;

OscP5 oscP5;
Keys keys;
int cc [] = new int[9];
int STROKE_WEIGHT = 3;
int COLOR_SCHEME = 3;


void setup() {
  size(512, 512);
  frameRate(25);
  colorMode(HSB, 360, 100, 100); 
  
  float hey, kfg, irgm = 0;
  keys = new Keys();
  oscP5 = new OscP5(this, 12000);
  oscP5.plug(this, "keyData", "/keys"); //connect OSC messages with the addressPattern "/keys" to the parseOSCKeyData() method in our Processing sketch
  oscP5.plug(this, "cc", "/cc");
  oscP5.plug(this, "pedalData", "/pedal");
}

void draw() {
  background(215);
  strokeWeight(1);
  
  int verticalSpacing = height / keys.size;
  
  for (int pitch=0; pitch<keys.size; pitch++) {
    int velocity = keys.getVel(pitch);
    color col = colorScheme(pitch, velocity, keys.BASS_NOTE);
    stroke(col);
    strokeWeight(velocity * STROKE_WEIGHT * 0.5);
    //float velTriggeredAngle = (velocity / 127) * 50;
    line(0, pitch * verticalSpacing, width, pitch * verticalSpacing);
  }
}

void keyData(int pitch, int velocity) {
  keys.setVel(pitch, velocity);
}

void pedalData(int state) {
  keys.setPedal(boolean(state));
}

void cc(int i, int cc_val) {
  println("new cc " + i + " value: " + cc_val);
  cc[i] = cc_val;
}



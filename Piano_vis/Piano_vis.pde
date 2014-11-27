import oscP5.*;
import netP5.*;

OscP5 oscP5;
Keys keys;
int cc [] = new int[9];
int STROKE_WEIGHT = 3;  

void setup() {
  size(512, 512);
  frameRate(25);
  
  keys = new Keys();
  oscP5 = new OscP5(this, 12000);
  oscP5.plug(this, "parseOSCKeyData", "/keys"); //connect OSC messages with the addressPattern "/key_pitch" to the keyPitch() method in our Processing sketch
  oscP5.plug(this, "cc", "/cc");
  oscP5.plug(this, "pedal", "/pedal");
}

void draw() {
  background(215);
  strokeWeight(1);
  
  int verticalSpacing = height / keys.size;
  
  for (int pitch=0; pitch<keys.size; pitch++) {
    int velocity = keys.getVel(pitch);
    color col = colorScheme(pitch, velocity, keys.BASS_NOTE);
    stroke(col);
    strokeWeight(velocity * STROKE_WEIGHT);
    //float velTriggeredAngle = (velocity / 127) * 50;
    line(0, pitch * verticalSpacing, width, pitch * verticalSpacing);
  }
}

color colorScheme(int pit, int vel, int bassNote){
  //color returnColor;
  //int red, green, blue = 0;
  
  float hue = map(pit, 0, 120, 0, 765);
  float brightness = map(vel, 0, 127, 0, 255);
  float red = hue % 255;
  float grn = hue - 255 % 510;
  float blu = hue - 510 % 765;
  //float bassCol = bassNote % 12 * 21.25; // which key is the bass note on playing?
  //returnColor = color(red, grn, blu);
  
  return color(red, grn, blu);
}

void parseOSCKeyData(int pitch, int velocity) {
  keys.setVel(pitch, velocity);
}

void cc(int i, int cc_val) {
  println("new cc " + i + " value: " + cc_val);
  cc[i] = cc_val;
}

void pedal(int state) {
  keys.setPedal(boolean(state));
}

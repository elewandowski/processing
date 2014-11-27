import oscP5.*;
import netP5.*;

OscP5 oscP5;
Keys keys;
int cc [] = new int[9];

void setup() {
  size(512, 512);
  frameRate(25);
  
  keys = new Keys();
  oscP5 = new OscP5(this, 12000);
  oscP5.plug(this, "parseOSCKeyData", "/keys"); //connect OSC messages with the addressPattern "/key_pitch" to the keyPitch() method in our Processing sketch
  oscP5.plug(this, "cc", "/cc");
  oscP5.plug(this, "pedal", "/pedal");
  //noStroke();
}

void draw() {
  background(215);
  strokeWeight(1);
  
  int verticalSpacing = height / keys.size;
  
  for (int pitch=0; pitch<keys.size; pitch++) {
    int velocity = keys.getVel(pitch);
    //if (pitch % 12 == 0) println ("the vel is " + velocity);
    color col = colorScheme(pitch, velocity, keys.BASS_NOTE);
    stroke(col);
    strokeWeight(velocity * 3);
    //float velTriggeredAngle = (keysP[i] / 127) * 50;
    line(0, pitch * verticalSpacing, width, pitch * verticalSpacing);
  }
}

color colorScheme(int pit, int vel, int bassNote){
  color returnColor;
  
  float bassCol = bassNote % 12 * 21.25; // which key is the bass note on playing?
  returnColor = color(bassCol, vel, vel);
  
  return returnColor;
}

void parseOSCKeyData(int pitch, int velocity) {
  keys.setVel(pitch, velocity);
  //println("lastPlayedKey = " + lastPlayedKey);
  //println("i'm in in your kepitch method " + i + " " + v); 
}

void cc(int i, int cc_val) {
  cc[i] = cc_val;
}

void pedal(int state) {
  //println("the pedal state is " + state);
  keys.setPedal(boolean(state));
}

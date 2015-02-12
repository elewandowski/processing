import processing.video.*;

Capture cam;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
PImage img;
int imgNum;
int imgSize;
int rowNum;
float yTrans;
int numOfRows;
boolean savingFrame, drawCircles, slowFade;
String saveVideoFolder;

void setup() {
  size(1024, 768);
  saveVideoFolder = generateVideoFolderName();
  prepareImage(nextImgString());
  numOfRows = 4;
  slowFade = false;
  frameRate(30);

  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  cam = new Capture(this, Capture.list()[0]);
  cam.start();

  img = cam;
  img.loadPixels();
}

void draw() {
  background(200);
  // int [] cArrayPixels = colArray2intArray(img.pixels);
  if (cam.available() == true) {
    cam.read();
    prepareImage(cam);
  }

  if (img.height > 0) {
    int [] cArrayPixels = colArray2intArray(img.pixels);
    yTrans = -127;
    rowNum = 0;

    for (int i=0; i<numOfRows; i++) {
      int rowStart = ((rowNum + i*mouseX) * img.width) % imgSize;
      int[] row = subset(cArrayPixels, rowStart, img.width);

      if (drawCircles) drawCircSignal(row); 
      else drawLineSignal(row, height/numOfRows*i);
      
      if(slowFade) yTrans += 1 + ((float)mouseX/width)*8;
      
      OscMessage msg = new OscMessage("/av"+i);
      msg.add(getAverages(row));
      oscP5.send(msg, myRemoteLocation);
    }
    rowNum = (rowNum + 1) % img.height;
    if (savingFrame) saveFrame("video/" + saveVideoFolder + "/screen-#####.png");
  }
}

float[] getAverages(int[] row) {
  int seg = 4;
  float[] out = new float[seg];
  float sum = 0;
  int div = row.length / seg;
  //println("div: "+div);
  for (int i=0; i<row.length; i++) {
    sum += row[i];
    if(i % div == div - 1) {
      out[i / div] = sum / div / 255;
      sum = 0;
    }
  }
  return out;
}

void drawCircSignal(int[] row) {
  float theta = 0;
  float thetaInc = TWO_PI / row.length;
  float radius = 500;

  pushMatrix();
  translate(width/2, height/2);
  for (int i=0; i<row.length-1; i++) {      
    float tempR = (float) row[i] / 255;
    float tempR2 = (float) row[i+1] / 255;
    stroke(row[i]);
    line(cos(theta) * (tempR * radius), sin(theta) * (tempR * radius), 
          cos(theta + thetaInc) * (tempR2 * radius), sin(theta + thetaInc) * (tempR2 * radius));
    theta += thetaInc;
  }
  popMatrix();
}

void drawLineSignal(int[] row, int yTrans) {
  float xSpacing = (float)width/row.length;
  float ySpacing = 1; // (float)mouseY/height;

  pushMatrix();
  translate(0, yTrans);
  for (int i=0; i<row.length-1; i++) {
    stroke(row[i]);
    line(i * xSpacing, row[i], (i+1) * xSpacing, row[i+1] * ySpacing);
  }
  popMatrix();
}

int [] colArray2intArray(color[] cArray) {
  int [] intArray = new int[cArray.length];
  for (int i=0; i<cArray.length; i++) {
    intArray[i] = (int) green(cArray[i]);
  }
  return intArray;
}

void mousePressed() {
  if (mouseButton == LEFT) saveFrame("img/screen-######.png");
  else if (mouseButton == RIGHT) {
    String s = nextImgString();
    prepareImage(s);
  }
}

void keyPressed() {
  if (key == ' ') {
    //savingFrame = true;
    drawCircles = !drawCircles;
  }
}

void keyReleased() {
  if (key == ' ') {
    //savingFrame = false;
    saveVideoFolder = generateVideoFolderName();
  }
}

void prepareImage(String s) {
  img = loadImage(s);
  img.loadPixels();
  imgSize = img.height * img.width;
  rowNum = 0;
}

void prepareImage(Capture c) {
  img = c;
  img.loadPixels();
  imgSize = img.height * img.width;
  //rowNum = 0;
}

String generateVideoFolderName() {
  return year() + "-" + month() + "-" + day() +" "+ hour() +"_"+ minute() +"_"+ second() +" video";
}

String nextImgString() {
  imgNum = (imgNum + 1) % 8;
  String s = "img" + imgNum + ".jpg"; 
  return s;
}


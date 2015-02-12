import processing.video.*;

Capture cam;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
PImage img;
int imgNum;
int imgSize;
int rowNum;
float yTrans;
int numOfRows;
boolean savingFrame;
String saveVideoFolder;

void setup(){
  size(1024, 768);
  saveVideoFolder = generateVideoFolderName();
  prepareImage(nextImgString());
  numOfRows = 4;
  frameRate(30);
  
  String [] cameras = Capture.list();
  
  // for(int i=0; i<cameras.length; i++) println(cameras[i] + " "+ i);
  cam = new Capture(this, cameras[19]);
  cam.start();
  
  img = cam;
  img.loadPixels();
  
  println(img.height +" "+ img.width);
}

void draw(){
  background(200);
  // int [] cArrayPixels = colArray2intArray(img.pixels);
   if (cam.available() == true) {
    cam.read();
    prepareImage(cam);
  }
  
  if (img.height > 0) {
    int [] cArrayPixels = colArray2intArray(img.pixels);
    
    yTrans = -127;
    
  //   println("rowNum: " + rowNum 
  //           + " img.width: " + img.width 
  //           + " imgSize: " + imgSize);
  
    for(int i=0; i<numOfRows; i++) {
      int rowStart = ((rowNum + i*mouseX) * img.width) % imgSize;
      int[] row = subset(cArrayPixels, rowStart, img.width);
      // pushMatrix();
      // translate(0, height/numOfRows*i);
      drawSignal(row);
      // popMatrix();
      //yTrans += 1 + ((float)mouseX/width)*8;
    }
    rowNum = (rowNum + 1) % img.height;
    if(savingFrame) saveFrame("video/" + saveVideoFolder + "/screen-#####.png");
  }
}

void drawSignal(int[] row) {
  float xSpacing = (float)width/row.length;
  float ySpacing = (float)mouseY/height;
  
  float theta = 0;
  float thetaInc = TWO_PI / row.length;
  float radius = 0;
  
  noStroke();
  
  pushMatrix();
  translate(width/2, height/2);
  for(int i=0; i<row.length-1; i++){
    
    fill(row[i]);
    
    rect(cos(theta) * row[i], sin(theta) * row[i], 10, 10);
    
    //line(i * xSpacing, row[i], (i+1) * xSpacing, row[i+1] * ySpacing);
    
    theta += thetaInc;
  }
  popMatrix();
}

int [] colArray2intArray(color[] cArray){
  int [] intArray = new int[cArray.length];
  for(int i=0; i<cArray.length; i++) {
    intArray[i] = (int) green(cArray[i]);
  }
  return intArray;
}

void mousePressed(){
  if(mouseButton == LEFT) saveFrame("img/screen-######.png");
  else if(mouseButton == RIGHT) {
    String s = nextImgString();
    prepareImage(s);
  } 
}

void keyPressed(){
  if(key == ' ') {
    savingFrame = true;
  }
}

void keyReleased(){
  if(key == ' ') {
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

String generateVideoFolderName(){
  return year() + "-" + month() + "-" + day() +" "+ hour() +"_"+ minute() +"_"+ second() +" video";
}

String nextImgString(){
  imgNum = (imgNum + 1) % 8;
  String s = "img" + imgNum + ".jpg"; 
  return s;
}

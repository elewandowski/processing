PImage img;
int imgNum;
int imgSize;
float yTrans;

void setup(){
  size(1024, 768);
  imgNum = 6;
  img = loadImage(nextImgString());
  img.loadPixels();
  imgSize = img.height * img.width;
  
}

void draw(){
  background(200);
  int [] cArrayPixels = colArray2intArray(img.pixels);
  
  yTrans = -127;
  
  for(int i=0; i<imgSize; i+=img.width){
    int[] row = subset(cArrayPixels, i, img.width);
    pushMatrix();
    translate(0, yTrans);
    
    drawSignal(row);
    popMatrix();
    yTrans += 1 + ((float)mouseX/width)*8;
  }
}

void drawSignal(int[] row) {
  float seperation = (float)width/row.length;
  for(int i=0; i<row.length-1; i++){
    stroke(row[i]);
    line(i*seperation, row[i], (i+1)*seperation, row[i+1]);
  }
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
    println(s);
    img = loadImage(s);
    img.loadPixels();
    imgSize = img.height * img.width;
  } 
}

String nextImgString(){
  imgNum = (imgNum + 1) % 8;
  String s = "img" + imgNum + ".jpg"; 
  return s;
}

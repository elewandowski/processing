class ThreeDGrid {

  int w, h; 
  float xCor, yCor;
  float noiseVal;

  ThreeDGrid(int w, int h) {
    this.w = w;
    this.h = h;
  }

  void update(int _x, int _y) {
    if(frameCount % 2 == 0){
      xCor -= (_x-width/2)/256;
      yCor -= (_y-height/2)/256;
    }
//    xCor -= dist(_x, _y, width/2, height/2)/4;
//    yCor -= dist(_x, _y, width/2, height/2)/4;
//    if(frameCount % 60 == 0 ) println(((_x-width/2)/256) +" "+ ((_y-height/2)/256));

//    noiseVal+=0.025;
//    xCor -= noise(noiseVal);
//    yCor -= noise(noiseVal);

    if (xCor > w/2) xCor = w/2;
    else if (xCor < 0) xCor = 0;
    if (yCor > h/2) yCor = h/2;
    else if (yCor < 0) yCor = 0;
  }

  void display() {

    strokeWeight(0.5);
//   pushMatrix();
    translate(xCor, yCor);
//    if(frameCount%60==0) println(xCor +" "+ yCor);
    //the for loops have to have the same denominator so they match up
    for (int i=-width*2; i<width*3+1; i+=w) {
      for (int j=-width*4; j<height*3+1; j+=h) {
        
        stroke(60);
//        float r = random(20);
        
        //x lines
//        if(int(random(200)) == 0){
//        line(-width*2+r, j+r, -i+r, width*3+r, j+r, -i+r);
//        }
//        else{
//        
        line(-width*2, j, -i, width*3, j, -i);
//        }

        //y lines
//        if(int(random(200)) == 0){
//        line(i, -height*2+r, -j+r, i+r, height*3+r, -j+r);
//        }
//        else{
        line(i, -height*2, -j, i, height*3, -j);
//        }

        //z lines
//        if(int(random(200)) == 0){
//        line(i+r, j+r, width*2+r, i+r, j+r, -width*3+r);
//        }
//        else{
        line(i, j, width*2, i, j, -width*3);
//        }
      }
    }
//  popMatrix();
  }
}


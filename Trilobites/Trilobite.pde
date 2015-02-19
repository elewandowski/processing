class Trilobite {
  
  PVector location = new PVector();
  float bodySize;
  color skinColor;
  Head head;
  Spine spine;
  Arms arms;
  
  Trilobite(PVector location, float size) {
    this.location = location;
    this.bodySize = size;
    skinColor = color(random(200, 255), random(100, 120), random(40, 80));
    head = new Head();
    spine = new Spine();
    arms = new Arms(10, (int)bodySize, (int)bodySize);
  }
  
  class Head {
    
    float headSize;
    
    Head(){
      headSize = bodySize;
    }
    
    void paint(){
      noStroke();
      fill(skinColor);
      bezier(location.x - headSize,
             location.y,
                location.x - headSize,
                location.y + headSize,
              location.x + headSize,
              location.y + headSize,
                location.x + headSize,
                location.y);
    }
    
    class Antenna {
      
    }
  }
  
  class Spine {
    
    float spineSize;
    
    Spine(){
      spineSize = bodySize * 4;
    }
    
    void paint(){
      stroke(skinColor-10);
//      fill(skinColor);
      strokeWeight(spineSize/4);
      line(location.x, 
            location.y,
            location.x,
            location.y - spineSize);
    }
  }
  class Arms {
    
    Arm[] arms;
    int numOfArms, length1, length2, spacing;
    
    Arms(int numOfArms, int length1, int length2) {
      this.numOfArms = numOfArms;
      this.length1 = length1;
      this.length2 = length2;
      arms = new Arm[numOfArms];
      spacing = 20;
      for(int i=0; i<arms.length; i++){
        int verSide = (i % 2 == 0) ? 1 : -1;
        PVector start1 =  new PVector(location.x, location.y-(i*spacing));
        PVector end1 =  new PVector(location.x + (verSide*length1), location.y-(i*spacing));
        PVector start2 =  new PVector(end1.x, end1.y);
        PVector end2 =  new PVector(end1.x + (verSide*length2), end1.y + 20);
        arms[i] = new Arm(start1, end1, random(8, 10), start2, end2, random(6, 8));
      }
    }
    
    void paint() {
      for(Arm arm: arms) {
        arm.paint();
      }
    }
    
    class Arm {
      
      PVector start1, end1, start2, end2;
      float size1, size2;
      
      Arm(PVector start1, PVector end1, float size1, PVector start2, PVector end2, float size2){
        this.start1 = start1;
        this.end1 = end1;
        this.start2 = start2;
        this.end2 = end2;
        this.size1 = size1;
        this.size2 = size2;
      }
      
      void paint(){
        stroke(skinColor-10);
  //      fill(skinColor);
        strokeWeight(size1);
        line(start1.x, start1.y, end1.x, end1.y);
        strokeWeight(size2);
        line(start2.x, start2.y, end2.x, end2.y);
      }
    }
  }
  void paint() {
    spine.paint();
    head.paint();
    arms.paint();
  }
}

Trilobite t;
int prevSec, refreshRate;

void setup(){
  size(800, 600);
  t = new Trilobite(new PVector(width/2, height/2), 300);
  prevSec = 0;
  refreshRate = 100;
}

void draw(){
  background(200);
  if ((millis() / refreshRate) > prevSec) {
    t = new Trilobite(new PVector(width/2, height/2), random(150, 200));
    prevSec = millis() / refreshRate;
  }
  t.paint();
}

void mouseClicked() {
  t = new Trilobite(new PVector(width/2, height/2), (float)mouseX/width * 4);
}

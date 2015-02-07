class Boid {

  int thisBoid, audioType, visualType, colR, colG, colB, colHold, explodeHold, delayCount, nextPosition, colHoldFrames, explodeHoldFrames, wtIndex, wtIndexMod, modFreq, lastClockCount;
  float x, y, xA, yA, accelerationX, accelerationY, size, freq, pan, out, wtOut, mouseDist, zNorm, distance, rotX, rotY, rotZ, scrnX, scrnY, controlDepth, prevz, addingInterpolate, t, dOut, prevPan, weight;
  boolean isOn, collision, explode;
  //  int wTType = (int) random(6);

  float [] stereoOut;
  float [] control = new float[mMR.mapArray.length];
  int [] segmentCount = new int[control.length];
  int [] segmentDist = new int[control.length];
  float [] segmentDiff = new float[control.length];

  float z, volume, pitchCentre, envelopeTime, filterCutOff, delayTime, delayFeedback, reverbMix, reverbFeedback, distortion;
  float colour;
  int filterType;

  Shard s;
  Envelope e;
  Delay d;
  Filter f;
  Filter freqFilter, panFilter, volFilter, delayTimeFilter;
  Filter[] controlFilters = new Filter[control.length];
  //  WaveTable wT;

  Boid (float x, float y, int size, int thisBoid, int type) {

    this.x = x;
    this.y = y;
    this.size = size;
    this.thisBoid = thisBoid;
    visualType = audioType = type;

    s = new Shard(x, y, size, size);
    xA = random(-1, 1);
    yA = random(-1, 1);
    freq = 0;
    delayFeedback = 0.66;
    distortion = 1;
    weight = random(0.8, 1);
    reverbMix = 0.5f;
    collision = explode = false;
    isOn = true;
    rotX = TWO_PI * random(1);
    rotY = TWO_PI * random(1);
    rotZ = TWO_PI * random(1);
    pitchCentre = 220;
    //    freq =  20 + pow( (float)y/height, sqrt(height*0.01) ) * 200;

    stereoOut = new float [2];
    e = new Envelope (1, 20, 1, 400);
    freqFilter = new Filter(0.35);
    volFilter = new Filter(0.01);
    panFilter = new Filter(0.01);
    delayTimeFilter = new Filter(0.01);
    f = new Filter(1);
    d = new Delay(44100, (int)random(200, 22100), delayFeedback);
    d.setMix(0);
  }

  public void update() {
    
    scrnX = screenX(x,y,z);
    scrnY = screenY(x,y,z);
    
    if(scrnX > 0 && scrnX < width && scrnY > 0 && scrnY < height){
      xA *= friction;
      yA *= friction;
    }
    else{
      xA += 0.01 * weight;
      yA += 0.01 * weight;
    }

    for (int i=0; i <=boidDisplayNumClicker.val; i++) {
      if (i!=thisBoid) {
        distance = dist(boidArray[i].x, boidArray[i].y, x, y);
        //
        if (distance < size/2) {
//          if(collision && boidArray[i].collision) e.queue();
//          else e.trigger();
          e.queue();
          stroke(255);
          line(boidArray[i].x, boidArray[i].y, boidArray[i].z, x, y, z);
////          
//          xA *= -1;
//          yA *= -1;
//          
//          if (xA > 0.2 && yA > 0.2) {
//            
//          }
//          else {
//            collision = true;
//          }
        }
        //        else collision = false;
      }
    }

    //    if(frameCount % 60 ==0 )println(collision +" "+ thisBoid +" "+ millis());
    if (!collision) {
      x += xA;
      y += yA;
    }

    if (x >= boidControlSpace[2]) x = boidControlSpace[0]+1;
    else if (x <= boidControlSpace[0]) x = boidControlSpace[2]-1;
    if (y >= boidControlSpace[3]) y = boidControlSpace[1]+1;
    else if (y <= boidControlSpace[1]) y = boidControlSpace[3]-1;

    s.update(x, y);
    newFreq();

    //only do interpolation once every new mcClockCount
    for (int i=0; i<mMR.mapArray.length; i++) {
      if (mMR.mapArray[i].positions[thisBoid][segmentCount[i]] != null) {
        interpolate(i);
        sendAudioMapping(mMR.mapArray[i].mappingAudio, control[i]);
        sendVisualMapping(mMR.mapArray[i].mappingVisual, control[i]);
      }
    }
    //    f.setCutOff((float)mouseX/width);
  }

  public void display() {
    stroke(255*colour+35, colG*colour+35, colB*colour+35);
    fill(255*colour+35, colG*colour+35, colB*colour+35);
    pushMatrix();
    translate(0, 0, z);
    s.display(visualType);
    popMatrix();
  }

  void mousePressed() {
    //    if(!prevMousePressed){
    //      prevMX = thisMX = mouseX;
    //      prevMY = thisMY = mouseY;
    //    }
  }

  void mouseDragged() {
    if (thisMX != prevMX && thisMY != prevMY) {
      mouseDist = dist(thisMX, thisMY, screenX(x + grid.xCor, y, z), screenY(x, y + grid.yCor, z));
      //      if (thisMX - x < size/32 && thisMY - y < size/32/500) explode = true;
      //      else explode = false;
    }
    else mouseDist = 0;

    if (mouseDist != 0 && mouseDist < size/8) {
      accelerationX = ( (thisMX-prevMX) / (size/8) ) * force;
      accelerationY = ( (thisMY-prevMY) / (size/8) ) * force;
      xA += accelerationX * weight;
      yA += accelerationY * weight;
    }
  }

  public void interpolate(int i) {

    if (clockCount != this.lastClockCount) {
      //      println("keBlac " + thisBoid +" "+ clockCount +" "+ this.lastClockCount +" "+ segmentCount[i] +" "+ mMR.mapArray[i].positions[thisBoid][segmentCount[i]].segment +" "+ mMR.mapArray[i].positions[thisBoid][segmentCount[i]].val);
      if (mMR.mapArray[i].positions[thisBoid][segmentCount[i]].segment < clockCount && mMR.mapArray[i].positions[thisBoid][segmentCount[i]+1] != null) {
        segmentDiff[i] = mMR.mapArray[i].positions[thisBoid][segmentCount[i]+1].val - mMR.mapArray[i].positions[thisBoid][segmentCount[i]].val;
        segmentDist[i] = mMR.mapArray[i].positions[thisBoid][segmentCount[i]+1].segment - mMR.mapArray[i].positions[thisBoid][segmentCount[i]].segment;
        segmentCount[i]++;
      }

      if (i == mMR.mapArray.length-1) this.lastClockCount = clockCount;
    }

    control[i] = mMR.mapArray[i].positions[thisBoid][segmentCount[i]].val;

    //    control[i] += segmentDiff[i] / segmentDist[i];
  }

  public void resetCount() {
    for (int i=0; i<segmentCount.length; i++) segmentCount[i] = 0;
  }

  public void newFreq() {
    //    if (freq < 20 + pow( (float)y/height, sqrt(height*0.01) ) * 2000) freq+= 2;
    //    else if (freq > 20 + pow( (float)y/height, sqrt(height*0.01) ) * 2000) freq-= 2;
    //    if (freq < 0) freq = 0;
    freq = freqFilter.loPass((1-(y/height)));
  }

  public float[] wtOutStereo() {
    if (isOn) {
//      if(frameCount % 60 == 0 )println(t +" "+ thisBoid +" "+ dOut);

      out = d.delay(e.env(wtOut()));
      pan = panFilter.loPass((float)x/boidControlSpace[2]);
      stereoOut[0] = out * sqrt(1-pan);
      stereoOut[1] = out * sqrt(pan);
    }
    else {
      stereoOut[0] = 0;
      stereoOut[1] = 0;
    }
    return stereoOut;
  }

  public float wtOut() {
    wtIndex %= 44100;
    wtOut = waveTableArray[audioType].waveTable[wtIndex] * volFilter.loPass(volume);
    wtIndex += int(freq * pitchCentre + 200);
    wtIndexMod = int(waveTableArray[audioType].waveTable[wtIndex/2] * 200);
    return wtOut;
  }

   public void sendAudioMapping(int caseNum, float control) {
    switch(caseNum) {

    case 0: 
      volume = 1-control;
      break;

    case 1: 
      pitchCentre = (round(control*100) / 4) * 100; 
      break;

    case 2: 
      e.setAttack(2 + int(control * 1000)); 
      break;

    case 3: 
      e.setDecay(2 + int(control * 2000));  
      break;

    case 4: 
      f.setCutoff(control); 
      break;

    case 5: 
      filterType = int(control * 3); 
      break;

    case 6: 
      d.setDelayTime(11025 + int(control * 22050)); 
      break;

    case 7: 
      d.setFeedback(control*0.5f); 
      break;

    case 8: 
      reverbMix = control; 
      break;

    case 9: 
      reverbFeedback = control; 
      break;

    case 10: 
      distortion = 1 + control*3; 
      break;

    case 11: 
      setAudioType(int(control * 5 - 0.1f)); 
      break;

    default: 
      break;
    }
  }

  public void sendVisualMapping(int caseNum, float control) {
    switch(caseNum) {

      //VOLUME
    case 0: 
      if (control < OFF_THRESHOLD) {
        z = -((control * width * 1.5) - width/3);
        zNorm = control;
        isOn = true;
      }
      else isOn = false;
      break;
      //PITCHCENTRE
    case 1: 
      s.setSize(1-control); 
      break;
      //ENVELOPETIME
    case 2: 
      explodeHoldFrames = colHoldFrames = int(e.getDecay() / 44.1f / frameRate);
      break;
      
    case 3:

      break;

    case 4:
      s.setRot(control);
      break;

    case 5://DELAYTIME
      
      break;

    case 6://DELAYFEEDBACK

      break;

    case 7://REVERBMIX

      break;

    case 8://REVERBFEEDBACK

      break;

    case 9://DISTORTION

      break;
      //BOIDTYPE
    case 10: 
      setVisualType(int(control * 6)); 
      break;
    }
  }

  public void setVisualType(int type) {

    visualType = type;
    switch(type) {
    case 0://sin
      colG = 100;
      colB = 150;
      break;    
    case 1://tri
      colG = colB = 100;
      break;
    case 2://saw
      colG = 255;
      colB = 0;
      break;
    case 3://square
      colG = 150;
      colB = 45;
      break;
    default:
      colB = colG = 50;
      break;
    }
  }

  public void setAudioType(int type) {
    audioType = type;
  }
}


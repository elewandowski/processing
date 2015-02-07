class Delay {

  int   readHead, writeHead, delayTime;
  float feedback, mix, output;
  float [] delayLine;

  Delay(int length, int delayTime, float feedback) {

    delayLine       = new float[length];
    this.feedback   = feedback;
    this.delayTime  = delayTime;
    mix = 0.5;
  }
  
//  float delay(float input) {
//    
//    output = (delayLine[readHead] * mix) + (input * (1-mix));
//    
//    delayLine[writeHead] = (delayLine[writeHead] + input) * feedback;
//    
//    writeHead ++;
//    writeHead %= delayLine.length;
//    
//    readHead =
//    readHead ++;
//    readHead %= delayTime;
//
//    return output;
//  }

  float delay(float input) {
    
    output = (delayLine[readHead] * mix) + (input * (1-mix));
    
    delayLine[readHead] = (delayLine[readHead] + input) * feedback;
    
    readHead ++;
    readHead %= delayTime;

    return output;
  }

  float delayRev(float input) {

    delayLine[readHead] *= feedback;
    delayLine[readHead] = (delayLine[readHead] + input) * 0.5;

//    writeHead ++;
//    writeHead %= delayLine.length;
    
    readHead %= 1 + (delayTime - 2);
    output = delayLine[readHead];
    readHead ++;
    
    return output;
  }

  void setDelayTime(int delayTime) {
    if(this.delayTime != delayTime) this.delayTime = delayTime;
  }

  void setFeedback(float feedback) {
    this.feedback = feedback;
  }

  void setMix(float mix) {
    this.mix = mix;
  }
}

class Reverb {

  Delay[] delays = new Delay[6];
  float output;

  Reverb(int length, int delayTime, float feedback) {
    for (int i=0; i<delays.length; i++) {
      delays[i] = new Delay(length, (int) random(delayTime/3, delayTime), random(feedback/2, feedback));
    }
  }

  float reverb(float input) {

    output = 0;
    for (int i=0; i<delays.length; i++) {
      output += delays[i].delayRev(input);
    }
    output /= delays.length;
    return output;
  }
}

class Envelope {

  int[] times = new int[2];
  float[] values = new float[2];
  float signal, env;
  int segmentCount, sampleCount, tempAttack, tempDecay;
  boolean trigger, flag; 

  //an attack decay envelope
  Envelope(float value0, int time0, float value1, int time1) {

    flag = trigger = false;
    segmentCount = 0;
    sampleCount = 0;

    values[0] = value0;
    times[0] = PApplet.parseInt(time0*44.1f);
    values[1] = value1;
    times[1] = PApplet.parseInt(time1*44.1f);
  }

  public void trigger() {
    reset();
    trigger = true;
    segmentCount = 0;
//    escapeFade = true;
  }
  
  public void queue(){
    if(!trigger){
      reset();
      trigger = true;
    }
  }

  public float env(float signal) {
    
    if(trigger){
      
  
      switch(segmentCount) {
        case 0: 
          env = values[segmentCount] * ((float)sampleCount/times[segmentCount]); // attack increase
  //       if(frameCount%30==0)println("attacking " + trigger +" "+ sampleCount +" "+ millis());
          break;
        case 1:
          env = values[segmentCount] * (1-(float)sampleCount/times[segmentCount]);// decay decrease
  //       if(frameCount%30==0)println("decaying " + millis());
          break;
//        case 2:
//          env = 1 * (1-(float)sampleCount/88); // 2ms fade to avoid clicks whilst changing envelope timings
//          println("essssacape " + millis());
//          if (sampleCount >= 88) {
//            escapeFade = false;
//            reset();
//            trigger = true;
//          }
//          break;
      }
      
      sampleCount++;
      
      if (sampleCount >= times[segmentCount]) {
        segmentCount++;
        if (segmentCount > 1) reset();
        sampleCount = 0;
      }
     
      
    }else if(flag){
      times[0] = tempAttack;
      times[1] = tempDecay;
      flag = false;
    }
    signal *=  env;
    
    return signal;
  }

  public void reset() {
    trigger = false;
    segmentCount = 0;
    sampleCount = 0;
  }

  public void setAttack(int attack) {
    if (int(attack*44.1) != times[0]) {
      flag = true;
      tempAttack = int(attack*44.1);
    }
  }

  public float getAttack() {
    return times[0];
  }

  public void setDecay(float decay) {
    if (int(decay*44.1) != times[1]) {
      flag = true;
      tempDecay = int(decay*44.1);
    }
  }

  public float getDecay() {
    return times[1];
  }
}

class Filter {

  float previousSample, cutOff, resonance, input, output;

  Filter(float cutOff) {
    this.resonance = 1f - resonance;
    this.cutOff = cutOff;
  }

  float filter(float input, int type) {
    switch(type) {
    case 0: 
      //no filter
      output = input;
      break;
    case  1:
      output = loPass(input);
      break;
    case 2:
      output = hiPass(input);
      break;
    }
    return output;
  }

  float loPass(float _input) {
    input = _input;
    output = previousSample + cutOff * (input - previousSample);
    previousSample = output;
    return output;
  }

  float hiPass(float _input) {
    input = _input;
    output = input - (previousSample + cutOff*(input-previousSample));
    previousSample = output;
    return output;
  }

  void setRes(float resonance) {
    this.resonance = 1f - resonance;
  }

  void setCutoff(float cutOff) {
    this.cutOff = cutOff;
  }
}

class WaveTable {

  float[] waveTable;
  int wtIndex, wtIndex2;
  float output, output2;

  WaveTable(int caseNum) {
    waveTable = new float[44100];
    populateWaveTable(caseNum);
  }

  WaveTable(int caseNum, int size) {
    waveTable = new float[size];
    populateWaveTable(caseNum);
  }

  void populateWaveTable(int caseNum) {

    switch(caseNum) {

      //sinewave
    case 0:
      float angle = 0;
      float increment = TWO_PI/waveTable.length;
      for (int i=0; i<waveTable.length; i++) {
        waveTable[i] = sin(angle);
        angle = increment*i;
      }
      break;

      //triangle wave
    case 1:
      angle = 0;
      increment = 1f / (waveTable.length / 4);
      for (int i=0; i<waveTable.length; i++) {
        if (angle > 1 || angle < -1) increment *= -1; 
        waveTable[i] = angle;
        angle += increment;
      }
      break;

      //sawtooth wave
    case 2:
      for (int i=0; i<waveTable.length; i++) {
        waveTable[i] = (((float)i/waveTable.length)-0.5)*2;
      }
      break;

      //square wave
    case 3:
      for (int i=0; i<waveTable.length; i++) {
        if ((float)i/44100<0.5) this.waveTable[i] = 1;
        else waveTable[i] = -1;
      }
      break;     

      //white noise
    case 4:
      for (int i=0; i<waveTable.length; i++) {
        waveTable[i] = random(-1, 1);
      }
      break;

      //multiple sinewaves in one wavetable
    case 5:
      angle = 0;
      increment = TWO_PI/waveTable.length;
      for (int i=0; i<waveTable.length; i++) {
        waveTable[i] = sin(angle);
        angle = (increment*i) + (increment*i*8);
      }
      break;

      // blank waveTable
    case 6:
      for (int i=0; i<waveTable.length; i++) {
        waveTable[i] = 0;
      }
      break;
    }
  }

  float output(float frequency, float amplitude) {
    wtIndex %= waveTable.length;
    output = waveTable[wtIndex] * amplitude;
    wtIndex += frequency;
    return output;
  }

  float output2(float frequency, float amplitude) {
    wtIndex2 %= waveTable.length;
    output2 = waveTable[wtIndex2] * amplitude;
    wtIndex2 += frequency;
    return output2;
  }

  float readWt(int wtIndex) {
    output = waveTable[wtIndex];
    return output;
  }

  void record(float sample) {
    waveTable[this.wtIndex] = sample;
    this.wtIndex++;
    this.wtIndex %= waveTable.length;
  }
}

float distortion(float signal, float distortion) {
  signal *= distortion;
  if (signal > 1) signal = 1;
  else if (signal < -1) signal = -1;
  return signal;
}

void stereoLimiter(float sampleL, float sampleR) {

  if (sampleL > 1) { 
    sampleL = 1;
    if (frameCount % 60 == 0) println("clipping LEFT >1");
  }
  else if (sampleL < -1) {
    sampleL = -1;
    if (frameCount % 60 == 0) println("clipping LEFT <-1");
  }
  if (sampleR > 1) {
    sampleR = 1;
    if (frameCount % 60 == 0) println("clipping RIGHT >1");
  }
  else if (sampleR < -1) {
    sampleR = -1;
    if (frameCount % 60 == 0) println("clipping RIGHT <-1");
  }
}

float limiter(float sample) {
  if (sample > 1) { 
    sample = 1;
    if (frameCount % 60 == 0) println("clipping >1");
  }
  else if (sample < -1) {
    sample = -1;
    if (frameCount % 60 == 0) println("clipping <-1");
  }
  return sample;
}


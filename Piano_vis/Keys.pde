class Keys {
  
  int size = 120;
  int keys [] = new int[size];
  int keysWithPedal [] = new int[size];
  int keysWithPedalAndDecay [] = new int[size];
  boolean PEDAL_STATE = false;
  int LAST_PLAYED_KEY = 0;
  int BASS_NOTE = 0;
  
  Keys() {
    for (int i=0; i<size; i++) {
      keys[i] = 0;
      keysWithPedal[i] = 0;
      keysWithPedalAndDecay[i] = 0;
    }
  }
  
  int getVel(int pitch){
    return keysWithPedalAndDecay[pitch] = reduceVel(keysWithPedalAndDecay[pitch]);
  }
  
  void setVel(int pitch, int velocity) {
    keys[pitch] = velocity;
    keysWithPedalAndDecay[pitch] = keysWithPedal[pitch] = pedal(keysWithPedal[pitch], velocity);
    BASS_NOTE = findBassNote(pitch);
    LAST_PLAYED_KEY = pitch;
  }
  
  void setPedal(boolean state) {
    if (state == false && PEDAL_STATE == true) silenceKeys();
    PEDAL_STATE = state;
  }
  
  private int pedal(int currentVelocity, int newVelocity) {
    println("the pedalstate is: "+PEDAL_STATE+" the newVelocioty is: "+newVelocity);
    return PEDAL_STATE && newVelocity == 0 ? currentVelocity : newVelocity; 
  }
  
  private int reduceVel(int vel){
    if (frameCount % 2 == 0) {
      if (vel > 0) vel -= 1;
    }
    return vel;
  }
  
  private void silenceKeys() {
    for (int i=0; i<keysWithPedal.length; i++) {
      if (keys[i] == 0) {
        keysWithPedal[i] = keysWithPedalAndDecay[i] = 0;
      }
    }
  }
  
  private int findBassNote(int currentNote){
    int returnBassNote = BASS_NOTE;
    
    if (keysWithPedal[currentNote] != 0 && (keysWithPedal[BASS_NOTE] == 0 || currentNote < BASS_NOTE)) {
        returnBassNote = currentNote;
      //println("the new bass note is: " + returnBassNote);
    }
    return returnBassNote;
  }
}

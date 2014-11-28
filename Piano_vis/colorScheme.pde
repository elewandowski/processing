color colorScheme(int pit, int vel, int bassNote) {
  
  color returnColor = color(0);
  float red = 0;
  float grn = 0;
  float blu = 0;
  float hue = 0;
  float sat = 0;
  float brit = 0;
//  float alpha = map(mouseX, 0, width, 0, 255);
  float alpha = 127;
//float red, grn, blu = 0;
//  red, grn, blue = 0;
  
  switch(COLOR_SCHEME) {
    case 1:
      red = hue % 255;
      grn = hue - 255 % 510;
      blu = hue - 510 % 765;
      returnColor = color(red, grn, blu);
      break;
    case 2:
      hue = map(pit, 0, 120, 0, 360);
      sat = map(pit, 0, 120, 0, 100);
      brit = map(vel, 0, 127, 0, 100);
      returnColor = color(hue, sat, brit, alpha);
//      println(returnColor);
      break;
    case 3:
      hue = map(vel, 0, 120, 0, 360);
      sat = 127;
      brit = 127;
      returnColor = color(hue, sat, brit, alpha);
      break;
  }
     
  return returnColor;
}

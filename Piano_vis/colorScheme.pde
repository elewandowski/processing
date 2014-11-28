color colorScheme(int pit, int vel, int bassNote) {
  
  float red = 0;
  float grn = 0;
  float blu = 0;
  float hue = map(pit, 0, 120, 0, 765);
  float brightness = map(vel, 0, 127, 0, 255);
//float red, grn, blu = 0;
//  red, grn, blue = 0;
  
  switch(COLOR_SCHEME) {
    case 1:
      red = hue % 255;
      grn = hue - 255 % 510;
      blu = hue - 510 % 765;
      break;
    case 2:
      red = 0;
      break;
  }
     
  return color(red, grn, blu);
}

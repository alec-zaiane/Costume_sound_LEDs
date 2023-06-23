// edit these globals to change the layout of the rendering
int leds_per_pixel = 3;         // how many LEDs per pixel
int NUM_LEDS = 400;             // how many pixels total (not number of LEDs)
int NUM_BUCKETS = 20;           // how many buckets (and strips) there are
int BUCKET_MAX = 100;           // max value for the buckets
int VISUAL_LED_SIZE = 6;        // how big the LEDs are
int VISUAL_STRIP_THICKNESS = 4; // thickness of the strips in the background
int VISUAL_STRIP_LIGHTNESS = 0; // brightness value of the strips in the background
int VISUAL_STRIP_OVERSCAN = 5;  // strip extends x pixels above/below leds
int VISUAL_LED_CLARITY = 4;    // for drawing LED glow, heavily affects performance, set to 1 to draw LEDs solidly
int DISPLAY_MODE = 0;

// dont' edit these globals
int pixels_per_bucket = NUM_LEDS/NUM_BUCKETS;
int LEDs_per_bucket = pixels_per_bucket * leds_per_pixel;
color strip[] = new color[NUM_LEDS];
int buckets[] = new int[NUM_BUCKETS];
int hueRotate = 0;
/*
  this file contains code for visualizing the LED array, if you want to change the layout (# of LEDs or # per strip, etc), the variables are above
  if you want to change the patterns and colours, the code for that is in `EDIT_ME_calculate_LED_funcs.pde`
*/

void setup() {
  size(700, 920);
  frameRate(20);
}

void draw() {
  surface.setTitle("LED Visualizer | fps: "+frameRate);
  background(32);
  update_buckets();
  calculate_LEDs();
  draw_LEDs(100, 70, 600, 850);
  //draw_LEDs(100,70,mouseX,mouseY);
}

// draws the strips and the LEDs on top of it
void draw_LEDs(int minx, int miny, int maxx, int maxy) {
  // draw each strip first
  // the first strip will be on minx, the last strip will be on maxx, others evenly distributed
  // all strips go from miny -> maxy
  int xspan = maxx - minx;
  int yspan = maxy - miny;
  boolean forward = true;
  int rolling_index = 0;
  for (int i=0; i<NUM_BUCKETS; i++) {
    int strip_xpos = (i*(xspan/(NUM_BUCKETS-1))) + minx;
    pushMatrix();
    translate(strip_xpos, miny);
    if (!forward) {
      translate(0, yspan);
      rotate(PI);
    }
    stroke(VISUAL_STRIP_LIGHTNESS);
    strokeWeight(VISUAL_STRIP_THICKNESS);
    line(0, -VISUAL_STRIP_OVERSCAN, 0, yspan+VISUAL_STRIP_OVERSCAN);
    // draw pixels from 0 to yspan
    int LED_yoff = int(float(yspan)/float(2*LEDs_per_bucket));
    for (int j=0; j<LEDs_per_bucket; j++) {
      int LED_ypos = int(j*(float(yspan)/float(LEDs_per_bucket)));
      draw_LED(strip[rolling_index], 0, LED_ypos+LED_yoff);
      if (j%leds_per_pixel == (leds_per_pixel-1)) {
        rolling_index++;
      }
    }

    popMatrix();
    forward = !forward;
  }
}

// draws a single LED of colour `col` at position `(x, y)`
void draw_LED(color col, int x, int y) {
  rectMode(CENTER);
  noStroke();
  if(VISUAL_LED_CLARITY == 1){ // draw a different style if size is 1
    fill(col);
    ellipse(x,y, VISUAL_LED_SIZE*1.2, VISUAL_LED_SIZE*1.2);
    return;
  }
  color bright_col = lerpColor(col, #FFFFFF, 0.8); 
  for(int i=0; i< VISUAL_LED_CLARITY; i++){
    //draw multiple circles to simulate a glow effect
    // sizes from VISUAL_LED_SIZE*2 to VISUAL_LED_SIZE/2
    float lerp_amount = float(i+1)/float(VISUAL_LED_CLARITY); // between small number and 1
    float col_lerp_amount = lerp_amount * lerp_amount; // more realistic?
    fill(lerpColor(col, bright_col, col_lerp_amount), int(lerp_amount*255));
    float size = lerp(VISUAL_LED_SIZE*2, VISUAL_LED_SIZE/2, lerp_amount);
    ellipse(x, y, size, size);
  }
}

// dummy function to update the values stored in buckets[] - in deployment this will be the FFT data (modify if you want a different pattern temporally)
void update_buckets(){
  for(int i=0; i<NUM_BUCKETS; i++){
    if(buckets[i] > 1){
      buckets[i] -= random(0.7)*random(10);
    }
    if(random(1) > 0.9){
      buckets[i] = max(int(random(BUCKET_MAX)),buckets[i]);
    }
    buckets[i] = max(buckets[i],0);
  }
}

int leds_per_pixel = 3;
int NUM_LEDS = 100;
int NUM_BUCKETS = 5;
int BUCKET_MAX = 100;
int VISUAL_LED_SIZE = 8;
int VISUAL_STRIP_THICKNESS = 4;
int VISUAL_STRIP_LIGHTNESS = 32;
int VISUAL_STRIP_OVERSCAN = 20; // strip extends x pixels above/below leds


int pixels_per_bucket = NUM_LEDS/NUM_BUCKETS;
int LEDs_per_bucket = pixels_per_bucket * leds_per_pixel;
color strip[] = new color[NUM_LEDS];
int buckets[] = {10,25, 50, 75, 100};

void setup() {
  size(1280, 920);
}

void draw() {
  background(128);
  //calculate_LEDs();
  draw_LEDs(100, 70, 1180, 850);
}

void calculate_LEDs() {
  int rolling_index = 0;
  boolean forward = true;
  for(int i=0; i<NUM_BUCKETS; i++){
    float float_pattern_1 = float(pixels_per_bucket * buckets[i]) / float(BUCKET_MAX);
    int num_pattern_1 = int(float_pattern_1);
    float fractional_pattern_1 = float_pattern_1 - num_pattern_1;
    int num_pattern_2 = pixels_per_bucket - num_pattern_1-1;
    println("===");
    println(num_pattern_1);
    println(fractional_pattern_1);
    println(num_pattern_2);
    println((num_pattern_1 + num_pattern_2 + 1) == pixels_per_bucket);
    println(rolling_index);
    if (!forward) {
      for(int j=0; j<num_pattern_2; j++){
         strip[rolling_index] = pattern_2(rolling_index);
         rolling_index++;
      }
      strip[rolling_index] = mix_pattern_percent(rolling_index, fractional_pattern_1);
      rolling_index++;
    }
    for(int j=0; j<num_pattern_1; j++){
      strip[rolling_index] = pattern_1(rolling_index);
      rolling_index++;
    }
    if (forward){
      strip[rolling_index] = mix_pattern_percent(rolling_index, fractional_pattern_1);
      rolling_index++;
      for(int j=0; j<num_pattern_2; j++){
         strip[rolling_index] = pattern_2(rolling_index);
         rolling_index++;
      }
    }
    forward = !forward;
  }
}

color pattern_1(int idx) {
  color out = #FFFFFF;
  if (idx%2 == 0) {
    out *= 0.8;
  }
  return out;
}

color pattern_2(int idx) {
  color out = #FF00F0;
  if (idx%2 == 0) {
    out *= 0.8;
  }
  return out;
}

color mix_pattern_percent(int idx, float mix_percent) {
  color col1 = pattern_1(idx);
  color col2 = pattern_2(idx);
  col1 *= mix_percent;
  col2 *= (1.0-mix_percent);
  return col1+col2;
}

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
    if (!forward){
      translate(0,yspan);
      rotate(PI);
    }
    stroke(VISUAL_STRIP_LIGHTNESS);
    strokeWeight(VISUAL_STRIP_THICKNESS);
    line(0, -VISUAL_STRIP_OVERSCAN, 0, yspan+VISUAL_STRIP_OVERSCAN);
    // draw pixels from 0 to yspan
    for (int j=0; j<LEDs_per_bucket; j++){
      int LED_ypos = j*(yspan/(LEDs_per_bucket));
      draw_LED(strip[0], 0, LED_ypos);
    }
    
    popMatrix();
    forward = !forward;
    //for (int j=0; j<pixels_per_bucket; j++) {
    //  int pixel_ypos = (j*(yspan/(pixels_per_bucket))) + miny;
    //  if (!forward) {
    //    pixel_ypos = maxy - pixel_ypos +(yspan/(pixels_per_bucket));
    //  }
    //  pixel_ypos += 17;
    //  //draw_LED(strip[0], strip_xpos, pixel_ypos);
    //  for (int k=0; k<leds_per_pixel; k++) {
    //    int strip_index = j+(i*pixels_per_bucket);
    //    int LED_y_offset = (k-1)*((yspan/(pixels_per_bucket))/2);
    //    draw_LED(strip[strip_index], strip_xpos, pixel_ypos+LED_y_offset);
    //  }
    //}
    //forward = !forward;
  }
}

void draw_LED(color col, int x, int y) {
  rectMode(CENTER);
  fill(col);
  noStroke();
  rect(x, y, VISUAL_LED_SIZE, VISUAL_LED_SIZE);
  return;
}

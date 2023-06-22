int leds_per_pixel = 3;
int NUM_LEDS = 400;
int NUM_BUCKETS = 20;
int BUCKET_MAX = 100;
int VISUAL_LED_SIZE = 6;
int VISUAL_STRIP_THICKNESS = 4;
int VISUAL_STRIP_LIGHTNESS = 0;
int VISUAL_STRIP_OVERSCAN = 5; // strip extends x pixels above/below leds
int VISUAL_LED_CLARITY = 10; // for drawing pixel glow

int pixels_per_bucket = NUM_LEDS/NUM_BUCKETS;
int LEDs_per_bucket = pixels_per_bucket * leds_per_pixel;
color strip[] = new color[NUM_LEDS];
int buckets[] = new int[NUM_BUCKETS];

void setup() {
  size(1280, 920);
  frameRate(20);
}

void draw() {
  surface.setTitle("FPS"+frameRate);
  background(32);
  update_buckets();
  calculate_LEDs();
  draw_LEDs(100, 70, 600, 850);
}

void calculate_LEDs() {
  int rolling_index = 0;
  boolean forward = false; // reverse every 2nd strip (because of how they're wired up)
  for (int i=0; i<NUM_BUCKETS; i++) {
    // for each strip, draw a solid pattern_1 amount, then a transition pixel, then a solid pattern 2 amount. pattern_1_amount + 1 + pattern_2_amount *must* == the number of pixels per bucket
    float throwaway_amount_pattern_1 = float(pixels_per_bucket*buckets[i])/float(BUCKET_MAX);
    int full_pattern_1 = int(throwaway_amount_pattern_1); // amount of full pattern_1 pixels
    if (full_pattern_1 == pixels_per_bucket){
      full_pattern_1 -=1;
    }
    float transition_pattern_1_amount = throwaway_amount_pattern_1 - full_pattern_1; // how much of pattern_1 should be in the transition pixel?
    float full_pattern_2 = pixels_per_bucket - full_pattern_1 - 1;
    // if the strip is reversed, draw pattern_2 first
    if (!forward) {
      for (int j=0; j<full_pattern_2; j++) {
        strip[rolling_index] = pattern_2(rolling_index++);
      }
      // draw transition pixel
      strip[rolling_index] = mix_pattern_percent(rolling_index++, transition_pattern_1_amount);
    }
    // draw pattern_1
    for (int j=0; j<full_pattern_1; j++) {
      strip[rolling_index] = pattern_1(rolling_index++);
    }
    // draw transition and pattern2 if forward
    if (forward) {
      strip[rolling_index] = mix_pattern_percent(rolling_index++, transition_pattern_1_amount);
      for (int j=0; j<full_pattern_2; j++) {
        strip[rolling_index] = pattern_2(rolling_index++);
      }
    }
    forward = !forward;
  }
}

color pattern_1(int idx) {
  color out = color(50,30,250);
  if (idx%2 == 0) {
    out = color(30,16,200);
  }
  return out;
}

color pattern_2(int idx) {
  color out = color(255,255,255);
  if (idx%2 == 0) {
    out = color(255,255,200);
  }
  return out;
}

color mix_pattern_percent(int idx, float mix_percent) {
  color col1 = pattern_1(idx);
  color col2 = pattern_2(idx);
  color out = lerpColor(col2, col1, mix_percent);
  return out;
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
    if (!forward) {
      translate(0, yspan);
      rotate(PI);
    }
    stroke(VISUAL_STRIP_LIGHTNESS);
    strokeWeight(VISUAL_STRIP_THICKNESS);
    line(0, -VISUAL_STRIP_OVERSCAN, 0, yspan+VISUAL_STRIP_OVERSCAN);
    // draw pixels from 0 to yspan
    int LED_yoff = yspan/(2*LEDs_per_bucket);
    for (int j=0; j<LEDs_per_bucket; j++) {
      int LED_ypos = j*(yspan/(LEDs_per_bucket));
      draw_LED(strip[rolling_index], 0, LED_ypos+LED_yoff);
      if (j%3 == 2) {
        rolling_index++;
      }
    }

    popMatrix();
    forward = !forward;
  }
}

void draw_LED(color col, int x, int y) {
  rectMode(CENTER);
  noStroke();
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


void update_buckets(){
  // dummy function to update the values stored in buckets[] - in deployment this will be the FFT data
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

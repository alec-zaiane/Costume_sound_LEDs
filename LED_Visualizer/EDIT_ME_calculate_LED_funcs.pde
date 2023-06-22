/*
  this file contains the functions that will be present on the arduino
  calculate_LEDs() will likely stay the same until optimization
  change pattern_1() and pattern_2() to change the look of the project
   - they each return a colour given an index, and will have access to a global time variable, so frameCount could be used (framerate instability shouldn't matter too much)
   - right now the patterns are a very simple checker pattern (one pixel alternating between light and dark versions of blue (pattern_1) and yellow (pattern_2), but they have lots of malleability
*/

color pattern_1(int idx) {
  color out = #5357F2;
  if (idx%2 == 0) {
    out = #260FFF;
  }
  return out;
}

color pattern_2(int idx) {
  color out = #F0E516;
  if (idx%2 == 0) {
    out = #FFF862;
  }
  return out;
}

// don't change functions below unless you want to change functionality

color mix_pattern_percent(int idx, float mix_percent) {
  // mixes between two colours (boilerplate for lerpColor but will need to be implemented on the arduino side)
  color col1 = pattern_1(idx);
  color col2 = pattern_2(idx);
  color out = lerpColor(col2, col1, mix_percent); // this will have to be different in arduino
  return out;
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

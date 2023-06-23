#include <FastLED.h>
#include <fix_fft.h>

FASTLED_USING_NAMESPACE

#define DATA_PIN 3
#define LED_TYPE WS2811
#define COLOR_ORDER GRB
#define NUM_LEDS 100
CRGB leds[NUM_LEDS];

#define BRIGHTNESS 96
#define FPS 50

#define NUM_BUCKETS 5
#define BUCKET_MAX 100
short bucket_length = NUM_LEDS / NUM_BUCKETS;
short freq_buckets[] = { 10, 25, 50, 75, 100 };

void setup() {
  // put your setup code here, to run once:
  delay(3000);
  FastLED.addLeds<LED_TYPE, DATA_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);
  FastLED.setBrightness(BRIGHTNESS);
}

uint8_t gHue = 0;  // rotating "base color" used by many of the patterns

void loop() {
  FastLED.clear();
  // put your main code here, to run repeatedly:
  disp_buckets();
  FastLED.show();
  FastLED.delay(1000 / 10);
  EVERY_N_MILLISECONDS(20) {
    gHue++;
  }  // slowly cycle the "base color" through the rainbow
}

void disp_buckets() {
  // display frequency buckets onto the LED strip
  short rolling_index = 0;
  bool forward = true;
  for (short i = 0; i < NUM_BUCKETS; i++) {
    float float_pattern_1 = float(bucket_length * freq_buckets[i]) / float(BUCKET_MAX);
    short num_pattern_1 = short(float_pattern_1);                    // round down
    float fractional_pattern_1 = float_pattern_1 - num_pattern_1;  // set to number [0,1), acts as the % it should be pattern 1
    short num_pattern_2 = bucket_length - num_pattern_1;
    if (!forward) {  // if not forward, draw pattern 2 first
      for (short j = 0; j < num_pattern_2; j++) {
        leds[rolling_index] = pattern_2(rolling_index++);
      }
      // then show mixed pixel
      leds[rolling_index] = mix_pattern_percent(rolling_index++, fractional_pattern_1);
    }
    // draw pattern 1
    for (short j = 0; j < num_pattern_1; j++) {
      leds[rolling_index] = pattern_1(rolling_index++);
    }
    if (forward) {
      // show mixed pixel
      leds[rolling_index] = mix_pattern_percent(rolling_index++, fractional_pattern_1);
      // show pattern 2
      for (short j = 0; j < num_pattern_2; j++) {
        leds[rolling_index] = pattern_2(rolling_index++);
      }
    }
    forward = !forward;
  }
}

CRGB mix_pattern_percent(short index, float fraction) {
  //mix between fraction % of pattern 1 and (1-fraction%) of pattern 2 at index
  //TODO
  CRGB p1 = pattern_1(index);
  p1 *= fraction;
  CRGB p2 = pattern_2(index);
  p2 *= (1.0 - fraction);
  return p1 + p2;
}

CRGB pattern_1(short index) {
  CRGB out = CRGB::White;
  if(index % 2 == 0){
    out *= 0.7;
  }
  return out;
}

CRGB pattern_2(short index) {
  CRGB out = CRGB::Red;
  if(index % 2 == 0){
    out *= 0.7;
  }
  return out;
}
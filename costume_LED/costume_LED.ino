#include <FastLED.h>
#include <fix_fft.h>

FASTLED_USING_NAMESPACE

#define DATA_PIN 3
#define LED_TYPE WS2811
#define COLOR_ORDER GRB
#define NUM_LEDS 100
CRGB leds[NUM_LEDS];

#define BRIGHTNESS 50
#define FPS 50

#define NUM_BUCKETS 5
#define BUCKET_MAX 100
const short bucket_length = NUM_LEDS / NUM_BUCKETS;
short freq_buckets[] = { 10, 25, 50, 75, 100 };
int prev_millis = 0;

void setup() {
  // put your setup code here, to run once:
  delay(3000);
  FastLED.addLeds<LED_TYPE, DATA_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);
  FastLED.setBrightness(BRIGHTNESS);
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(9600);
}

uint8_t gHue = 0;  // rotating "base color" used by many of the patterns

void loop() {
  Serial.println(millis() - prev_millis);
  prev_millis = millis();
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
  // directly adapted from simulator code
  short rolling_index = -1; // TODO figure out why this is -1 here and 0 in java
  bool forward = true;
  for(int i=0; i<NUM_BUCKETS; i++){
    //for each strip, draw a solid pattern_1 amount, then a transition pixel, then a solid pattern_2 amount
    float throwaway_amount_pattern_1 = float(bucket_length*freq_buckets[i]) / float(BUCKET_MAX);
    int full_pattern_1 = int(throwaway_amount_pattern_1);
    if(full_pattern_1 == bucket_length) {
      full_pattern_1 -=1;
    }
    float transition_pattern_1_amount = throwaway_amount_pattern_1 - full_pattern_1;
    float full_pattern_2 = bucket_length - full_pattern_1 - 1; // 1 for the transition pixel
    // if the strip is reversed, draw pattern_2 first
    if (!forward) {
      for(int j=0; j<full_pattern_2; j++){
        leds[rolling_index] = pattern_2(rolling_index++);
      }
      leds[rolling_index] = mix_pattern_percent(rolling_index++, transition_pattern_1_amount);
    }
    for(int j=0; j<full_pattern_1; j++){
      leds[rolling_index] = pattern_1(rolling_index++);
    }
    if (forward){
      leds[rolling_index] = mix_pattern_percent(rolling_index++, transition_pattern_1_amount);
      for(int j=0; j<full_pattern_2; j++) {
        leds[rolling_index] = pattern_2(rolling_index++);
      }
    }
    forward = !forward;
  }
}

CRGB mix_pattern_percent(short index, float fraction) {
  return CRGB::Green;
  //mix between fraction % of pattern 1 and (1-fraction%) of pattern 2 at index
  //TODO
  // CRGB p1 = pattern_1(index);
  // p1 *= fraction;
  // CRGB p2 = pattern_2(index);
  // p2 *= (1.0 - fraction);
  // return p1 + p2;
}

CRGB pattern_1(short index) {
  CRGB out = CRGB::White;
  if(index % 2 == 0){
    out = CRGB::WhiteSmoke;
  }
  return out;
}

CRGB pattern_2(short index) {
  CRGB out = CRGB::Red;
  if(index % 2 == 0){
    out = CRGB::OrangeRed;
  }
  return out;
}
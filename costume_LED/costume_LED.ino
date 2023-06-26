#include <FastLED.h>
#include <fix_fft.h>

FASTLED_USING_NAMESPACE

#define DATA_PIN 3
#define LED_TYPE WS2811
#define COLOR_ORDER GRB
#define NUM_LEDS 95  //380
CRGB leds[NUM_LEDS];

#define BRIGHTNESS 99
#define FPS 50

#define NUM_BUCKETS 5
const unsigned char BUCKET_LENGTH = NUM_LEDS / NUM_BUCKETS;  // TODO make this a compiler define later
// each bucket is out of 255
unsigned char freq_buckets[] = { 50, 54, 56, 58, 62 };  //{ 50, 64, 128, 184, 255};//, 25, 60, 80, 9, 55, 11, 23, 84, 92, 99, 50, 44, 80, 10, 34 };

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Serial.println(0);
  delay(3000);
  FastLED.addLeds<LED_TYPE, DATA_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);
  FastLED.setBrightness(BRIGHTNESS);
  pinMode(LED_BUILTIN, OUTPUT);
}

void update_buckets() {
  for (short i = 0; i < NUM_BUCKETS; i++) {
    if (freq_buckets[i] > 1) {
      freq_buckets[i] -= int(random(7));
      freq_buckets[i] = max(freq_buckets[i], 0);
    }
    if (random(11) > 9 || freq_buckets[i] < 1) {
      freq_buckets[i] = max(int(random(255)), freq_buckets[i]);
    }
  }
}

uint8_t gHue = 0;  // rotating "base color" used by many of the patterns

void loop() {
  Serial.println(millis());
  FastLED.clear();
  // put your main code here, to run repeatedly:
  disp_buckets();
  FastLED.show();
  FastLED.delay(1000 / 50);
  EVERY_N_MILLISECONDS(20) {
    gHue++;
    update_buckets();
  }  // slowly cycle the "base color" through the rainbow
}



void disp_buckets() {
  // display frequency buckets onto the LED strip
  // directly adapted from simulator code
  short rolling_index = -1;  // TODO figure out why this is -1 here and 0 in java
  bool forward = true;
  short full_pattern_1, full_pattern_2, transition_amount;
  for (short i = 0; i < NUM_BUCKETS; i++) {
    //calculate full pattern amounts and transition
    full_pattern_1 = freq_buckets[i] / (256 / BUCKET_LENGTH);
    transition_amount = (full_pattern_1 == BUCKET_LENGTH) ? 255 : BUCKET_LENGTH * (freq_buckets[i] % (256 / BUCKET_LENGTH));  // set to 255 if full_pattern_1 is full
    full_pattern_2 = BUCKET_LENGTH - full_pattern_1 - 1;
    //for each strip, draw a solid pattern_1 amount, then a transition pixel, then a solid pattern_2 amount
    if (full_pattern_1 == BUCKET_LENGTH) { full_pattern_1 -= 1; }  // subtract one so that the transition pixel can still be drawn (it is already set to 255)
    // if the strip is reversed, draw pattern_2 first
    if (!forward) {
      for (short j = 0; j < full_pattern_2; j++) {
        leds[rolling_index] = pattern_2(rolling_index++);
      }
      leds[rolling_index] = mix_pattern_percent(rolling_index++, transition_amount);
    }
    for (short j = 0; j < full_pattern_1; j++) {
      leds[rolling_index] = pattern_1(rolling_index++);
    }
    if (forward) {
      leds[rolling_index] = mix_pattern_percent(rolling_index++, transition_amount);
      for (short j = 0; j < full_pattern_2; j++) {
        leds[rolling_index] = pattern_2(rolling_index++);
      }
    }
    forward = !forward;
  }
}

CRGB mix_pattern_percent(short index, unsigned char amount) {
  return blend(pattern_2(index), pattern_1(index), amount);
}

CRGB pattern_1(short index) {
  CRGB out = CRGB::Cyan;
  if (index % 3 == 0) {
    out = CRGB::SlateBlue;
  }
  return out;
}

CRGB pattern_2(short index) {
  CRGB out = CRGB::Red;
  if (index % 3 == 0) {
    out = CRGB::OrangeRed;
  }
  return out;
}
#include "instructions.h";
#include "memory.h";
#include "ble.h"

Memory mem = {};

void setup() {
  mem.rx.a = 1;
  pinMode(LEDR, OUTPUT);
  
  initBLE();
}

void loop() {
  digitalWrite(LEDR, HIGH);
  delay(12);
  digitalWrite(LEDR, LOW);
  delay(1);

  loopBLE();
}

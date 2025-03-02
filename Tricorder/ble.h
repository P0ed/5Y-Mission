#include <ArduinoBLE.h>

typedef struct {
  int code;
  int payload[16];
} BLEIO;

const char deviceName[] = "Tricorder";
BLEService blelService("E20A39F4-73F5-4BC4-A12F-17D1AD07A962");

BLETypedCharacteristic<BLEIO> bleInput("08590F7E-DB05-467E-8757-72F6FAEB13D9", BLEWrite | BLEWriteWithoutResponse);
BLETypedCharacteristic<BLEIO> bleOutput("08590F7E-DB05-467E-8757-72F6FAEB13D6", BLERead);

BLEDevice central;

static void initBLE() {
  if (BLE.begin()) {
    BLE.setLocalName(deviceName);
    BLE.setDeviceName(deviceName);

    BLE.setAdvertisedService(blelService);

    blelService.addCharacteristic(bleInput);
    blelService.addCharacteristic(bleOutput);

    BLE.addService(blelService);
    BLE.advertise();

    central = BLE.central();
    central.connect();
  }
}

static void loopBLE() {
  central.connected();
}

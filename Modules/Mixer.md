### Functional description:
```
OUT1: IN1 * P1 (SW1) IN2 * P2
OUT2: OUT1 < OUT4 ? 5 : 0
OUT3: OUT1 + OUT4
OUT4: IN4 * P4 (SW2) IN3 * P3

SW1: (+) : (-)
SW2: (+) : (-)

LED1: OUT1
LED2: OUT4
```
LED wavelength: 630nm

### Schematic:

[Spice simulation](Mixer.asc)

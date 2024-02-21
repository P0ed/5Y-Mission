<img width="800" alt="Screenshot 2024-02-21 at 20 57 11" src="https://github.com/P0ed/5Y-Mission/assets/5844101/c7d21f87-e40e-4aa4-a743-46e0eac0b8d0">

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
<img width="800" alt="Screenshot 2024-02-21 at 18 55 12" src="https://github.com/P0ed/5Y-Mission/assets/5844101/93574a01-3657-4520-9079-1248025e5901">

[Spice simulation](Mixer.asc)

<img width="800" alt="Module" src="https://github.com/P0ed/5Y-Mission/assets/5844101/9ac468b0-5209-44cd-90c3-2ca82e12e505">

The sequencer is based on CD4029 binary counter and ADG1404 4:1 multiplexer. It outputs 3 lowest bits and one of four pots based on 2 lowest bits. Acting as a 1:8, 1:4, 1:2 frequency divider and 4 step CV sequencer. There are two operations: increment the counter or set to J2 << 1 | J1 where J1 and J2 are IN3 and IN2 negated or not by respective switch. It is possible to set the length of sequence by patching Q3 to SET and toggling switches to select initial stage.

### Functional description:
```
COUNT := 0

Q1: COUNT & 1 << 0
Q2: COUNT & 1 << 1
Q3: COUNT & 1 << 2

OUT1: Q3
OUT2: Q2
OUT3: Q1
OUT4: 5 * Q2 ? (Q1 ? P4 : P3) : (Q1 ? P2 : P1)

SW1: (!!) : (!)
SW2: (!!) : (!)

LED1: Q2
LED2: Q1

IN1[rising]: COUNT := (SW1)IN2 << 1 | (SW2)IN3 << 0
IN4[rising]: COUNT := COUNT + 1
```
LED wavelength: 587nm

### Schematic:
<img width="800" alt="Screenshot 2024-02-21 at 20 37 58" src="https://github.com/P0ed/5Y-Mission/assets/5844101/7e692b03-cb84-4868-a20f-e05dcb8ecf77">

[Spice simulation](Sequencer.asc)

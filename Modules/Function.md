### YADUSGC
<img width="800" alt="Screenshot 2024-02-21 at 20 58 10" src="https://github.com/P0ed/5Y-Mission/assets/5844101/deae1058-f72e-431d-ad85-529cefd027bd">

Based on first order state variable filter topology. There is a mixer at input, something that works as variable resistor with exponential response and an integrator. Integrator's input is derivative of its output. This derivative is then split into positive and negative parts and allows to control rise and fall times independently.

Besides SVF there are two flip-flops for attack and decay.

With two of these and a mixer it should be possible to build second order SVF with resonance.

### Functional description:
```
ATK := 0
DEK := 0

OUT1: ATK || END
OUT2: !OUT1
END: OUT4 < 4.20
OUT3: OUT4'
OUT4: ∫((IN - OUT4) * G)

IN: (ATK ? 10 : 0) + (DEK ? -10 : 0) + (SW1 ? IN : 0)
[!SW1 && IN1 > 1 && END]: ATK := 1
[OUT > 5]: ATK := 0
[!END && ATK]: DEK := 1
[OUT < 0.1]: DEK := 0

G: OUT3 > 0 ? GA : GD
GC: (SW2)P3 * IN3 + IN4 + P4
GA: GC + P1 + P2 * IN2
GD: GC - P1 + P2 * IN2
SW2: (+) : (-)
```
LED wavelength: 572nm

### Schematic:
<img width="800" alt="Screenshot 2024-02-21 at 20 35 20" src="https://github.com/P0ed/5Y-Mission/assets/5844101/da8bdf91-d95c-40e5-b945-ff0277825f57">

[Spice simulation](Function.asc)

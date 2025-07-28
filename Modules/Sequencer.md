# Sequencer

The sequencer is based on CD4029 binary counter and ADG429 2:1 multiplexer. It outputs one of the pot values and either of two lowest bits. Acting as a 1:4, 1:2 frequency divider and 4 step CV sequencer. There are two operations: increment the counter or set to IN2 << 1 | IN3.

### Schematic:
<img width="1206" height="876" alt="Screenshot 2025-07-28 at 16 52 01" src="https://github.com/user-attachments/assets/f562a0c5-222a-4f1d-af30-d693f368f1a1" />


[Spice simulation](Sequencer.asc)

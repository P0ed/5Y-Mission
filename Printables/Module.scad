$fn = 24;
in = 25.4;

include <../Parts/1900/1900.scad>

module Banana() {
	scl = 0.97;
	rs = in / 48;
	r = in / 4;
	h = 6.35;
	rt = r * scl - rs;
	hr = in / 8;
	
	difference() {
		union() {
			translate([0, 0, h - rs - rt])
			rotate_extrude()
			translate([rt, rt])
			circle(rs);
			
			linear_extrude(h - rs, scale = scl)
			circle(r);

			linear_extrude(h)
			circle(rt);
		}
		
		translate([0, 0, 2])
		linear_extrude(h)
		circle(hr);
	}
}

module LED() {
	translate([0, 0, 2])
	intersection() {
		linear_extrude(3)
		circle(d = 5);
		
		translate([0, 0, -0.4])
		sphere(d = 5 + 0.1);
	}
	linear_extrude(2.01)
	circle(d = 5);
}

module Button() {
	linear_extrude(2.5)
	circle(d = 5);
}

color("#664400")
translate([in / 2, in / 2])
for(x = [0:3]) for(y = [2:2])
translate([x * in, y * in])
Banana();

color("#222222")
translate([in / 2, in / 2])
for(x = [0:3]) for(y = [1:1])
translate([x * in, y * in])
Banana();

color("#222222")
translate([in / 2, in / 2])
for(x = [0:3]) for(y = [0:0])
translate([x * in, y * in])
D1900(holes = false);

color("#222222")
translate([in, in])
for(x = [0:1]) for(y = [0:0])
translate([x * in * 2, y * in])
Button();

color("#449955")
translate([in, in])
for(x = [0:1]) for(y = [1:1])
translate([x * in * 2, y * in])
LED();

color("#EEEECC")
translate([0, 0, -2])
linear_extrude(2)
square([in * 4, in * 3]);

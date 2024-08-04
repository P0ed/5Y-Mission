$fn = 8;
hfn = 48;

wt = 1.2;
sw_h = 13.1;
pot_h = sw_h - 8.9;
nna_h = sw_h - 6.5;

nna_d = 6.8;
pot_d = 10.0;

function in(x) = x * 25.4;

function gx(x) = in(1) * x;
function gy(x) = in(1) * x;
function g(x, y) = [gx(x), gy(y), 0];

module do(cx, cy, sx, sy) {
	for (x = [0 : cx - 1]) {
		for (y = [0 : cy - 1]) {
			translate([x * sx, y * sy]) children();
		}
	}
}

module round_spacer(d, w, h) {
	linear_extrude(h) difference() {
		circle(d=d + w * 2);
		circle(d=d, $fn=hfn);
	}
}

module hul(offset) {
	hull() {
		children();
		translate(offset) children();
	}
}

module banana_spacer() {
	round_spacer(nna_d, 3, nna_h);
	translate([0, 0, -1.2])
	round_spacer(nna_d, (9.2 - nna_d) / 2, nna_h, $fn=hfn);
}

module pot_spacer() { 
	round_spacer(pot_d, 3, pot_h);
}

module switch_spacer() {
	linear_extrude(4.5) 
	difference() {
		rr([5.1 + 2 * wt, 6.1 + 2 * wt], r=1.35);
		rr([5.1, 6.1], r=0.5);
	}
}

module rr(s, r) {
	translate([-s.x / 2 + r, -s.y / 2 + r])
	hul([0, s.y - r * 2]) 
	hul([s.x - r * 2, 0])
	circle(r=r, $fn=4);
}

translate(g(0, 1))
do(8, 4, in(1), in(1))
banana_spacer();

translate(g(0, 0))
do(8, 2, in(1), in(5))
pot_spacer();

translate(g(0.5, 0.5))
do(4, 2, in(2), in(4))
switch_spacer();

for(x = [0: 6])
for(y = [0: 5])
translate([in(x) + (in(1) - 15) / 2, in(y) - wt / 2, 0])
cube([15, wt, pot_h]);

for(x = [0: 7])
for(y = [0: 4])
translate([in(x) - wt / 2, in(y) + in(0.5) - 15 / 2, 0])
cube([wt, 15, pot_h]);

for(x = [0: 3])
for(y = [0: 1])
for(q = [0: 3])
translate([in(x * 2), in(y * 4), 0])
rotate([0, 0, q * 90])
translate([
	in(q == 2 || q == 3 ? -1 : 0),
	in(q == 1 || q == 2 ? -1 : 0),
	0
])
translate([4, 4, 0])
rotate([0, 0, -45])
translate([-wt / 2, 0, 0])
cube([wt, 8, pot_h]);

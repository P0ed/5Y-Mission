$fn = 8;
hfn = 48;

wt = 1.2;
sw_h = 13.9;
pot_h = sw_h - 8.9;
nna_h = 14 - 6.5;

nna_d = 6.7;
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

translate(g(0, 1))
do(8, 4, in(1), in(1))
banana_spacer();

translate(g(0, 0))
do(8, 2, in(1), in(5))
pot_spacer();

for(x = [0: 6])
for(y = [0: 5])
translate([in(x) + (in(1) - 15) / 2, in(y) - wt / 2, 0])
cube([15, wt, pot_h]);

for(x = [0: 7])
for(y = [0: 4])
translate([in(x) - wt / 2, in(y) + in(0.5) - 15 / 2, 0])
cube([wt, 15, pot_h]);

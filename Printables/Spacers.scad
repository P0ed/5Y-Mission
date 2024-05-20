$fn = 8;
hfn = 48;

sw_h = 13.1 - 3.5;
h = sw_h + 1;
sw_d = 6.3;
nna_d = 6.8;
pot_d = 10.0;
nna_h = 4.2;

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
	
module border(delta) {
	difference() {
		children();
		offset(delta = -delta) children();
	}
}

module line(start, end, thickness = 1) {
	translate(start) hul([end.x - start.x, end.y - start.y]) circle(thickness);
}

module banana_spacer() { round_spacer(nna_d, 3.3, nna_h); }

translate(g(0, 1))
do(4, 4, in(1), in(1))
banana_spacer();

//translate(g(0, 1))
//do(3, 3, in(1), in(1))
//for(a = [0: 1])
//translate([a * in(1), 0, 0])
//rotate([0, 0, 45 + 90 * a])
//translate([7 / 2, -1.5 / 2, 0])
//cube([sqrt(2) * in(1) - 7, 1.5, nna_h]);

translate(g(0, 1))
for(x = [0: 3]) for(y = [0: 2])
translate([in(x), in(y), 0])
translate([-1.5 / 2, 7 / 2, 0])
cube([1.5, in(1) - 7, nna_h]);

translate(g(0, 1))
for(x = [0: 2]) for(y = [0: 3])
translate([in(x), in(y), 0])
translate([7 / 2, -1.5 / 2, 0])
cube([in(1) - 7, 1.5, nna_h]);

module pot_spacer() { round_spacer(pot_d, 3.3, 1.9); }

translate(g(0, 0))
do(4, 2, in(1), in(5))
pot_spacer();

for(k = [0: 2])
for(y = [0: 1])
translate([k * in(1) + (in(1) - 15) / 2, y * in(5) - 2.2 / 2, 0])
cube([15, 2.2, 1.9]);


module sw_spacer() { round_spacer(sw_d, 2.2, 1); }

translate(g(0.5, 0.5))
do(2, 2, in(2), in(4))
sw_spacer();

for(k = [0: 1])
for(j = [0: 1])
for(y = [0: 1])
translate([k * in(1) + j * in(2), y * in(5), 0])
rotate([0, 0, 45 + k * 90 + y * -90 + y * k * 180])
translate([5, -3 / 2, 0])
cube([sqrt(2) * in(0.5) - pot_d / 2 - sw_d / 2, 3, 1]);


for(k = [0: 1])
for(j = [0: 1])
for(y = [0: 1])
translate([in(k + j * 2), in(1 + y * 3), 0])
rotate([0, 0, -45 + k * -90 + y * 90 + y * k * 180])
translate([5, -1 / 2, 0])
cube([sqrt(2) * in(0.5) - pot_d / 2 - sw_d / 2, 1, 1]);

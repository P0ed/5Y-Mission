$fn = 64;

function in(x) = x * 25.4;

bx = in(1);
by = in(1);

wm = 4;
w = in(17 / 4 * wm);
h = in(7);
hx = 9;
hy = in(0.25);

dx = (w - bx * (wm * 4 - 1)) / 2;
dy = (h - by * 5) / 2;

function gx(x) = bx * x + dx;
function gy(y) = by * y + dy;
function grid(x, y) = [gx(x), gy(y)];

module do(cx, cy, sx = 1, sy = 1) {
	for (x = [0 : cx - 1]) {
		for (y = [0 : cy - 1]) {
			translate([bx * x * sx, by * y * sy]) children();
		}
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

module bipolar(x, y) {

	module side() {
		difference() {
			translate([0, -1.5]) circle(9);
			circle(7.25);
			translate([-1.25, -10]) square([20, 20]);
			line([-1.3, -8.8], [1.3, -8.8], 3.4);
		}
	}

	translate(grid(x, y)) {
		border(0.25) side();
		mirror([1, 0]) side();
	}
}

module M3() { circle(d = 3.2); }
module Button() { circle(d = 5.4); }
module LED() { circle(d = 5.1); }
module Banana() { circle(d = 9.6); }

module roundRect(w, h, r) {
	hull() {
		translate([r, r]) circle(d = r * 2);
		translate([r, h - r]) circle(d = r * 2);
		translate([w - r, r]) circle(d = r * 2);
		translate([w - r, h - r]) circle(d = r * 2);
	}
}

module 4holes(w, h, hx = 0) {
	translate([w / 2, h / 2]) hul([-hx, 0]) children();
	translate([-w / 2, h / 2]) hul([hx, 0]) children();
	translate([w / 2, -h / 2]) hul([-hx, 0]) children();
	translate([-w / 2, -h / 2]) hul([hx, 0]) children();
}

module Panel() {

	difference() {
		roundRect(w, h, 1);
		
		do(wm, 1, 4, 1) {
			do(4, 6) {
				translate(grid(0, 0)) Banana();
			}
			do(3, 2, 1, 3) {
				translate(grid(0.5, 0.5)) Button();
			}
			do(1, 2, 1, 3) {
				translate(grid(1.5, 1.5)) LED();
			}
		}

		translate([w / 2, h / 2]) {
			4holes(w - hx * 2, h - hy * 2) M3();
			4holes(0, h - hy * 2) M3();
		}
	}
}

linear_extrude(2)
Panel();

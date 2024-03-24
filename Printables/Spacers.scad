$fn = 256;

sw_h = 13.1;

function in(x) = x * 25.4;

dx = 0;
dy = 0;

function gx(x) = in(1) * x + dx;
function gy(y) = in(1) * y + dy;
function grid(x, y) = [gx(x), gy(y)];

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
		circle(d=d);
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

module round_rect(w, h, r) {
	hull() {
		translate([r, r]) circle(d = r * 2);
		translate([r, h - r]) circle(d = r * 2);
		translate([w - r, r]) circle(d = r * 2);
		translate([w - r, h - r]) circle(d = r * 2);
	}
}

module M3() { circle(d = 3.2); }
module Button() { circle(d = 5.4); }
module LED() { circle(d = 5.1); }
module Banana() { circle(d = 9.6); }

module pot_spacer() {
	difference() {
		round_spacer(9.6, 4, sw_h - 10);
		translate([-1, -10, sw_h - 10 - 1.39]) linear_extrude(1.4) square([2, 20]);
	}
}
module banana_spacer() { round_spacer(6.5, 3, sw_h - 6.5); }
module led_spacer() { round_spacer(5.1, 1.8, 3); }

// 32
pot_spacer();
// 64
!banana_spacer();
// 8
led_spacer();

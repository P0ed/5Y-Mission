$fn = 24;
hq = 24;
vhq = 48;

w = in(17 / 4);
h = in(7);
hx = 9;
hy = 6.5;

dx = (w - in(1) * 3) / 2;
dy = (h - in(1) * 5) / 2;

pt = 3.3;
wt = 1.2;
pl = 0.01;


sw_h = 13.1;
sws_h = 3.5;
pot_h = sw_h - 8.9;		// 4.2
nna_h = 6.6;			// 13.1 - 6.5

sw_d = 6.2;
nna_d = 6.5;
pot_d = 9.7;


function in(x) = x * 25.4;

function gx(x) = in(1) * x;
function gy(x) = in(1) * x;
function g(x, y) = [gx(x), gy(y), 0];

function gxx(x) = in(1) * x + dx;
function gxy(y) = in(1) * y + dy;
function grid(x, y) = [gxx(x), gxy(y)];

module do(cx, cy, sx, sy) {
	for (x = [0 : cx - 1]) {
		for (y = [0 : cy - 1]) {
			translate([x * sx, y * sy]) children();
		}
	}
}

//////////////////////////////////////////////////////////////////

	
module border(delta) {
	difference() {
		children();
		offset(delta = -delta) children();
	}
}

module M3() { circle(d = 3.2, $fn=hq); }
module Button() { 
	swh_w = 3.6;
	translate([0, -(sw_d - swh_w) / 2])
	hul([0, sw_d - swh_w])
	circle(d=swh_w, $fn=22);
}
module LED() { circle(d = 5.0, $fn=hq); }
module Banana() { circle(d = pot_d, $fn=hq); }

module 4holes(w, h, hx = 0) {
	translate([w / 2, h / 2]) hul([-hx, 0]) children();
	translate([-w / 2, h / 2]) hul([hx, 0]) children();
	translate([w / 2, -h / 2]) hul([-hx, 0]) children();
	translate([-w / 2, -h / 2]) hul([hx, 0]) children();
}

module Panel() {
	difference() {
		linear_extrude(pt)
		difference() {
			square([w, h]);
			
			do(1, 1, in(4), in(1)) {
				do(4, 2, in(1), in(5)) {
					translate(grid(0, 0)) Banana();
				}
				do(2, 2, in(2), in(4)) {
					translate(grid(0.5, 0.5)) Button();
				}
				do(2, 2, in(2), in(2)) {
					translate(grid(0.5, 1.5)) LED();
				}
			}

			translate([w / 2, h / 2]) {
				4holes(w - hx * 2, h - hy * 2) M3();
			}
		}
		
		do(2, 2, in(2), in(4)) {
			translate([0, 0, sws_h])
			translate(grid(0.5, 0.5)) 
			linear_extrude(wt)
			circle(d=sw_d);
		}
		
		do(1, 7, 0, in(1))
		translate([-1, in(0.5), -pl])
		linear_extrude(wt, scale=[1, 0.68])
		translate([0, -wt / 2])
		square([110, wt]);
		
		do(5, 1, in(1), 0)
		translate([in(0.125), in(0.5), -pl])
		linear_extrude(wt, scale=[0.68, 1])
		translate([-wt / 2, 0])
		square([wt, in(6)]);

		cnt = 6;
		do(4, 2, in(1), in(5))
		translate([in(0.625), in(1), -pl])
		for(i=[0: cnt - 1])
		translate([0, 0, i * 1.5 / cnt])
		linear_extrude(
			1.5 / cnt + pl,
			scale=1 - 0.015 * exp(1.1 * i / cnt)
		)
		circle(r=12.4 - exp(0.4 + i * 1.3 / cnt), $fn=vhq);

		do(4, 6, in(1), in(1))
		translate([in(0.625), in(1), -pl]) {
			linear_extrude(wt + pl * 2)
			circle(r=6.4, $fn=vhq);

			translate([0, 0, wt])
			linear_extrude(2.1 + pl * 2)
			circle(r=nna_d/2, $fn=hq);

			translate([0, 0, wt])
			linear_extrude(0.6 + pl * 2)
			circle(r=pot_d/2, $fn=hq);
		}

		translate([w / 2, h / 2, -pl])
		linear_extrude(pt - 2)
		4holes(w - hx * 2, h - hy * 2)
		circle(d=6.1);
	}
}


//////////////////////////////////////////////////////////////////

module round_spacer(d, w, h, s=1) {
	difference() {
		union() {
			children();
		
			linear_extrude(h, scale=s)
			circle(d=d + w * 2 / s, $fn=hq);
		}
		
		translate([0, 0, -pl])
		linear_extrude(h + pl * 2)
		circle(d=d, $fn=hq);
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
	translate(start) hul([end.x - start.x, end.y - start.y])
	circle(thickness);
}


module banana_spacer() { 
	round_spacer(nna_d, 3, nna_h, 0.75);
}


module pot_spacer() { 
	round_spacer(pot_d, 3, pot_h, 0.7);
}


module sw_spacer() {
	round_spacer(sw_d, 1.5, sws_h, 0.9);
}

module cut(s=[in(10), in(10), in(10)]) {
	intersection() {
		children();
		translate([-s.x, -s.y / 2, -s.z / 2])
		cube(s);
	}
}

//cut()
rotate([180, 0, 0]) {
	translate([-in(1.25 / 2), -in(2 / 2), wt-pt])
	Panel();
	
	translate(g(0, 1))
	do(4, 4, in(1), in(1))
	banana_spacer();

	translate(g(0, 0))
	do(4, 2, in(1), in(5))
	pot_spacer();
				
	translate(g(0.5, 0.5))
	do(2, 2, in(2), in(4))
	sw_spacer();
}


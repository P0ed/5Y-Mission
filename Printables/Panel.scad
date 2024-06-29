s = 3;
$fn = 24 / s;
hq = 24 / s;
vhq = 48 / s;

w = in(17 / 2);
h = in(7);
hx = 9;
hy = 6.5;

dx = (w - in(1) * 7) / 2;
dy = (h - in(1) * 5) / 2;

pt = 3.5;
wt = 1.2;
pl = 0.01;


sw_h = 13.1;
sws_h = 3.5;
pot_h = sw_h - 8.9;		// 4.2
nna_h = 6.6;			// 13.1 - 6.5


sw = [5.2, 6.2];
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
module LED() { 
	translate([-sw.x / 2, -sw.y / 2])
	hul([sw.x, 0])
	hul([0, sw.y])
	circle(0.5, $fn=4);
}
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
				do(8, 2, in(1), in(5)) {
					translate(grid(0, 0)) Banana();
				}
				do(4, 2, in(2), in(4)) {
					translate(grid(0.5, 0.5)) LED();
				}
				do(4, 2, in(2), in(2)) {
					translate(grid(0.5, 1.5)) LED();
				}
			}

			translate([w / 2, h / 2]) {
				4holes(w - hx * 2, h - hy * 2) M3();
			}
		}
		
		do(4, 2, in(2), in(4)) {
			translate([0, 0, sws_h])
			translate(grid(0.5, 0.5)) 
			linear_extrude(wt)
			circle(d=sw_d);
		}
		
		do(1, 7, 0, in(1))
		translate([-1, in(0.5), -pl])
		linear_extrude(wt, scale=[1, 0.68])
		translate([0, -wt / 2])
		square([w + 2, wt]);
		
		do(9, 1, in(1), 0)
		translate([in(0.25), in(0.5), -pl])
		linear_extrude(wt, scale=[0.68, 1])
		translate([-wt / 2, 0])
		square([wt, in(6)]);

		cnt = 6;
		do(8, 2, in(1), in(5))
		translate([in(0.75), in(1), -pl])
		for(i=[0: cnt - 1])
		translate([0, 0, i * 1.5 / cnt])
		linear_extrude(
			1.5 / cnt + pl,
			scale=1 - 0.015 * exp(1.1 * i / cnt)
		)
		circle(r=12.4 - exp(0.4 + i * 1.3 / cnt), $fn=vhq);

		translate([in(0.75), in(1), -pl])
		do(8, 6, in(1), in(1)) {
			linear_extrude(pt + pl * 2)
			circle(r=nna_d/2, $fn=hq);

			linear_extrude(0.8 + pl * 2)
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

module banana_spacer() { 
	round_spacer(nna_d, 3, nna_h, 0.75);
}


module pot_spacer() { 
	round_spacer(pot_d, 3, pot_h, 0.7);
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
	translate([-in(1.5 / 2), -in(2 / 2), wt-pt])
	Panel();
	
	translate(g(0, 1))
	do(8, 4, in(1), in(1))
	banana_spacer();

	translate(g(0, 0))
	do(8, 2, in(1), in(5))
	pot_spacer();
}


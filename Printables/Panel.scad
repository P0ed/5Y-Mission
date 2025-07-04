include <2d.scad>

hq = 24;
vhq = 48;
$fn = hq;

w = in(8.5);
h = in(7);
hx = 9;
hy = 6.5;

dx = (w - in(1) * 7) / 2;
dy = (h - in(1) * 5) / 2;

pt = 2;
wt = 0.5;
pl = 0.01;


sw_h = 13.9;
sws_h = 3.5;
pot_h = sw_h - 8.9;


sw = [5.2, 6.2];
sw_d = 6.2;
nna_d = 9.53 + 0.1;
pot_d = 9.53 + 0.2;


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

module A12() { 
	translate([-sw.x / 2, -sw.y / 2])
	hul([sw.x, 0])
	hul([0, sw.y])
	circle(0.5, $fn=4);
}

module SW() {
	circle(d=6.5, $fn=hq);
}

module Banana() {
	circle(d = pot_d, $fn=hq);
}

module 4holes(w, h) {
	translate([w / 2, h / 2]) children();
	translate([-w / 2, h / 2]) children();
	translate([w / 2, -h / 2]) children();
	translate([-w / 2, -h / 2]) children();
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
					translate(grid(0.5, 0.5)) SW();
				}
				do(4, 2, in(2), in(2)) {
					translate(grid(0.5, 1.5)) LED5();
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

		//cut_grid();

		translate([in(0.75), in(1), -pl])
		do(8, 6, in(1), in(1)) {
			linear_extrude(pt + pl * 2)
			circle(d=nna_d, $fn=hq);
		}
	}
}

module cut_grid() {
	do(1, 7, 0, in(1))
	translate([-1, in(0.5), -pl])
	linear_extrude(wt, scale=[1, 0.54])
	translate([0, -wt * 2 / 2])
	square([w + 2, wt * 2]);
	
	do(9, 1, in(1), 0)
	translate([in(0.25), in(0.5), -pl])
	linear_extrude(wt, scale=[0.54, 1])
	translate([-wt * 2 / 2, 0])
	square([wt * 2, in(6)]);
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

module border(delta) {
	difference() {
		children();
		offset(delta = -delta) children();
	}
}

module banana_spacer() { 
	round_spacer(nna_d, 2, 2, 0.9);
}


module pot_spacer() { 
	
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
	translate([0, 0, -pt])
	Panel();

	translate([0, 0, -pl])
	translate(g(0.75, 2))
	do(8, 4, in(1), in(1))
	banana_spacer();

//	translate(g(0, 0))
//	do(8, 2, in(1), in(5))
//	pot_spacer();
}


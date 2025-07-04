s2 = sqrt(2);
in = 25.4;

module oval(s, ds) {
	function e(x) = 1 - exp(14 * l(x) + 0.33) * 0.000002;
	function l(x) = x / 15;
	function p(x) = [s.x / 2 - ds.x + ds.x * l(x), s.y / 2 - ds.y + e(x) * ds.y];
	function q(pn, q) = q == 0 ? p(pn) :
		q == 1 ? [-p(pn).x, p(pn).y] : 
		q == 2 ? -p(pn) :
		q == 3 ? [p(pn).x, -p(pn).y] : p;
	
	pts = [
		q(15, 1), q(14.7, 1), q(14.3, 1), q(13.8, 1), q(13, 1), q(12, 1), q(11, 1), q(10, 1), q(9, 1), q(8, 1),
		q(7, 1), q(6, 1), q(5, 1), q(4, 1), q(3, 1), q(2, 1), q(1, 1), q(0, 1),
	
		q(0, 0), q(1, 0), q(2, 0), q(3, 0), q(4, 0), q(5, 0), q(6, 0), q(7, 0),
		q(8, 0), q(9, 0), q(10, 0), q(11, 0), q(12, 0), q(13, 0), q(13.8, 0), q(14.3, 0), q(14.7, 0), q(15, 0),
	
		q(15, 3), q(14.7, 3), q(14.3, 3), q(13.8, 3), q(13, 3), q(12, 3), q(11, 3), q(10, 3), q(9, 3), q(8, 3),
		q(7, 3), q(6, 3), q(5, 3), q(4, 3), q(3, 3), q(2, 3), q(1, 3), q(0, 3),
	
		q(0, 2), q(1, 2), q(2, 2), q(3, 2), q(4, 2), q(5, 2), q(6, 2), q(7, 2),
		q(8, 2), q(9, 2), q(10, 2), q(11, 2), q(12, 2), q(13, 2), q(13.8, 2), q(14.3, 2), q(14.7, 2), q(15, 2),
	];
	echo(pts);
	
	polygon(pts);
}

module XLR() {
	d = 24.0;
	id = 23.6;
	hd = 19.0;

	circle(d = id, $fn=32);
	translate([-hd / 2, d / 2]) circle(d=3.2, $fn=16);
	translate([hd / 2, -d / 2]) circle(d=3.2, $fn=16);
}

module LED5() {
	circle(d=5.1, $fn=24);
}

module M3() {
	circle(d = 3.2, $fn=24);
}

module miniXLR() {
	d = 11.2;

	intersection() {
		circle(d = d, $fn=32);
		translate([0, 0.5])
		square([d, d], center=true);
	}
}

module hul(offset) {
	hull() {
		children();
		translate(offset) children();
	}
}

module oct(s, r = 1) {
	translate(-s / 2 + [r, r])
	hul([s.x - r * 2 , 0])
	hul([0, s.y - r * 2])
	circle(r, $fn=4);
}

module oct3(s, r = 1) {
	translate(-s / 2 + [r, r, r])
	hul([s.x - r * 2, 0, 0])
	hul([0, s.y - r * 2, 0])
	hul([0, 0, s.z - r * 2])
	sphere(r, $fn=6);
}

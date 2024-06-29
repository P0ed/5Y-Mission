$fn = 48;

in = 25.4;
wall = 2;
rail = [3, 10];
dh = [9, 6.5];

ps = [4.25 * in, 7 * in];
mc = 2;
s = [ps.x * mc, ps.y, 40];

dx = 0.01;
m3 = 3.2;

module nut_mount(wall=1.2) {
	sns = [7, 7, 2];
	
	difference() {
		translate([-sns.x / 2 - wall, -sns.y / 2, -sns.z - wall])
		cube([sns.x + wall * 2, sns.y + wall, sns.z + wall + dx]);
		
		translate([-sns.x / 2 - dx, -sns.y / 2 - dx, dx - sns.z])
		cube(sns);
	
		translate([0, 0, -sns.z - wall - dx])
		cylinder(h = sns.z + wall * 2 + dx * 2, r = m3 / 2);
	}
}

module box(s) {
	difference() {
		cube(s);
		
		translate([wall, wall, wall])
		cube([s.x - wall * 2, s.y - wall * 2, s.z - wall * 2]);
		
		translate([rail.x, rail.y, s.z - wall - dx])
		cube([s.x - rail.x * 2, s.y - rail.y * 2, wall + dx * 2]);
		
		for(i = [0: mc - 1]) {
			translate([(i + 1) * ps.x - dh.x, ps.y - dh.y, s.z - wall - dx])
			cylinder(h = wall + dx * 2, r = m3 / 2);
			
			translate([i * ps.x + dh.x, ps.y - dh.y, s.z - wall - dx])
			cylinder(h = wall + dx * 2, r = m3 / 2);
			
			translate([(i + 1) * ps.x - dh.x, dh.y, s.z - wall - dx])
			cylinder(h = wall + dx * 2, r = m3 / 2);
			
			translate([i * ps.x + dh.x, dh.y, s.z - wall - dx])
			cylinder(h = wall + dx * 2, r = m3 / 2);
		}
	}
	
	for(i = [0: mc - 1]) {
		translate([(i + 1) * ps.x - dh.x, ps.y - dh.y, s.z - wall - dx])
		nut_mount();
		
		translate([i * ps.x + dh.x, ps.y - dh.y, s.z - wall - dx])
		nut_mount();
		
		translate([(i + 1) * ps.x - dh.x, dh.y, s.z - wall - dx])
		rotate(180)
		nut_mount();
		
		translate([i * ps.x + dh.x, dh.y, s.z - wall - dx])
		rotate(180)
		nut_mount();
	}
}

module hul(offset) {
	hull() {
		children();
		translate(offset) children();
	}
}

module ul() {
	difference() {
		children();
		
		cnt = 6;
		for(x=[0: 5])
		for(z=[0: cnt - 1])
		translate([
			x * s.x * 3 / 19 + s.x * 2 / 19,
			s.y * 5 / 24,
			wall + dx - (z + 1) * (wall - 1.2) / cnt
		])
		hul([0, s.y * 7 / 12, 0])
		rotate([0, 0, 180 - 180 * x])
		linear_extrude((wall - 1.2) / cnt + dx)
		circle(s.z / 5 - exp(0.5 + 2 * z / cnt), $fn=6);
		
		for(x=[0: 1])
		for(z=[0: cnt - 1])
		translate([
			wall + x * (s.x - wall * 2) - (1 - x * 2) * (z + 1) * (wall - 1.2) / cnt,
			s.y * 5 / 24,
			wall + s.z / 2
		])
		rotate([0, 90 - 180 * x, 0])
		hul([0, s.y * 7 / 12, 0])
		rotate([0, 0, 180 - 180 * x])
		linear_extrude((wall - 1.2) / cnt + dx)
		circle(s.z / 5 - exp(0.5 + 2 * z / cnt), $fn=6);
	}
}

module cut(c, r, t, dt = [0, 0, 0], rr=[0,0,0]) {
	difference() {
		
		union() {
			children();
			
			translate(t)
			rotate(rr)
			rotate(r)
			cube(c);
		}

		translate(dt)
		translate(t)
		rotate(rr)
		rotate(r)
		translate([-dx, -dx, -dx])
		cube([c.x + dx * 2, c.y + dx * 2, c.z + dx * 2]);
	}
}

module hole() {
	difference() {
		children();
		
		translate([20, s.y - 3.5, 3.5])
		rotate([45])
		cylinder(d=5, h=6, $fn=10);
		
		translate([20 - 3.8, s.y - 3, 3])
		rotate([0, -90, 180])
		rotate([0, 45, 45])
		cylinder(d=5, h=10, $fn=10);
		
		for(x=[0: 1])
		translate([40, s.y - 5 + x * 3, 2 + x * 3])
		rotate([45])
		hul([4, 0])
		cylinder(d=2.4, h=6, $fn=10);
	}
}

module cuts() {
	cut([xs, ss, xs], [0, 45, 0], [-s2 * xs, 0, s2 * ss], rr=[-45, 0, 0])
	cut([xs, ss, xs], [0, 45, 0], [s.x - s2 * xs, 0, s2 * ss], rr=[-45, 0, 0])
	cut([xs, ss, xs], [0, 45, 0], [-s2 * xs, s.y, s2 * ss], rr=[-135, 0, 0])
	cut([xs, ss, xs], [0, 45, 0], [s.x - s2 * xs, s.y, s2 * ss], rr=[-135, 0, 0])
	
	cut([xs, s.y, xs], [0, 45, 0], [-s2 * xs, 0, 0])
	cut([xs, s.y, xs], [0, 45, 0], [s.x - s2 * xs, 0, 0])
	
	cut([xs, xs, s.z], [0, 0, -45], [-s2 * xs, 0, 0], [0, 0, 0])
	cut([xs, xs, s.z], [0, 0, -45], [s.x + -s2 * xs, 0, 0], [0, 0, 0])
	cut([xs, xs, s.z], [0, 0, -45], [s.x + -s2 * xs, s.y, 0], [0, 0, 0])
	cut([xs, xs, s.z], [0, 0, -45], [-s2 * xs, s.y, 0], [0, 0, 0])

	cut([s.x, ss, ss], [45, 0, 0], [0, s.y - 2, 2 - s2 * ss], [0, 2, -2])
	cut([s.x, ss, ss], [45, 0, 0], [0, 2, 2 - s2 * ss], [0, -2, -2])

	children();
}

s2 = sqrt(2) / 2;
ss = 13;
xs = 1;

translate([-s.x / 2, -s.y / 2])
hole()
ul()
cuts()
box(s);

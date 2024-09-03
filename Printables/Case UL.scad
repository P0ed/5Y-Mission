$fn = 48;

in = 25.4;
dx = 0.01;

wall = 2;
rail = [3, 10];
rw = 6;
dh = [9, 6.5];
sns = [7 + dx, 7 + dx, 2];

ps = [4.25 * in, 7 * in];
mc = 2;
s = [ps.x * mc, ps.y, 40];

m3 = 3.2;


module nut_cut() {
	translate([0, 0, -sns.z - wall - dx])
	cylinder(h = wall * 2 + sns.z + dx * 2, r = m3 / 2);
	
	translate([-sns.x / 2 - dx, -sns.y / 2 - dx, -sns.z - dx])
	cube([sns.x + dx * 2, sns.y + dx * 2, sns.z + dx * 2]);
}

module nut_mount() {
	difference() {
		translate([-sns.x / 2 - wall, -sns.y / 2, -sns.z - wall])
		cube([sns.x + wall * 2, sns.y + wall, sns.z + wall * 2]);
		
		nut_cut();
	}
}

module box(s) {
	difference() {
		cube(s);
		
		translate([wall, rw, rw])
		cube([s.x - wall * 2, s.y - rw * 2, s.z - rw * 2]);
		
		translate([rw / 2 + s.x / 2, wall, rw])
		cube([s.x / 2 - rw * 1.5, s.y - wall * 2, s.z - rw * 2]);
		
		translate([rw, wall, rw])
		cube([s.x / 2 - rw * 1.5, s.y - wall * 2, s.z - rw * 2]);
		
		translate([rail.x, rail.y, -dx])
		cube([s.x - rail.x * 2, s.y - rail.y * 2, s.z + dx * 2]);
		
		for(z = [0: 1])
		for(i = [0: mc - 1]) {
			dz = z ? s.z - wall : wall + sns.z;
			translate([(i + 1) * ps.x - dh.x, ps.y - dh.y, dz])
			nut_cut();
			
			translate([i * ps.x + dh.x, ps.y - dh.y, dz])
			nut_cut();
			
			translate([(i + 1) * ps.x - dh.x, dh.y, dz])
			nut_cut();
			
			translate([i * ps.x + dh.x, dh.y, dz])
			nut_cut();
		}
	}
	
	for(z = [0: 1])
	for(i = [0: mc - 1]) {
		dz = (z ? s.z - wall : wall + sns.z) - dx;
		translate([(i + 1) * ps.x - dh.x, ps.y - dh.y, dz])
		nut_mount();
		
		translate([i * ps.x + dh.x, ps.y - dh.y, dz])
		nut_mount();
		
		translate([(i + 1) * ps.x - dh.x, dh.y, dz])
		rotate(180)
		nut_mount();
		
		translate([i * ps.x + dh.x, dh.y, dz])
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
		
		translate([s.x / 8, s.y - wall * 1.5, s.z / 2])
		rotate([-90])
		rotate([0, 0, 90])
		cylinder(d=5, h=wall * 2, $fn=24);
		
		translate([s.x / 8, s.y - wall / 2, s.z / 2])
		rotate([0, 0, -60])
		translate([5, 0, 0])
		rotate([0, -90, 0])
		cylinder(d=5, h=10, $fn=24);
		
		#for(x=[0: 1])
		translate([s.x * 2 / 8, s.y - wall * 1.5, s.z / 2 - 2.5 + x * 5])
		rotate([-90])
		hul([4, 0])
		cylinder(d=2.4, h=wall * 2, $fn=24);
	}
}

module cuts() {
	cut([xs, xs, s.z], [0, 0, -45], [-s2 * xs, 0, 0], [0, 0, 0])
	cut([xs, xs, s.z], [0, 0, -45], [s.x + -s2 * xs, 0, 0], [0, 0, 0])
	cut([xs, xs, s.z], [0, 0, -45], [s.x + -s2 * xs, s.y, 0], [0, 0, 0])
	cut([xs, xs, s.z], [0, 0, -45], [-s2 * xs, s.y, 0], [0, 0, 0])
	children();
}

s2 = sqrt(2) / 2;
ss = 13;
xs = 1;

translate([-s.x / 2, -s.y / 2])
hole()
cuts()
box(s);

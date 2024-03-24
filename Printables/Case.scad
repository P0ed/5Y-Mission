$fn = 48;

in = 25.4;
wall = 2;
rail = [3, 10];
dh = [9, 6.5];

ps = [4.25 * in, 7 * in];
mc = 3;
s = [ps.x * mc, ps.y, 40];

dx = 0.01;
m3 = 3.2;

module nut_mount() {
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
	
	for (i = [1: mc - 1])
	translate([ps.x * i - wall / 2, 0, 0])
	difference() {
		cube([wall, s.y, s.z]);
		translate([-dx, wall * 2, wall * 2])
		cube([wall + dx * 2, s.y - wall * 4, s.z]);
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

box(s);

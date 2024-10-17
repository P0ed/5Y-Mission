$fn = 48;

in = 25.4;
dx = 0.01;

wall = 3.5;
wal = 2;
rail = [8.5, 0];
rw = 6;
dh = [3, 7.5];
sns = [6.5 + dx, 6.5 + dx, 2];

ps = [128.5, 3 * in];
mc = 1;
s = [ps.x * mc, ps.y, 42];
ms = [s.x, s.y + 2 * in, s.z];
wo = [0, -0.5 * in, 0];
id = [0, 0, 0];

m3 = 3.2;


module nut_cut() {
	wal = 2;
	translate([0, 0, -sns.z - wal - dx])
	cylinder(h = wall * 2 + sns.z + dx * 2, r = m3 / 2);
	
	translate([-sns.x / 2 - dx, -sns.y / 2 - dx, -sns.z - dx])
	cube([sns.x + dx * 2, sns.y + dx * 2, sns.z + dx * 2]);
}

module nut_mount() {
	difference() {
		translate([-sns.x / 2 - wal, -sns.y / 2 + sns.y / 2 - dh.x, -sns.z - wal])
		cube([sns.x + wal * 2, sns.y + wal, sns.z + wal * 2]);
		
		nut_cut();
	}
}

module box(s) {
	difference() {
		translate(wo)
		cube(ms);
		
		// window
		translate([rail.x, rail.y, s.z - wall - dx])
		cube([s.x - rail.x * 2, s.y - rail.y * 2, s.z + dx * 2]);
			
		// volume
		translate(wo)
		translate([wall, wall, wall])
		cube([ms.x - wall * 2, ms.y - wall * 2, ms.z - wall * 2]);
		
		for(i = [0: mc - 1]) {
			dz = s.z - wal;
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
	
	for(i = [0: mc - 1]) {
		dz = s.z - wal;
		translate([(i + 1) * ps.x - dh.x, ps.y - dh.y, dz])
		rotate(90)
		nut_mount();
		
		translate([i * ps.x + dh.x, ps.y - dh.y, dz])
		rotate(-90)
		nut_mount();
		
		translate([(i + 1) * ps.x - dh.x, dh.y, dz])
		rotate(90)
		nut_mount();
		
		translate([i * ps.x + dh.x, dh.y, dz])
		rotate(-90)
		nut_mount();
	}
}

module hul(offset) {
	hull() {
		children();
		translate(offset) children();
	}
}

module hole() {
	
	module XLR() {
		d = 24.0;
		id = 23.6;
		hd = 19.0;
		
		circle(d = id);
		translate([-hd / 2, d / 2]) circle(d=m3);
		translate([hd / 2, -d / 2]) circle(d=m3);
	}
	
	difference() {
		children();
		
		for(i = [0: 2]) {
			sp = 35;
			translate([i * sp + ms.x / 2 - sp, ms.y - wall - dx, ms.z / 2])
			translate(wo)
			rotate([0, 0, 180])
			rotate([0, 90, -90])
			rotate([0, 0, 90])
			linear_extrude(wall + dx * 2)
			XLR();
		}
	}
}

module cut(c, r, t, dt=id, rr=id, hl=id, prehl=id) {
	difference() {
		
		union() {
			children();
			
			hul(hl)
			translate(t)
			rotate(rr)
			hul(prehl)
			rotate(r)
			cube(c);
		}

		translate(dt)
		hul(hl)
		translate(t)
		rotate(rr)
		hul(prehl)
		rotate(r)
		translate([-dx, -dx, -dx])
		cube([c.x + dx * 2, c.y + dx * 2, c.z + dx * 2]);
	}
}

module cuts() {
	hull_len = 15;
	xs = 2.2;
	dw = 3.3;
	zs = dw / s2;
	
	cut([xs, xs, ms.z], [0, 0, -45], [-s2 * xs, wo.y, 0])
	cut([xs, xs, ms.z], [0, 0, -45], [s.x + -s2 * xs, wo.y, 0])
	cut([xs, xs, ms.z], [0, 0, -45], [s.x + -s2 * xs, ms.y + wo.y, 0])
	cut([xs, xs, ms.z], [0, 0, -45], [-s2 * xs, ms.y + wo.y, 0])
	
	cut([ms.x, xs, xs], [45, 0, 0], [0, wo.y, -s2 * xs])
	cut([ms.x, xs, xs], [45, 0, 0], [0, ms.y + wo.y, -s2 * xs])
	cut([ms.x, xs, xs], [45, 0, 0], [0, wo.y, -s2 * xs + ms.z])
	cut([ms.x, xs, xs], [45, 0, 0], [0, ms.y + wo.y, -s2 * xs + ms.z])
	
	// io
	cut(
		[ms.x - 3 * dw, xs, xs],
		id,
		[dw * 3 / 2, ms.y + wo.y - xs, dw],
		hl=[0, 0, ms.z - dw * 2 - xs]
	)
//	
//	// face
//	cut(
//		[ms.x - 2 * dw, xs, xs],
//		[45, 0, 0],
//		[dw, wo.y, -s2 * xs + dw],
//		hl=[0, 0, ms.z - dw * 2]
//	)
//	cut(
//		[ms.x, xs, xs], 
//		[45, 0, 0],
//		[0, wo.y, ms.z / 2 - hull_len / 2 - xs * s2],
//		hl=[0, 0, hull_len]
//	)
	
	// side cuts
	cut(
		[zs, ms.y, zs], 
		[0, 45, 0],
		[-s2 * zs, wo.y, ms.z / 2 - hull_len / 2],
		hl=[0, 0, hull_len]
	)
	// side cuts
	cut(
		[zs, ms.y, zs], 
		[0, 45, 0],
		[-s2 * zs + ms.x, wo.y, ms.z / 2 - hull_len / 2],
		hl=[0, 0, hull_len]
	)
	cut(
		[1, ms.y, 1], 
		[0, 45, 0],
		[-s2 * 1, wo.y, 0],
		[0, 0, 0]
	)
	cut(
		[1, ms.y, 1], 
		[0, 45, 0],
		[-s2 * 1 + ms.x, wo.y, 0],
		[0, 0, 0]
	)
	
	children();
}

s2 = sqrt(2) / 2;
ss = 13;

translate([-s.x / 2, -s.y / 2])
hole()
cuts()
box(s);

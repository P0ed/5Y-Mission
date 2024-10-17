include <2d.scad>

s = [110, 35, 140];
module o() { oval(s, [8, 4]); }

module oring() { 
	difference() {
		scale([(s.x + 7) / s.x, (s.y + 7) / s.y]) o();
		o();
	};
}

hex_mount(e=6.6, m=2.5, t=[6 - s.x / 2, s.y / 2 - 6, s.z - 13.3], r=[0,0,270])
hex_mount(e=6.6, m=2.5, t=[s.x / 2 - 6, s.y / 2 - 6, s.z - 13.3], r=[0,0,90])
hex_mount(e=6.6, m=2.5, t=[6 - s.x / 2, 6 - s.y / 2, s.z - 13.3], r=[0,0,270])
hex_mount(e=6.6, m=2.5, t=[s.x / 2 - 6, 6 - s.y / 2, s.z - 13.3], r=[0,0,90])

hex_mount(e=6.6, m=2.5, t=[-43.5, s.y / 2 - 4.9, 14], r=[90,0,0])
hex_mount(e=6.6, m=2.5, t=[43.5, s.y / 2 - 4.9, 14], r=[90,0,0])
hex_mount(e=6.6, m=2.5, t=[-43.5, s.y / 2 - 4.9, 14 + 3 * 25.4 + 14], r=[90,180,0])
hex_mount(e=6.6, m=2.5, t=[43.5, s.y / 2 - 4.9, 14 + 3 * 25.4 + 14], r=[90,180,0])
cut()
linear_extrude(s.z) oring();

module sq(s) { translate(-s/2) square(s); }

module hul(offset) {
	hull() {
		children();
		translate(offset) children();
	}
}

module cut() {
	difference() {
		union() {
			children();
					
			translate([0, s.y / 2 - 4, 0])
			rotate([90, 0, 180])
			translate([0, 59, 0])
			linear_extrude(5)
			sq([109, 108]);
			
			translate([0, 0, 5])
			linear_extrude(3.5)
			sq([s.x, s.y]);
			
			
			translate([6 - s.x / 2, 0, s.z - 5 - 7])
			linear_extrude(3.5)
			sq([12, s.y]);
			
			translate([s.x / 2 - 6, 0, s.z - 5 - 7])
			linear_extrude(3.5)
			sq([12, s.y]);
			
		}
		
		translate([0, s.y / 2 - 6, 0])
		rotate([90, 0, 180])
		translate([0, 59, 0])
		linear_extrude(12)
		sq([105, 78]);
		
		translate([0, s.y / 2 - 0.08, 0])
		rotate([90, 0, 180])
		translate([0, 59, 0])
		linear_extrude(3.6)
		sq([105, 102]);
	}
}

module hex_mount(m, e, t, r) {
	difference() {
		union() {
			children();
			
			translate(t)
			rotate(r)
			translate(-[0,0, 3.5 + m / 2])
			linear_extrude(m + 7)
			rotate([0,0,45])
			circle(d=e + 7 + 3.3, $fn=4);
		}
		
		translate(t)
		rotate(r)
		hul([0, e])
		translate(-[0,0,m/2])
		linear_extrude(m)
		rotate([0,0,90])
		circle(d=e, $fn=6);
		
		translate(t)
		rotate(r)
		translate(-[0,0,(m+7.2)/2])
		linear_extrude(m + 7.2)
		circle(d=3.2, $fn=24);
	}
}

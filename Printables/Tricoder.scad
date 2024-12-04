include <2d.scad>

s = [110, 35, 130];
dz = s.z / 2;
module o() { oval(s, [8, 4]); }

module oring() { 
	difference() {
		scale([(s.x + 7) / s.x, (s.y + 7) / s.y]) o();
		o();
	};
}

//hex_mount(e=6.6, m=2.5, t=[6 - 52.5, s.y / 2 - 4.9, 18], r=[90,0,0])
//hex_mount(e=6.6, m=2.5, t=[52.5 - 6, s.y / 2 - 4.9, 18], r=[90,0,0])
//hex_mount(e=6.6, m=2.5, t=[6 - 52.5, s.y / 2 - 4.9, 18 + 70 + 12], r=[90,180,0])
//hex_mount(e=6.6, m=2.5, t=[52.5 - 6, s.y / 2 - 4.9, 18 + 70 + 12], r=[90,180,0])
cut()
linear_extrude(s.z) oring();

module sq(s) {
	square(s, center=true);
}

module cut() {
	difference() {
		union() {
			children();
					
			translate([0, - 3.4 - s.y / 2, 0])
			rotate([90, 0, 180])
			translate([0, dz, 0])
			linear_extrude(7 - 0.1)
			sq([109, 75]);
			
			translate([0, 0, 5])
			linear_extrude(3.5)
			sq([s.x, s.y]);
			
			translate([0, 0, s.z - 8.5])
			linear_extrude(3.5)
			sq([s.x, s.y]);
		}
		
		for(i=[0: 3])
		translate([in * (1.5 - i), 0, 0])
		linear_extrude(10)
		circle(d=9.7, $fn=24);
		
		for(j=[0: 1])
		for(i=[0: 3])
		translate([in * (1.5 - i), s.y / 2 + 7.01 / 2, dz - in / 2 + in * j])
		rotate([90, 0, 0])
		union() {
			linear_extrude(0.7)
			circle(d=9.7, $fn=24);
			linear_extrude(7)
			circle(d=6.7, $fn=24);
		}
		
		for(j=[0: 1])
		for(i=[0: 1])
		translate([in * (1 - 2 * i), j * 19.05 - 19.05 / 2, 0])
		linear_extrude(10)
		oct([5.2, 6.2], 0.5);
		
		for(i=[0: 2])
		translate([33 * (1 - i), 0, s.z - 10])
		linear_extrude(10)
		XLR();
		
		translate([0, -6 - s.y / 2, 0])
		rotate([90, 0, 180])
		translate([0, dz, 0])
		linear_extrude(12)
		sq([105, 60]);
		
		translate([0, - s.y / 2 - 3.6, 0])
		rotate([90, 0, 180])
		translate([0, dz, 0])
		linear_extrude(3.5)
		oct([105, 67]);
	}
}

module hex_mount(m, e, t, r) {
	difference() {
		union() {
			children();
			
			translate(t)
			rotate(r)
			translate(-[0,0, 3.5 + m / 2])
			linear_extrude(m + 6.5)
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
		circle(d=3.2, $fn=16);
	}
}

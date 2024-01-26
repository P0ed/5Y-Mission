$fn = 64;

ds = 2;
dvh = [9, 6.5];

s = [dvh.x * 2 - ds, 12.2 - ds, 42 - ds * 2];

dx = 0.01;
m3 = 3.2;

wl = 4;

module col() {
	color("#FFEEEE")
	difference() {
		cube(s);
		
		translate([wl, wl, wl])
		cube([s.x, s.y, s.z - 2 * wl]);
		
		translate([dvh.x - ds, -dx, s.x / 2])
		rotate([-90, 0, 0])
		linear_extrude(wl + 2 * dx)
		circle(d=m3);
		
		translate([dvh.x - ds, -dx, s.z - s.x / 2])
		rotate([-90, 0, 0])
		linear_extrude(wl + 2 * dx)
		circle(d=m3);
		
		translate([-dx, dvh.y - ds, s.x / 2])
		rotate([0, 90, 0])
		linear_extrude(wl + 2 * dx)
		circle(d=m3);
		
		translate([-dx, dvh.y - ds, s.z - s.x / 2])
		rotate([0, 90, 0])
		linear_extrude(wl + 2 * dx)
		circle(d=m3);
		
		translate([dvh.x - ds, dvh.y - ds, -dx])
		linear_extrude(wl + 2 * dx)
		circle(d=m3);

		translate([dvh.x - ds, dvh.y - ds, s.z - dx - wl])
		linear_extrude(wl + 2 * dx)
		circle(d=m3);
	}
}

module sheet(s) {
	color("#EEFFEE")
	linear_extrude(ds)
	square(s);
}


translate([ds, ds, ds])
col();


// Bottom:
translate([ds, ds])
sheet([
	25.4 * 4.25 * 3 - 2 * ds,
	25.4 * 7 - 2 * ds
]);

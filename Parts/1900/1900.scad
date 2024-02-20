$fn = 192;
d = 12.7;
h = 17;
sr = 25.4;
mr = 0.4;
ma = 9.6;
d_insert = 9.6;
h_insert = 8.6;

difference() {
	// body
	intersection() {
		hull() {
			linear_extrude(0.1)
			circle(d=d);
			
			translate([0, 0, h])
			linear_extrude(0.1)
			circle(d=d * .94);
		}
		translate([0, 0, h - sr])
		sphere(sr);
	}
	
	// mark
	translate([0, 0, h])
	sphere(r=mr);

	translate([0, 0, h - sr])
	rotate([-ma, 0, 0])
	translate([0, 0, sr])
	sphere(r=mr);

	translate([0, 0, h - sr])
	rotate([0, -90, 0])
	rotate_extrude(angle=ma)
	translate([sr, 0, 0])
	circle(r=mr);

	// ribs
	for(i=[0:7]) {
		dr = 8.5;
		start = 1.85;
		end = 3.1;
		ph = 360 / 16;
		hull() {
			angl = i * 360 / 8 + ph;
			translate([sin(angl) * dr, cos(angl) * dr, 0])
			linear_extrude(0.1)
			circle(start);
			
			translate([sin(angl) * dr, cos(angl) * dr, h])
			linear_extrude(0.2)
			circle(end);
		}
	}

	// shaft hole
	translate([0, 0, -0.1])
	linear_extrude(12.7)
	circle(d=6.4);

	// insert hole
	translate([0, 0, -0.1])
	linear_extrude(h_insert)
	circle(d=d_insert);

	// set screw hole
	translate([0, -3 , 4.2])
	rotate([90, 0, 0])
	linear_extrude(5)
	circle(d=3.4);
}
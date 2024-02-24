function in(x) = x * 25.4;

module Knob(h, d, ribs, skirt, holes = true) {
	sr = 25.4;
	mr = 0.4;
	ma = 9.6;
	e_scale = 0.94;
	top_d = e_scale * d;
	skirt_h = in(3 / 32);
	skirt_d = in(3 / 4);
	d_insert = 9.6;
	h_insert = 8.6;

	difference() {
		// body
		union() {
			intersection() {
				linear_extrude(h, scale = e_scale)
				circle(d = d);
				translate([0, 0, h - sr])
				sphere(sr);
			}
			
			if(skirt) {
				linear_extrude(skirt_h / 2)
				circle(d = skirt_d);
				
				translate([0, 0, skirt_h / 2])
				linear_extrude(skirt_h / 2, scale = 1 / 1.5)
				circle(d = skirt_d);
			}
		}
		
		// mark
		if(!skirt) {
			translate([0, 0, h])
			sphere(mr);

			translate([0, 0, h - sr])
			rotate([-ma, 0, 0])
			translate([0, 0, sr])
			sphere(mr);

			translate([0, 0, h - sr])
			rotate([0, -90, 0])
			rotate_extrude(angle=ma)
			translate([sr, 0, 0])
			circle(mr);
		}
		if(skirt) {
			translate([
				0,
				skirt_d / 2 - mr * 2,
				skirt_h / 2 + mr
			])
			hull() {
				sphere(mr);
			
				dr = d / 2 + mr * 3.5 - skirt_d / 2;
				translate([0, dr, skirt_h / 2 + dr / 2])
				sphere(mr);
			}
		}

		// ribs
		difference() {
			for(i = [0 : ribs - 1]) {
				dr = d * 8.4 / 12.7;
				angl = i * 360 / ribs + 180 / ribs;
				translate([sin(angl) * dr, cos(angl) * dr, 0])
				linear_extrude(h, scale = 1.5)
				circle(d * 1.9 / 12.7);
			}		
			if(skirt)
			linear_extrude(skirt_h)
			circle(d);
		}

		if(holes) {
			// shaft hole
			translate([0, 0, -0.1])
			linear_extrude(h - in(3 / 32))
			circle(d=6.5);
			
			ds = skirt ? skirt_h / 2 : 0;

			// insert hole
			translate([0, 0, -0.01])
			linear_extrude(h_insert + ds)
			circle(d=d_insert);

			// set screw hole
			translate([0, -3 , 4.2 + ds])
			rotate([90, 0, 0])
			linear_extrude(5)
			circle(d=3.2);
			
			translate([0, 0, -0.01])
			if(skirt) {
				linear_extrude(in(1 / 32))
				circle(d = in(9 / 16));
				
				translate([0, 0, in(1 / 32) - 0.01])
				linear_extrude(in(1 / 32), scale = 1 / 1.5)
				circle(d = in(9 / 16));	
			}
		}
	}
}

module D1900() {
	Knob(h = in(0.63), d = in(1 / 2), ribs = 8, skirt = false);
}

module D1910() {
	Knob(h = in(1 / 2), d = in(17 / 32), ribs = 8, skirt = true);
}

module cs(box = [20, 20, 20]) {
	intersection() {
		cube(box);
		children();
	}
}

include <polyround.scad>;

$fn = 24;
in = 25.4;
dx = 0.01;

module tfm() {
	children();
}

module knob() {
	shaft_h = in * 3 / 8 - 1;
	shaft_d = 6.35 + 0.1;
	skirt_h = 2.5;
	skirt_d = 11;
	
	h = shaft_h + skirt_h + 2;
	top_r = 7;
	bot_r = 7;
	
	x = 1.2;
	rr = 1.4;
	
	shaft_hole(shaft_d, shaft_h, skirt_d, skirt_h)
	tfm()
	rotate_extrude()
	polygon(polyRound([
		[0, 0, 0],
		[bot_r, 0, 0],
		[top_r, h - x, 0],
		[top_r, h, rr / 1.2],
		[top_r - x * 2, h, rr],
		[top_r - x * 3, h - x, rr],
		[0, h - x, 0],
	], $fn / 8));
}

module shaft_hole(shaft_d, shaft_h, skirt_d, skirt_h, slot = true) {
	difference() {
		children();

		union() {
			if(skirt_h > 0) {
				translate([0, 0, -0.2])
				linear_extrude(skirt_h)
				circle(d = skirt_d);
			}

			difference() {
				translate([0, 0, -dx])
				linear_extrude(shaft_h + skirt_h)
				circle(d=shaft_d);

				if(slot) {
					translate([0, 0, shaft_h - 1.6 + skirt_h])
					linear_extrude(0.4, scale = [1.5, 1])
					square([1.1 / 1.5, shaft_d], center = true);
					
					translate([0, 0, shaft_h - 1.2 + skirt_h - dx])
					linear_extrude(1.2 + dx)
					square([1.1, shaft_d], center = true);
				}

				cnt = 8;
				rib_r = shaft_d / 64;
				difference() {
					for(i = [0: cnt - 1])
					rotate(i * 360 / cnt + 180 / cnt)
					translate([shaft_d / 2, 0, skirt_h])
					linear_extrude(shaft_h, scale = 1.05)
					circle(rib_r, $fn = 8);
					
					translate([0, 0, skirt_h - dx])
					linear_extrude(1, scale = 0.5)
					circle(d = shaft_d + rib_r);
				}
			}
		}
	}
}

module btn_cap() {
	top_r = 4.8 / 2;
	bot_r = 4.9 / 2;
	travel = 1.5;
	h = 5.4 + 0.8 - travel;
	
	x = 0.2;
	
	shaft_hole(2, h - 0.8, 0, 0, slot = false)
	rotate_extrude()
	polygon(polyRound([
		[0, 0, 0],
		[bot_r, 0, 0],
		[top_r, h - x, 0],
		[top_r, h, 4],
		[top_r - x * 4, h, 4],
		[top_r - x * 8, h - x, 4],
		[0, h - x, 0],
	], $fn / 8));
}


module cs(box = [20, 20, 20]) {
	intersection() {
		cube(box);
		children();
	}
}

//cs()
knob();
//btn_cap();

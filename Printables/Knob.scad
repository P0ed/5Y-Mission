include <polyround.scad>;

module knob() {
	shaft_h = 25.4 * 3 / 8 - 1;
	shaft_d = 6.35;
	skirt_h = 2.5;
	
	h = shaft_h + skirt_h + 2;
	top_r = 7;
	bot_r = 7;
	
	x = 1.2;
	rr = 1.4;
	
	shaft_hole(shaft_d, shaft_h, top_r - 1, skirt_h, true)
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

module shaft_hole(shaft_d, shaft_h, skirt_r, skirt_h, slot) {
	dx = 0.01;
	
	difference() {
		children();

		union() {
			if(skirt_h > 0) {
				translate([0, 0, -0.2])
				linear_extrude(skirt_h)
				circle(skirt_r);
			}

			difference() {
				translate([0, 0, -dx])
				linear_extrude(shaft_h + skirt_h)
				circle(d = shaft_d, $fn = 13);

				if(slot) {
					translate([0, 0, shaft_h - 1.6 + skirt_h])
					linear_extrude(0.4, scale = [1.5, 1])
					square([1.1 / 1.5, shaft_d], center = true);
					
					translate([0, 0, shaft_h - 1.2 + skirt_h - dx])
					linear_extrude(1.2 + dx)
					square([1.1, shaft_d], center = true);
				}
			}
		}
	}
}

module btn_cap(link) {
	top_r = 4.9 / 2;
	bot_r = top_r;
	travel = 1.5;
	h = 5.4 + 0.8 - travel;
	
	x = 0.39;
	k = 1.47;
	
	shaft_hole(2.8, h - 0.8, 0, 0, false) {

		if(link)
		translate([-3, -0.4, 0])
		cube([2, 0.8, 0.8]);

		rotate_extrude()
		polygon(polyRound([
			[0, 0, 0],
			[bot_r, 0, 0],
			[top_r, h - x * k, 0],
			[top_r * 1.01, h, 4],
			[top_r * 0.75, h, 4],
			[top_r * 0.51, h, 4],
			[top_r * 0.25, h - x / k, 4],
			[0, h - x / k, 0],
		], 3));
	}
}

//for(x = [0: 7])
//translate([14.4 * x, 0, 0])
//render()
//knob();

for(x = [0: 3])
translate([5.3 * x, 0, 0])
render()
btn_cap(x != 0, $fn = 31);

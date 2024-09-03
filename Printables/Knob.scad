r = 11 / 2;
l = 0.001;

shaft_h = 9.0;
shaft_d = 6.35;

skirt_r = 10.7 / 2;
skirt_h = 0;//2;

top_h = 3.3;
dc = 0.39;

h = shaft_h + skirt_h + top_h;

lq = 12;
mq = 24;
hq = 48;
vhq = 96;

module knob() {
	indicator(h, r)
	cut(h - 0.7, r)
	shaft_hole(shaft_d, shaft_h, skirt_r, skirt_h)
	ribs(8, 2.15, dc)
	linear_extrude(h)
	circle(r, $fn=vhq);
}

module ribs(cnt, rib_r, dr) {
	difference() {
		children();
		
		for(i = [0: cnt - 1])
		rotate(i * 360 / cnt + 180 / cnt)
		translate([r - dr + rib_r, 0, -l])
		cylinder(h + l * 2, rib_r, rib_r, $fn=hq);
	}
}

module shaft_hole(shaft_d, shaft_h, skirt_r, skirt_h) {
	difference() {
		children();

		union() {
			if(skirt_h > 0) {
				translate([0, 0, -l])
				linear_extrude(skirt_h)
				circle(skirt_r, $fn=hq);
			}

			difference() {
				translate([0, 0, -l])
				linear_extrude(shaft_h + skirt_h)
				circle(d = shaft_d, $fn=hq);

				translate([0, 0, shaft_h - 1.6 + skirt_h])
				linear_extrude(0.4, scale = [1.5, 1])
				square([1.1 / 1.5, shaft_d], center = true);
				
				translate([0, 0, shaft_h - 1.2 + skirt_h - l])
				linear_extrude(1.2 + l)
				square([1.1, shaft_d], center = true);
			}
		}
	}
}

module hl(t) {
	hull() {
		children();
		translate(t) children();
	}
}

module indicator(h, r) {
	difference() {
		children();

		sr = 1.5;
		scl = 0.6;

		translate([0, -dc, h + sr - dc])
		hl([0, r + sr, 0])
		rotate([0, 90, 0])
		sphere(sr, $fn=lq);
	}
}

module cut(h, r) {
	intersection() {
		children();
		
		union() {
			cylinder(h, r, r, $fn=vhq);
			translate([0, 0, h])
			cylinder(r, r, r / 4, $fn=vhq);
		}
	}
}

module row(cnt, offset) {
	dr = 2;
	dx = offset + dr;
	mw = 1.1;
	mo = 2.2;

	for(x = [0: cnt - 1])
	translate([dx * x, 0, 0])
	children();

	for(x=[0: cnt - 2])
	translate([dx * x + r - mo, -mw / 2, -1.8])
	difference() {
		cube([dx - r * 2 + mo * 2, mw, 2]);

		translate([mw, -l, mw])
		cube([dx - r * 2 + mo * 2 - mw * 2, mw + 2 * l, 2]);
	}
}

row(4, 10)
knob();

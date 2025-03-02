include <2d.scad>

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

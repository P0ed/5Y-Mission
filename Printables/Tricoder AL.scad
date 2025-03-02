include <2d.scad>
include <3d.scad>

s = [220, 180, 47];		// external size
ss = [s.y, s.z, 6];		// side
fs = [s.x - ss.z * 2, s.z, 8];		// front
rs = fs;				// rear
ear = 9;
pl = 0.001;

boltInsets = [[4 + ear, 4], [6, 6]];

//side();
//front();
//rear();
assemble();

module assemble() {
	rotate([0, 90, 0])
	translate(-[s.y, s.z - s.z, s.x] / 2)
	translate(ss / 2) {
		side();
		
		translate([0, 0, fs.x + ss.z])
		rotate([180, 0, 0])
		side();
		
		translate([-ss.x / 2 + ear + fs.z / 2, 0, fs.x / 2 + ss.z / 2])
		rotate([0, 90, 0])
		front();
		
		translate([ss.x / 2 - fs.z / 2, 0, fs.x / 2 + ss.z / 2])
		rotate([0, 90, 0])
		rear();
	}
}

module side() {
	cutSide()
	oct3(ss, r=0.5);
}

module front() {
	cutThread()
	oct3(fs, r=0.5);
}

module rear() {
	cutRear()
	rotate([180, 0, 0])
	cutThread()
	oct3(rs, r=0.5);
}

module cutRear() {
	difference() {
		union() {
			children();
		}
		
		translate([-in, -10, -rs.z / 2 - pl])
		linear_extrude(rs.z + pl * 2)
		miniXLR();
		
		translate([0, -10, -rs.z / 2 - pl])
		linear_extrude(rs.z + pl * 2)
		miniXLR();
		
		translate([in, -10, -rs.z / 2 - pl])
		linear_extrude(rs.z + pl * 2)
		miniXLR();
	}
}

module cutThread() {
	difference() {
		union() {
			children();
		}
		
		depth = 8;
		hs = 3.5;
		inst = boltInsets;
		
		translate([fs.x / 2 - depth + pl, -fs.y / 2 + inst.y.x, 0])
		rotate([0, 90, 0])
		cylinder(d=hs, h=depth, $fn=24);
		
		translate([fs.x / 2 - depth + pl, fs.y / 2 - inst.y.y, 0])
		rotate([0, 90, 0])
		cylinder(d=hs, h=depth, $fn=24);
		
		translate([-fs.x / 2 + depth - pl, -fs.y / 2 + inst.y.x, 0])
		rotate([0, -90, 0])
		cylinder(d=hs, h=depth, $fn=24);
		
		translate([-fs.x / 2 + depth - pl, fs.y / 2 - inst.y.y, 0])
		rotate([0, -90, 0])
		cylinder(d=hs, h=depth, $fn=24);
	}
}

module cutSide() {
	difference() {
		union() {
			children();
		}
		
		translate(-ss / 2) {
			insets = boltInsets;
			for(i = [0: 1]) for(j = [0: 1])
			translate([
				insets.x[0] + (ss.x - insets.x[0] - insets.x[1]) * i,
				insets.y[0] + (ss.y - insets.y[0] - insets.y[1]) * j,
				-pl
			])
			cylinder(d=4.1, h=ss.z + pl * 2, $fn=24);
			
			hd = ear / 3;
			earInsets = [hd, 4];
			translate([earInsets.x + hd / 2, earInsets.y + hd / 2])
			hul([0, ss.y - earInsets.y * 2 - hd])
			cylinder(d=hd, h=ss.z + pl * 2, $fn=24);
		}
	}
}

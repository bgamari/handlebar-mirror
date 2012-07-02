// handlebar_mirror.scad
// sizes are in mm

ball_rad = 8;
ball_fudge = 0.35;
socket_slits_n = 5;
bar_irad = 8.0;
bar_orad = 12;
bar_depth = 20;

insert_slits_n = 5; // Number of slits in bar insert
insert_irad = 7;

taper_angle = 5; // degrees

plug_height = bar_depth/3;

screw_rad = 4/2 + 0.5;
screw_head_rad = 7/2;

mirror_angle = 45; // degrees

// bar insert
module bar_insert() {
    difference() {
        union() {
            cylinder(r=bar_irad, h=bar_depth);
        
            translate([0,0,-2])
            cylinder(r=bar_orad, h=2);			// bar-end cap
        
            translate([0,0,-ball_rad-1])
            sphere(r=ball_rad-ball_fudge);		// ball
        }
        cylinder(r1=insert_irad-bar_depth*sin(taper_angle), r2=insert_irad, h=bar_depth+1);		// tapered hole

        translate([0,0,-ball_rad]) {
            cylinder(r=screw_rad, h=2*ball_rad);	// screw hole
            mirror([0,0,1])
            cylinder(r=screw_head_rad, h=2*ball_rad);	// counter sink
        }

        slits(insert_slits_n, bar_irad, 2*bar_depth);
    }
}

// expander plug
module expander_plug() {
    difference() {
        cylinder(r1=insert_irad-plug_height*sin(taper_angle), r2=insert_irad, h=plug_height);
        cylinder(r=screw_rad, h=3*plug_height, center=true);
        translate([0,0,plug_height]) m4_nut_catch(2*3.2);
    }
}

module hexagon(height, depth) {
    boxWidth=height/1.75;
    union(){
        cube([boxWidth, height, depth], center=true);
        rotate([0,0,60]) cube([boxWidth, height, depth], center=true);
        rotate([0,0,-60]) cube([boxWidth, height, depth], center=true);
    }
}

module m4_nut_catch(l) {
    hexagon(height=7.6, depth=l);
}

// socket
module socket(ball_frac = 0.75, slits_frac = 0.8) {
    module hi() {
        thickness = 2.4;
        r = ball_rad+thickness/2;
        angle = 20;
        difference() {
            circle(r=ball_rad+thickness);
            circle(r=ball_rad);
            translate([-2*ball_rad, -3*ball_rad/2]) square([2*ball_rad, 3*ball_rad]);
            polygon([ [0,0]
                    , [2*ball_rad*cos(-angle), 2*ball_rad*sin(-angle)]
                    , [0, -2*ball_rad]
                    ]);
        }
        translate([r*cos(-angle), r*sin(-angle)])
        circle(r=thickness/2, $fn=10);
    }

    mirror([0,0,1]) 
    difference() {
        mirror([0,0,1]) rotate_extrude() hi();

        translate([0,0, -2*(slits_frac-0.5)*ball_rad])
        slits(socket_slits_n, 3+ball_rad, 2*ball_rad);
    }
}

module socket2(ball_frac, slits_frac) {
    outer_rad = 3.0+ball_rad;
    mirror([0,0,1])
    difference() {
        union() {
            sphere(r=outer_rad);
            translate([0,0, -ball_rad])
            cylinder(r1=bar_orad, r2=outer_rad, h=6);
        }

        sphere(r=ball_rad);

        translate([0,0, 2*(ball_frac-0.5)*ball_rad])
        translate([-3*ball_rad/2, -3*ball_rad/2, 0])
        cube([3*ball_rad, 3*ball_rad, 2*ball_rad]);

        translate([0,0, -2*(slits_frac-0.5)*ball_rad])
        slits(socket_slits_n, 3+ball_rad, 2*ball_rad);
    }
}

module mirror_mount() {
    mount_length = 2*bar_orad / sin(mirror_angle);
    ball_frac = 0.70;
    slits_frac = 0.8;
    socket_offset = ball_rad*(slits_frac-1) - 4;

    translate([0,0,ball_rad/2 - socket_offset - 0.5])
    difference() {
        union() {
            cylinder(r=bar_orad, h=mount_length);

            translate([0,0, socket_offset-0.3])
            socket2(ball_frac=ball_frac, slits_frac=slits_frac);
        }

        translate([0,0, -1.2*ball_rad])
        cylinder(r1=1.1*ball_rad, r2=0.7*ball_rad, h=3);

        translate([0,0, socket_offset])
        sphere(r=ball_rad);

        translate([0, 0, mount_length*sin(mirror_angle)/2])
        rotate(a=mirror_angle, v=[1,0,0])
        translate([0, 0, mount_length*sin(mirror_angle)/2])
        cube([2*bar_orad, mount_length/sin(mirror_angle), mount_length*sin(mirror_angle)], center=true);
    }
}

module slits(n, r, d) {				// n cuts
    for (i = [0:n-1]) {
        rotate(a=i*360/n,v=[0,0,1])
        translate([0,-1,0])
        cube([r,1,d]);
    }
}

module print_plate() {
    translate([0,0,bar_depth]) rotate([180,0,0]) bar_insert();
    translate([30,0,0]) expander_plug();
    translate([-30,0,0]) mirror_mount();
}

module assembly() {
    bar_insert();
    translate([0,0,4/3*bar_depth]) expander_plug();
    translate([0,0,-2*ball_rad]) mirror([0,0,1]) mirror_mount();
}
    
print_plate();
//assembly();

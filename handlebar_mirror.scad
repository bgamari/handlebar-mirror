// handlebar_mirror.scad
// sizes are in mm

ball_rad = 8;
ball_fudge = -0.08;
bar_irad = 8.0;
bar_orad = 12;
bar_depth = 20;

insert_slits_n = 4; // Number of slits in bar insert
insert_irad = 5.5;

taper_angle = 5; // degrees

plug_height = bar_depth/3;

screw_rad = 4/2 + 0.6;
screw_head_rad = 7/2 + 0.6;

mirror_angle = 45; // degrees

// bar insert
module bar_insert() {
    difference() {
        union() {
            cylinder(r=bar_irad, h=bar_depth);
        
            translate([0,0,-2])
            cylinder(r=bar_orad, h=5);			// bar-end cap
        
            translate([0,0,-ball_rad-0.5])
            sphere(r=ball_rad-ball_fudge);		// ball
        }

        translate([0,0,+4])
        rotate_extrude()
        translate([bar_orad+1, 0])
        circle(5);

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

module mirror_mount() {
    mount_length = 2*bar_orad / sin(mirror_angle);
    ball_frac = 0.60;
    l = 15;

    difference() {
        cylinder(r=bar_orad, h=mount_length+l);

        // cut out side
        translate([0, 0, -1])
        rotate_extrude()
        translate([5+bar_orad, 0])
        scale([1,2])
        circle(7.5);

        // ball
        translate([0, 0, ball_rad * (1 - ball_frac)])
        sphere(r=ball_rad);

        // cut out top of ball hole
        translate([0,0,ball_rad+2])
        cylinder(r1=0.7*ball_rad, h=3);

        // slit
        cube([1+2*bar_orad, 1, 0.85*mount_length + l], center=true);
        
        // mirror flat
        translate([0, 0, l])
        translate([0, 0, mount_length*sin(mirror_angle)/2])
        rotate(a=mirror_angle, v=[1,0,0])
        translate([0, 0, mount_length*sin(mirror_angle)/2])
        cube([1+2*bar_orad, mount_length/sin(mirror_angle), mount_length*sin(mirror_angle)], center=true);

        translate([0, 0, 1.8*ball_rad]) {
            // nut catch
            rotate([90,0,0])
            translate([0, 0, bar_orad * 0.8])
            m4_nut_catch(bar_orad);

            // bolt hole
            rotate([90,0,0])
            cylinder(r=4.2/2, h=3*bar_orad, center=true);
        }
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
    
print_plate($fn=50);
//assembly();

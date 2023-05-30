include <Round-Anything/polyround.scad>

/* 
 * The original file was collected from https://www.printables.com/model/63198-stylish-plant-labels
 * by seasick.
 *
 * The modification I did are:
 * 1) Reduce the size of the stick to be suitable for printing on a Prusa MINI+ (18x18cm)
 * 2) Reduce the list to be scalar, so the name of the label and text direction can be
 *    provided from command line, allowing in this way having a simple shell script that
 *    calls openscad several times producing a different STL file each time for each label.
 *
 * Again, all rights go to the original author.
 *
 *
 * From command line you can run:
 *     openscad -o "basil_label.stl" stylish_plant_label.scad -D "label_text=\"Basil\""
 * or
 *     openscad -o "" -D "label_text=\"\"" -D "label_direction=\"rtl\""
 */    

/*
 * Labels
 */
label_font = "Liberation Sans:style=Bold";
label_text = "Locoto Rojo";
label_direction = "ltr";  // "rtl" for Hebrew.


/*
 * Text settings
 */
text_size_genus = 6;
text_thickness_genus = 5;
text_offset_y = 0;
text_offset_x = 0;

/*
 * Stick settings
 */
stick_length = 146;
stick_thickness = 4;
stick_tip_length = 14;
stick_tip_size = 1.5;
stick_width = 4;

/*
 * Leaves settings
 */
leaf_thickness = 5;
leaf_height = stick_length * 0.08;
leaf_width = stick_length * 0.05;
leaf_rounding_r = leaf_height - 1;
leaf_petiole_length = 10;
leaf_shrinkage = 0.65; // The relative size of the middle leaf compared to the others
leaf_stick_thickness = stick_thickness;


/**
 * Create extruded text
 */
module extrude_text(label, font, size, height, direction) {
  linear_extrude(height = height) {
    text(
      label,
      font = font,
      size = size,
      direction = direction,
      spacing = 1,
      halign = "right",
      valign = "center",
      $fn = 25
    );
  }
}

/**
 * Create the long pointy stick whichs end will be put into the ground
 */
module stick() {
  linear_extrude(height = stick_thickness) {
    polygon(polyRound([
      [0, 0, 1],
      [stick_length, 0, 0],
      [stick_length, stick_width, 0],
      [stick_tip_length, stick_width, 0],
      [0, stick_tip_size, 0],
      [0, stick_width, 0]
    ], 10));
  }
}

/**
 * Helper to create the nice looking leaves on top of the stick
 */
module leaves() {
  leaf_petiole_width = stick_width / 5;
  offset_middle_leaf = 8;
  offset_right_leaf = -5;

  // left leaf
  leaf(
    leaf_height,
    leaf_width,
    leaf_rounding_r,
    leaf_petiole_width,
    leaf_petiole_length,
    leaf_thickness,
    leaf_stick_thickness
  );

  // right leaf
  translate([offset_right_leaf, -leaf_petiole_width * 3, 0]) {
    leaf(
      leaf_height,
      -leaf_width,
      leaf_rounding_r,
      -leaf_petiole_width,
      leaf_petiole_length + offset_right_leaf,
      leaf_thickness,
      leaf_stick_thickness
    );
  }

  // middle (smaller) leaf
  translate([offset_middle_leaf, -leaf_petiole_width, 0]) {
    leaf(
      leaf_height * leaf_shrinkage,
      -leaf_width * leaf_shrinkage,
      leaf_rounding_r * leaf_shrinkage,
      -leaf_petiole_width,
      leaf_petiole_length + offset_middle_leaf,
      leaf_thickness, leaf_stick_thickness
    );
  }


  // Add round corners where leaves meet the stick.
  // Basically create a cube and remove a
  // cylinder on top to create the rounded edges
  loop = [
    [leaf_petiole_width, 2.5], // first is the position, second the x offset
    [leaf_petiole_width * 3, 0]
  ];

  for(i = loop) {
    translate([-leaf_petiole_length, -i[0], 0]) {
      cube([i[1], leaf_petiole_width, leaf_stick_thickness]);
      translate([i[1], 0, 0]) {
        difference() {
          cube([leaf_petiole_width / 2, leaf_petiole_width, leaf_stick_thickness]);
          translate([leaf_petiole_width / 2, leaf_petiole_width / 2, 0]) {
            cylinder(r = leaf_petiole_width / 2, leaf_stick_thickness * 2, $fn = 75);
          }
        }
      }
    }
  }
}

/**
 * Helper to create a single leaf, including its "petiole"
 */
module leaf(
  height,
  width,
  rounding_r,
  petiole_width,
  petiole_length,
  thickness,
  stick_thickness
) {
  linear_extrude(height = thickness) {
    polygon(polyRound([
      [0, 0, 0],
      [height, 0, rounding_r],
      [height, width,0],
      [0, width, rounding_r]
    ], 80));
  }
  linear_extrude(height = stick_thickness) {
    polygon([
      [1, 0],
      [-petiole_length, 0],
      [-petiole_length, petiole_width],
      [1, petiole_width]
    ]);
  }
}

/**
 * Putting everything together
 */
union() {
        stick();

        translate([stick_length + leaf_petiole_length, stick_width / 5 * 4, 0]) {
          leaves();
        }

        // Move to the end of the stick
        translate([stick_length - text_offset_x, text_offset_y, 0]) {
          // Genus text
          extrude_text(label_text, label_font, text_size_genus, text_thickness_genus, label_direction);
        }
}

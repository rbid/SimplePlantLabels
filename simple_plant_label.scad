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
 * 3) Simplified the script and STL for a faster print.
 *
 * Again, all rights go to the original author.
 *
 *
 * From command line you can run:
 *     openscad -o "basil_label.stl" simple_plant_label.scad -D "label_text=\"Basil\""
 * or
 *     openscad -o "basil_label_heb.stl" simple_plant_label.scad -D "label_text=\"בסיליקום\"" -D "label_direction=\"rtl\""
 */    

/*
 * Labels
 */
//label_font = "Liberation Sans:style=Bold";
label_font = "DejaVu Sans Condensed:style=Bold";
label_text = "Locoto Rojo";
label_direction = "ltr";  // "rtl" for Hebrew.
label_thickness = 5;
label_text_size = 7;


/*
 * Text settings
 */

text_offset_y = 0;
text_offset_x = 4;

/*
 * Stick settings
 */
stick_length = 170;
stick_thickness = 4;
stick_tip_length = 16;
stick_tip_size = 1.5;
stick_width = 4;

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
    polyRoundExtrude([
      [0, 0, 1],
      [stick_length, 0, 2],
      [stick_length, stick_width, 2],
      [stick_tip_length, stick_width, 0],
      [0, stick_tip_size, 1]], stick_thickness, 1, 0, fn=50);
}


/**
 * Putting everything together
 */
union() {
        stick();

        // Move to the end of the stick
        translate([stick_length - text_offset_x, text_offset_y, 0]) {
          extrude_text(label_text, label_font, label_text_size, label_thickness, label_direction);
        }
}

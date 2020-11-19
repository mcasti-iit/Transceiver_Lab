foreach channel [get_cells -hier -filter LIB_CELL=~GT*CHANNEL] {
	create_pblock [get_property NAME $channel]
    set col [get_property COLUMN [get_tiles -of [get_sites -of $channel]]]
    set row [get_property ROW [get_tiles -of [get_sites -of $channel]]]
    set height 4
    set width 6
    if {$col == 84} {set coor_x [expr "33 - $width + 1"]};#xc7a25t, xc7a12
    if {$col == 97} {set coor_x [expr "57 - $width + 1"]}; #xc7a35, xc7a50 right GTP column
    if {$col == 130} {set coor_x [expr "81 - $width + 1"]}; #xc7a75, xc7a100 right GTP column
    if {$col == 155} {set coor_x [expr "97 - $width + 1"]}; #xc7z015, xc7z012 right GTP column
    if {$col == 103} {set coor_x [expr "51 - $width + 1"]}; #xca7a200 left GTP column 
    if {$col == 167} {set coor_x 114}; #xca7a200 right GTP column
    if {[regexp {xc7z015.*} [get_property PART [current_design]]] || [regexp {xc7z012.*} [get_property PART [current_design]]]} {
		set coor_y [expr {159 - $row}]
	} elseif {[regexp {xc7a35.*} [get_property PART [current_design]]] || [regexp {xa7a35.*} [get_property PART [current_design]]] || [regexp {xq7a35.*} [get_property PART [current_design]]]} {
		set coor_y [expr {155 - $row}]
	} elseif {[regexp {xc7a50.*} [get_property PART [current_design]]] || [regexp {xa7a50.*} [get_property PART [current_design]]] || [regexp {xq7a50.*} [get_property PART [current_design]]] || [regexp {xc7a15.*} [get_property PART [current_design]]] || [regexp {xa7a15.*} [get_property PART [current_design]]]} {
		set coor_y [expr {155 - $row}]
	} elseif {[regexp {xc7a75.*} [get_property PART [current_design]]] || [regexp {xq7a75.*} [get_property PART [current_design]]] || [regexp {xa7a75.*} [get_property PART [current_design]]]} {
		# two quads per column
		if {$row < 47} {set coor_y [expr {205 - $row}]} else {set coor_y [expr {211 - $row}]}
	} elseif {[regexp {xc7a100.*} [get_property PART [current_design]]] || [regexp {xa7a100.*} [get_property PART [current_design]]] || [regexp {xq7a100.*} [get_property PART [current_design]]]} {
		# two quads per column
		if {$row < 47} {set coor_y [expr {205 - $row}]} else {set coor_y [expr {211 - $row}]}
	} elseif {[regexp {xc7a200.*} [get_property PART [current_design]]] || [regexp {xq7a200.*} [get_property PART [current_design]]] || [regexp {xa7a200.*} [get_property PART [current_design]]]} {
		# two quads per column
		if {$row < 47} {set coor_y [expr {255 - $row}]} else {set coor_y [expr {263 - $row}]}
    } elseif {[regexp {xc7a25.*} [get_property PART [current_design]]] || [regexp {xc7a12.*} [get_property PART [current_design]]] || [regexp {xa7a25.*} [get_property PART [current_design]]] || [regexp {xa7a12.*} [get_property PART [current_design]]]} {
		# two quads per column
		if {$row < 47} {set coor_y [expr {104 - $row}]} else {set coor_y [expr {110 - $row}]}
    } else {
		puts "Wrong part targeted"
	}
	resize_pblock [get_property NAME $channel] -add SLICE_X${coor_x}Y[expr "${coor_y} - $height + 1"]:SLICE_X[expr "${coor_x} + $width - 1"]Y${coor_y}
    add_cells_to_pblock [get_property NAME $channel] [all_fanin -only_cells -levels 8 -flat [get_pins  [file dir $channel]/U_PATTERN_HANDLER/gen*.patchk*/genzero*.all_one_or_zero_reg/D ]] -clear_locs
}

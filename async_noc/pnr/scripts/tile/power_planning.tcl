deleteAllPowerPreroutes 


# cut rows
cutRow -area 0 0 $fp_left [expr $tile_height + $fp_bottom + $fp_top]
cutRow -area 0 0 [expr $tile_width + $fp_right + $fp_left] $fp_bottom
cutRow -area [expr $tile_width + $fp_right] 0 [expr $tile_width + $fp_right + $fp_left] [expr $tile_height + $fp_bottom + $fp_top]
cutRow -area  0 [expr $tile_height + $fp_bottom] [expr $tile_width + $fp_right + $fp_left] [expr $tile_height + $fp_bottom + $fp_top]


set domains {noc_switch}

# Place the power domains
foreach domain $domains {
	set PD PD_$domain
	set nets "VDD_$domain GND"
	deselectAll

	# Ring
	selectObject Group $PD
	addRing -stacked_via_top_layer AP -around power_domain -jog_distance 2.5 -threshold 2.5 -type block_rings -nets $nets -stacked_via_bottom_layer M1 -layer {bottom M7 top M7 right M6 left M6} -width 5 -spacing 3 -offset 2.5

	# Stripes
	addStripe -block_ring_top_layer_limit M3 -max_same_layer_jog_length 6 -over_power_domain 1 -padcore_ring_bottom_layer_limit M1 -set_to_set_distance 50 -stacked_via_top_layer AP -padcore_ring_top_layer_limit M3 -spacing 2 -xleft_offset 37  -merge_stripes_value 2.5 -layer M6 -block_ring_bottom_layer_limit M1 -width 3 -nets "VDD_$domain" -stacked_via_bottom_layer M1
	
	addStripe -block_ring_top_layer_limit M3 -max_same_layer_jog_length 6 -over_power_domain 1 -padcore_ring_bottom_layer_limit M1 -set_to_set_distance 50 -stacked_via_top_layer AP -padcore_ring_top_layer_limit M3 -spacing 2 -xleft_offset 43 -merge_stripes_value 2.5 -layer M6 -block_ring_bottom_layer_limit M1 -width 3 -nets {GND} -stacked_via_bottom_layer M1
    
}   

deselectAll

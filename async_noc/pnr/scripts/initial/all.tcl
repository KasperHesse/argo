#freeDesign

# load design config
source scripts/load_design.tcl

# floorplanning
source scripts/floorplan.tcl
saveDesign floorplanned.enc

# tile placement 
source scripts/place_tiles.tcl

# hand route tile interconnection
set routes {}
source scripts/hand_route_edges.tcl  
source scripts/hand_route_tiles.tcl

# partitioning
savePartition -lib -dir ./partitions -def -pt

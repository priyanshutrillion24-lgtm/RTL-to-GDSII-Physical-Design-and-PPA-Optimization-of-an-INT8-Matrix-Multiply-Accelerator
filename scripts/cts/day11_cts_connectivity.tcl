# Read the Sky130 timing library
read_liberty /work/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# Read post-CTS database and constraints
read_db /work/results/sky130hd/int8_matmul/base/4_cts.odb
read_sdc /work/results/sky130hd/int8_matmul/base/4_cts.sdc

# Load RC settings and estimate placement parasitics
source /OpenROAD-flow-scripts/flow/platforms/sky130hd/setRC.tcl
estimate_parasitics -placement

# Examine the clock-buffer outputs with fanout violations
set clock_pins {
    clkbuf_4_13__f_clk/X
    clkbuf_4_8__f_clk/X
    clkbuf_4_0__f_clk/X
    clkbuf_4_1__f_clk/X
    clkbuf_4_2__f_clk/X
}

foreach pin_name $clock_pins {
    puts "\n========================================"
    puts "CLOCK PIN: $pin_name"

    set p [get_pins -hierarchical $pin_name]
    set n [get_nets -of_objects $p]

    puts "CONNECTED NET: [get_full_name $n]"
    puts "CONNECTED PINS:"

    foreach q [get_pins -of_objects $n] {
        puts "  [get_full_name $q]"
    }
}

# Examine the D-pin nets of the affected result-memory cells
set cells [get_cells -hierarchical *result_mem*]

foreach c $cells {
    set cname [get_full_name $c]

    if {[regexp {result_mem\[(31|47|23|7|63|15|39|55)\]\[14\]} $cname]} {
        puts "\n========================================"
        puts "RESULT MEMORY CELL: $cname"

        set dp [get_pins -of_objects $c -filter "name == D"]
        set n [get_nets -of_objects $dp]

        puts "CONNECTED NET: [get_full_name $n]"
        puts "CONNECTED PINS:"

        foreach q [get_pins -of_objects $n] {
            puts "  [get_full_name $q]"
        }
    }
}

# Identify the driver of acc_value_next_bus[147]
puts "\n========== RESULT MEMORY NET DRIVER =========="

foreach c [get_cells -hierarchical *result_mem*] {
    set cname [get_full_name $c]

    if {[regexp {result_mem\[15\]\[14\]} $cname]} {

        set dp [get_pins -of_objects $c -filter "name==D"]
        set n [get_nets -of_objects $dp]

        puts "NET: [get_full_name $n]"

        set drivers [get_pins -of_objects $n -filter "direction==output"]
        puts "DRIVER PINS:"

        foreach d $drivers {
            puts "  [get_full_name $d]"
            puts "  DRIVER CELL: [get_full_name [get_cells -of_objects $d]]"
        }

        set loads [get_pins -of_objects $n -filter "direction==input"]
        puts "NUMBER OF LOAD PINS: [llength $loads]"

        break
    }
}

# Investigate the other max-slew violating pins
puts "\n========== OTHER SLEW-VIOLATING NETS =========="

set other_slew_pins {
    _4794_/B
    _4793_/Y
    place1984/A
    place1974/A
    place1973/A
    _6903_/Y
}

foreach pin_name $other_slew_pins {
    puts "\nPIN: $pin_name"

    set p [get_pins -hierarchical $pin_name]
    if {[llength $p] == 0} {
        puts "Pin not found"
        continue
    }

    set n [get_nets -of_objects $p]

    puts "NET: [get_full_name $n]"

    set drivers [get_pins -of_objects $n -filter "direction==output"]
    foreach d $drivers {
        puts "DRIVER: [get_full_name $d]"
        puts "DRIVER CELL: [get_full_name [get_cells -of_objects $d]]"
    }
}

# Inspect standard-cell masters and pin electrical properties

puts "\n========== CELL MASTER DETAILS =========="

set inspect_cells {
    _4606_
    _4793_
    _4794_
    _6903_
    _6691_
    place1984
    place1974
    place1973
}

foreach cell_name $inspect_cells {

    set inst [get_cells $cell_name]

    if {[llength $inst] == 0} {
        puts "\nCELL NOT FOUND: $cell_name"
        continue
    }

    puts "\n----------------------------------------"
    puts "INSTANCE: [get_full_name $inst]"
    puts "MASTER: [get_property $inst ref_name]"

    set libcell [get_lib_cells -of_objects $inst]

    if {[llength $libcell] == 0} {
        puts "No Liberty master found"
        continue
    }

    puts "LIBERTY CELL: [get_property $libcell full_name]"
    puts "CELL AREA: [get_property $libcell area]"

    foreach lp [get_lib_pins -of_objects $libcell] {

        set pname [get_property $lp name]
        set direction [get_property $lp direction]

        puts "PIN: $pname  DIRECTION: $direction"

        if {$direction == "output"} {
            if {[catch {
                set value [get_property $lp drive_resistance]
            }]} {
                set value "not available"
            }
            puts "  DRIVE RESISTANCE: $value"
        } else {
            if {[catch {
                set value [get_property $lp capacitance]
            }]} {
                set value "not available"
            }
            puts "  INPUT CAPACITANCE: $value"
        }
    }
}
exit
